//
//  MultipleImageEditView.swift
//  Meepoo
//
//  Created by 黄辉 on 3/16/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit
import Photos
import YYImage

/// 最多选择图片个数
let kMaxCountSelectImage: Int = 9

class AHMultipleImageEditView: UIView {

    let kSizeImagePadding: CGFloat = 2
    let kSizePerImageViewWidth: CGFloat = 96

    // 每行显示图片个数
    private var perlineCount: Int = 0

    // 图片控件
    private var imageViews = [UIImageView]()

    // localIdentifier image
    private var _selectImages = [(String, UIImage)]()
    var images: [(String, UIImage)] {
        get {
            return self._selectImages
        }
        set {
            self._selectImages = newValue
            for i in 0 ..< kMaxCountSelectImage { // 更新图片
                let imageView = self.imageViews[i]
                if i < self._selectImages.count {
                    imageView.image = self._selectImages[i].1
                    imageView.isHidden = false
                    // 显示删除按钮
                    if let btn = imageView.subviews.filter({ (view) -> Bool in
                        return view is UIButton
                    }).first {
                        btn.isHidden = false
                    }
                } else {
                    if i == self._selectImages.count {
                        imageView.isHidden = false
                        imageView.image = nil
                        // 隐藏删除按钮
                        if let btn = imageView.subviews.filter({ (view) -> Bool in
                            return view is UIButton
                        }).first {
                            btn.isHidden = true
                        }
                    } else {
                        imageView.isHidden = true
                    }
                }
            }
        }
    }

    override init(frame: CGRect) {

        // 约定每行显示3个
        self.perlineCount = 3

        let rows = (kMaxCountSelectImage / self.perlineCount) + (kMaxCountSelectImage % self.perlineCount == 0 ? 0 : 1)

        var f = frame
        f.size.height = (kSizePerImageViewWidth * CGFloat(rows)) + (kSizeImagePadding * CGFloat(max(0, rows - 1)))
        super.init(frame: f)

        for i in 0 ..< kMaxCountSelectImage {
            let row = i / self.perlineCount
            let column = i % self.perlineCount
            let imageView = UIImageView(frame: CGRect(x: CGFloat(column) * (kSizePerImageViewWidth + kSizeImagePadding),
                                                      y: CGFloat(row) * (kSizePerImageViewWidth + kSizeImagePadding),
                                                      width: kSizePerImageViewWidth,
                                                      height: kSizePerImageViewWidth))
            imageView.tag = i
            imageView.backgroundColor = UIColor.clear
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            imageView.clipsToBounds = true
            self.addSubview(imageView)

            self.imageViews.append(imageView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
