//
//  AHImagesBrowser.swift
//  Meepoo
//
//  Created by 黄辉 on 3/18/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit

protocol AHImagesBrowserDelegate: NSObjectProtocol {
    /**
     加载图片
     */
    func imageBrowser(_ imageBrowser: AHImagesBrowser, loadImageByIndex index: Int, imageViewer: AHImageViewer!)

    /**
     初始化自定义View
     */
    func imageBrowser(_ imageBrowser: AHImagesBrowser, initCustomViewByIndex index: Int) -> UIView!

    /**
     配置自定义View
     */
    func imageBrowser(_ imageBrowser: AHImagesBrowser, configCustomView: UIView?, byIndex index: Int)

    /**
     浏览图片界面消失
     */
    func imageBrowserDismiss(_ imageBrowser: AHImagesBrowser)
}

class AHImagesBrowser: UIView, UIScrollViewDelegate, AHNavigationBarDelegate {

    var navigationBarView: AHNormalNavigationBar!
    private var scrollView: UIScrollView!

    // 图片总数
    private var _allImagesCount: Int = 0
    var allImagesCount: Int {
        get {
            return self._allImagesCount
        }
        set {
            self._allImagesCount = newValue
            self.currentIndex = min(self.currentIndex, newValue - 1)
            self.scrollView.contentSize = CGSize(width: self.bounds.size.width * CGFloat(self._allImagesCount), height: self.bounds.size.height)
        }
    }

    // 图片浏览，最多3个
    private var imageViews = [AHImageViewer]()

    // 当前浏览序号
    var currentIndex: Int = 0

    // 自定义View
    private var customView: UIView?

    weak var delegate: AHImagesBrowserDelegate?

    init() {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.black
        self.isUserInteractionEnabled = true

        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = true
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.delegate = self

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapAction(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTap)

        self.addSubview(self.scrollView)

        // 导航栏
        self.navigationBarView = AHNormalNavigationBar()
        self.navigationBarView.frame = CGRect(x: 0, y: 0, width: AHImagesPickerConfigScreenWidth, height: AHImagesPickerConfigNavigationBarHeight)
        self.navigationBarView.backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        self.navigationBarView.delegate = self
        self.addSubview(self.navigationBarView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK -- NavigationBarViewDelegate

    func navigationBarPopAction() {
        self.dismiss()
    }

    func navigationBarPushAction() {
        self.dismiss()
    }

    func rightExtraBtnAction() {
    }

    func dismiss() {

        self.delegate?.imageBrowserDismiss(self)

        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.scrollView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 0.2
            }) { (completed) -> Void in
                self.removeFromSuperview()
                self.scrollView.transform = CGAffineTransform.identity
                self.alpha = 1.0
        }
    }

    func doubleTapAction(tap: UITapGestureRecognizer) {

        let touchPoint = tap.location(in: self)

        if self.currentIndex == 0 {
            self.imageViews[0].doubleTapActionAtPoint(touchPoint)
        } else if self.currentIndex == self.allImagesCount - 1 {
            self.imageViews[2].doubleTapActionAtPoint(touchPoint)
        } else {
            self.imageViews[1].doubleTapActionAtPoint(touchPoint)
        }
    }

    func showInParentView(_ parentView: UIView) {

        self.frame = parentView.bounds
        parentView.addSubview(self)

        let currentCount = self.imageViews.count
        if currentCount < min(self._allImagesCount, 3) {
            for i in currentCount ..< min(self._allImagesCount, 3) {
                let imageViewer = AHImageViewer(frame: CGRect(x: parentView.bounds.size.width * CGFloat(i), y: 0, width: parentView.bounds.size.width, height: parentView.bounds.size.height))
                self.imageViews.append(imageViewer)
            }
        }

        // 设置frame
        for i in 0 ..< self.imageViews.count {
            self.imageViews[i].frame = CGRect(x: parentView.bounds.size.width * CGFloat(i), y: 0, width: parentView.bounds.size.width, height: parentView.bounds.size.height)
        }

        // 初始化自定义View
        self.customView = self.delegate?.imageBrowser(self, initCustomViewByIndex: self.currentIndex)

        self.resetImageViews()

        // 出场动画
        self.scrollView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.scrollView.transform = CGAffineTransform.identity
            }) { (completed) -> Void in
        }
    }

    func resetImageViews() {

        self.imageViews.forEach { (imageView) -> () in
            imageView.removeFromSuperview()
        }

        for i in 0 ..< min(self._allImagesCount, 3) {
            let imageViewer = self.imageViews[i]
            self.scrollView.addSubview(imageViewer)
        }

        if self.currentIndex == 0 || self._allImagesCount < 4 { // 点击第0张，或者总数不超过4张，按顺序获取
            for i in 0 ..< min(self._allImagesCount, 3) {
                let imageView = self.imageViews[i]
                self.delegate?.imageBrowser(self, loadImageByIndex: i, imageViewer: imageView)
                imageView.ahLeft = CGFloat(i) * self.bounds.size.width
            }
        } else if self.currentIndex == self.allImagesCount - 1 { // 点击最后一张

            self.delegate?.imageBrowser(self, loadImageByIndex: self.currentIndex, imageViewer: self.imageViews[2])
            self.imageViews[2].ahLeft = CGFloat(self.currentIndex) * self.bounds.size.width

            self.delegate?.imageBrowser(self, loadImageByIndex: self.currentIndex - 1, imageViewer: self.imageViews[1])
            self.imageViews[1].ahLeft = CGFloat(self.currentIndex-1) * self.bounds.size.width

            self.delegate?.imageBrowser(self, loadImageByIndex: self.currentIndex - 2, imageViewer: self.imageViews[0])
            self.imageViews[0].ahLeft = CGFloat(self.currentIndex-2) * self.bounds.size.width

        } else {

            self.delegate?.imageBrowser(self, loadImageByIndex: self.currentIndex, imageViewer: self.imageViews[1])
            self.imageViews[1].ahLeft = CGFloat(self.currentIndex) * self.bounds.size.width

            self.delegate?.imageBrowser(self, loadImageByIndex: self.currentIndex - 1, imageViewer: self.imageViews[0])
            self.imageViews[0].ahLeft = CGFloat(self.currentIndex - 1) * self.bounds.size.width

            self.delegate?.imageBrowser(self, loadImageByIndex: self.currentIndex + 1, imageViewer: self.imageViews[2])
            self.imageViews[2].ahLeft = CGFloat(self.currentIndex + 1) * self.bounds.size.width
        }

        self.scrollView.contentOffset = CGPoint(x: CGFloat(self.currentIndex) * self.bounds.size.width, y: 0)
    
        self.navigationBarView.titleLabel.text = "\(self.currentIndex + 1)/\(self.allImagesCount)"

        // 配置自定义View
        self.delegate?.imageBrowser(self, configCustomView: self.customView, byIndex: self.currentIndex)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        var extra: Float = 0.0
        if velocity.x > 0.6 {
            extra = 0.5
        } else if velocity.x < -0.6 {
            extra = -0.5
        }

        let index = min(
                        max(
                            roundf(Float(scrollView.contentOffset.x) / Float(self.bounds.size.width) + extra),
                            0),
                        Float(self.allImagesCount - 1)
                    )

        targetContentOffset.pointee.x = self.bounds.size.width * CGFloat(index)

        self.updateImagesByContentOffsetX(self.bounds.size.width * CGFloat(index), index: Int(index))
    }

    func updateImagesByContentOffsetX(_ contentOffsetX: CGFloat, index: Int) {

        if self.currentIndex == index {
            return
        }

        if self.currentIndex < index { // 滑向左边
            if index != 1 && index != self.allImagesCount-1 { // 不等于第1个 和 不等于最后一个
                let imageView = self.imageViews.first!
                self.imageViews.removeFirst()
                self.imageViews.append(imageView)
                imageView.ahLeft = contentOffsetX + self.bounds.size.width
                self.delegate?.imageBrowser(self, loadImageByIndex: index + 1, imageViewer: imageView)
            }
        } else { // 滑向右边
            if index != 0 && index != self.allImagesCount-2 { // 不等于第0个 和 不等于倒数第二个
                let imageView = self.imageViews.last!
                self.imageViews.removeLast()
                self.imageViews.insert(imageView, at: 0)
                imageView.ahLeft = contentOffsetX - self.bounds.size.width
                self.delegate?.imageBrowser(self, loadImageByIndex: index - 1, imageViewer: imageView)
            }
        }

        self.currentIndex = index
        self.navigationBarView.titleLabel.text = "\(self.currentIndex + 1)/\(self.allImagesCount)"

        // 配置自定义View
        self.delegate?.imageBrowser(self, configCustomView: self.customView, byIndex: self.currentIndex)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
