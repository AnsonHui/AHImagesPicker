//
//  AHImagesPickerNavigationBar.swift
//  Meepoo
//
//  Created by 黄辉 on 3/15/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit

protocol AHImagesPickerNavigationBarDelegate: NSObjectProtocol {
    func ahImagesPickerNavigationBarTapTitleAction()
}

class AHImagesPickerNavigationBar: AHNormalNavigationBar {

    weak var tapTitleDelegate: AHImagesPickerNavigationBarDelegate?

    private var tapNoteLabel: UILabel!
    private var tapImageView: UIImageView!

    override init() {
        super.init()

        // 标题
        self.removeConstraints(self.titleLabel.constraints)
        self => self.titleLabel.top == self.top + AHImagesPickerConfigStatusBarHeight
        self => self.titleLabel.height == 23
        self => self.titleLabel.centerX == self.centerX

        // 提示点击
        self.tapNoteLabel = UILabel()
        self.tapNoteLabel.backgroundColor = AHImagesPickerConfig.ColorNavigationBar
        self.tapNoteLabel.textAlignment = NSTextAlignment.center
        self.tapNoteLabel.font = UIFont.systemFont(ofSize: 11.0)
        self.tapNoteLabel.textColor = AHImagesPickerConfig.ColorNormalText
        self.tapNoteLabel.text = AHImagesPickerConfig.StringTapChangeAlbum
        self.tapNoteLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.tapNoteLabel)

        self => self.tapNoteLabel.top == self.titleLabel.bottom
        self => self.tapNoteLabel.centerX == self.centerX

        // 三角形
        self.tapImageView = UIImageView()
        self.tapImageView.image = AHImagesPickerConfig.ImageTapChangeAlbum
        self.tapImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.tapImageView)

        self => self.tapImageView.left == self.tapNoteLabel.right + 2
        self => self.tapImageView.centerY == self.tapNoteLabel.centerY
    }

    func updateTriangleDown(_ down: Bool) {
        if down {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tapImageView.transform = CGAffineTransform(rotationAngle: 3.14 * 2)
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tapImageView.transform = CGAffineTransform(rotationAngle: -3.14)
            })
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        touches.forEach { (touch) -> () in

            let point = touch.location(in: self)

            if point.x <= (max(self.titleLabel.frame.maxX, self.tapNoteLabel.frame.maxX) + 10)
                && point.x >= (min(self.titleLabel.frame.minX, self.tapNoteLabel.frame.minX) - 10)
                && point.y <= self.tapNoteLabel.frame.maxY + 10
                && point.y >= self.titleLabel.frame.minY - 10 { // 下拉菜单

                    self.tapTitleDelegate?.ahImagesPickerNavigationBarTapTitleAction()
                    return
            }
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
