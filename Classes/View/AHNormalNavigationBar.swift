//
//  AHNormalNavigationBar.swift
//  AHImagesPicker
//
//  Created by 黄辉 on 7/6/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit

protocol AHNavigationBarDelegate: NSObjectProtocol {
    func navigationBarPopAction()
    func navigationBarPushAction()
}

class AHNormalNavigationBar : UIView {

    var backgroundView: UIView!

    var titleLabel: UILabel!

    private var titleLabelExtraRightConstraint: NSLayoutConstraint?

    internal var backBtn: UIButton!

    private var nextBtn: UIButton!

    private var slipLine: UIView! //分割线

    weak var delegate: AHNavigationBarDelegate?

    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.isUserInteractionEnabled = true

        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = AHImagesPickerConfig.ColorNavigationBar
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.backgroundView)

        self => self.backgroundView.left == self.left
        self => self.backgroundView.right == self.right
        self => self.backgroundView.top == self.top
        self => self.backgroundView.bottom == self.bottom

        // 标题
        self.titleLabel = UILabel()
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = AHImagesPickerConfig.ColorNormalText
        self.titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: UILayoutConstraintAxis.horizontal)
        self.titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: UILayoutConstraintAxis.horizontal)
        self.addSubview(self.titleLabel)

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self => self.titleLabel.top == self.top + AHImagesPickerConfigStatusBarHeight
        self => self.titleLabel.height == (AHImagesPickerConfigNavigationBarHeight - AHImagesPickerConfigStatusBarHeight)
        self => self.titleLabel.left >= self.left + 44
        self => self.titleLabel.right <= self.right - 44

        // 返回按钮
        self.backBtn = self.makeBtn()
        self.backBtn.setImage(AHImagesPickerConfig.ImageNavigationBarBack, for: UIControlState.normal)
        self.backBtn.addTarget(self, action: #selector(self.navigationBackBtnAction), for: UIControlEvents.touchUpInside)
        self.addSubview(self.backBtn)

        self => self.backBtn.left == self.left
        self => self.backBtn.bottom == self.bottom
        self => self.backBtn.height == (AHImagesPickerConfigNavigationBarHeight - AHImagesPickerConfigStatusBarHeight)

        // 下一步按钮
        self.nextBtn = self.makeBtn()
        self.nextBtn.addTarget(self, action: #selector(self.navigationNextBtnAction), for: UIControlEvents.touchUpInside)
        self.addSubview(self.nextBtn)

        self => self.nextBtn.right == self.right - 10
        self => self.nextBtn.bottom == self.backBtn.bottom
        self => self.nextBtn.height == (AHImagesPickerConfigNavigationBarHeight - AHImagesPickerConfigStatusBarHeight)

        // 分割线
        self.slipLine = UIView()
        self.slipLine.backgroundColor = AHImagesPickerConfig.ColorSeparatorLine
        self.slipLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.slipLine)

        self => self.slipLine.left == self.left
        self => self.slipLine.right == self.right
        self => self.slipLine.height == AHImagesPickerConfigPix
        self => self.slipLine.bottom == self.bottom
    }

    private func makeBtn() -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.backgroundColor = UIColor.clear
        button.setTitleColor(AHImagesPickerConfig.ColorNormalText, for: UIControlState.normal)
        button.setTitleColor(AHImagesPickerConfig.ColorNormalText.withAlphaComponent(0.5), for: UIControlState.disabled)
        button.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: UILayoutConstraintAxis.horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: UILayoutConstraintAxis.horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func updateBtnImage(button: UIButton, image: UIImage?, state: UIControlState = UIControlState.normal) {

        button.setTitle(nil, for: UIControlState.normal)
        button.setTitle(nil, for: UIControlState.selected)
        button.setTitle(nil, for: UIControlState.highlighted)

        if let btnImage = image {
            button.setImage(btnImage, for: state)
            button.isHidden = false
        } else {
            button.isHidden = true
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func updateBtnTitle(button: UIButton, title: String?, state: UIControlState = UIControlState.normal) {

        button.setImage(nil, for: UIControlState.normal)
        button.setImage(nil, for: UIControlState.selected)
        button.setImage(nil, for: UIControlState.highlighted)

        button.setTitle(title, for: state)
        if title == nil {
            button.isHidden = true
        } else {
            button.isHidden = false
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func setLeftBarItemImage(_ image: UIImage?, state: UIControlState = UIControlState.normal) {
        self.updateBtnImage(button: self.backBtn, image: image, state: state)
    }

    func setLeftBarItemTitle(_ title: String?, state: UIControlState = UIControlState.normal) {
        self.updateBtnTitle(button: self.backBtn, title: title, state: state)
    }

    func setRightBarItemImage(_ image: UIImage?, state: UIControlState = UIControlState.normal) {
        self.updateBtnImage(button: self.nextBtn, image: image, state: state)
    }

    func setRightBarItemTitle(_ title: String?, state: UIControlState = UIControlState.normal) {
        self.updateBtnTitle(button: self.nextBtn, title: title, state: state)
    }

    func setRightBarItemTitleColor(_ titleColor: UIColor, state: UIControlState) {
        self.nextBtn.setTitleColor(titleColor, for: state)
    }

    func setRightBarItemEnable(_ enable: Bool) {
        self.nextBtn.isEnabled = enable
    }

    func navigationBackBtnAction() {
        self.delegate?.navigationBarPopAction()
    }

    func navigationNextBtnAction() {
        self.delegate?.navigationBarPushAction()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
