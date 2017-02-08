//
//  AHImageViewer.swift
//  Meepoo
//
//  Created by 黄辉 on 3/18/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit
import YYImage
import AHCategories

class AHImageViewer: UIView, UIScrollViewDelegate {

    private var scrollView: UIScrollView!
    var imageView: YYAnimatedImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.delegate = self
        self.scrollView.bouncesZoom = true
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.bounces = false
        self.scrollView.isMultipleTouchEnabled = true
        self.scrollView.contentSize = CGSize(width: self.bounds.size.width, height: self.bounds.size.height)
        self.addSubview(self.scrollView)

        self.imageView = YYAnimatedImageView()
        self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        self.scrollView.addSubview(self.imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(image: UIImage?) {
        self.imageView.image = image
        self.resizeSubviewSize()
    }

    func doubleTapActionAtPoint(_ point: CGPoint) {
        if self.scrollView.zoomScale > 1 {
            self.scrollView.setZoomScale(1, animated: true)
        } else {
            let newZoomScale = self.scrollView.maximumZoomScale
            let xSize = self.bounds.width / newZoomScale
            let ySize = self.bounds.height / newZoomScale
            self.scrollView.zoom(to: CGRect(x: point.x - xSize / 2, y: point.y - ySize / 2, width: xSize, height: ySize), animated: true)
        }
    }

    func resizeSubviewSize() {
        if let image = self.imageView.image {
//            if image.size.width < self.bounds.width && image.size.height < self.bounds.height {
//                self.imageView.ahHeight = image.size.height
//                self.imageView.ahWidth = image.size.width
//            } else
            if image.size.height / image.size.width > self.bounds.height / self.bounds.width { // 图片高度比例超过屏幕高度比例，按原始高度显示
                self.imageView.ahHeight = self.bounds.height
                self.imageView.ahWidth = self.bounds.height * image.size.width / image.size.height
            } else {
                self.imageView.ahWidth = self.bounds.width
                self.imageView.ahHeight = image.size.height / image.size.width * self.bounds.width
            }
            self.imageView.ahCenterX = self.bounds.width / 2
            self.imageView.ahCenterY = self.bounds.height / 2

            self.scrollView.contentSize = CGSize(width: self.bounds.width, height: max(self.imageView.ahHeight, self.bounds.height))
            self.scrollView.scrollRectToVisible(self.bounds, animated: false)

            // 计算最大可放大的倍数
            let wScale = self.bounds.size.width / image.size.width
            let hScale = self.bounds.size.height / image.size.height
            let maximumZoomScale = min(wScale, hScale)
            self.scrollView.maximumZoomScale = max(3.0, maximumZoomScale)
        } else {
            self.imageView.frame = self.bounds
            self.scrollView.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height)
            self.scrollView.scrollRectToVisible(self.bounds, animated: false)
            self.scrollView.maximumZoomScale = 1
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (self.scrollView.bounds.size.width > scrollView.contentSize.width) ? (self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (self.scrollView.bounds.size.height > scrollView.contentSize.height) ? (self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5 : 0.0
        self.imageView.center = CGPoint(x: self.scrollView.contentSize.width * 0.5 + offsetX, y: self.scrollView.contentSize.height * 0.5 + offsetY)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
