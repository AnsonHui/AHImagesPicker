//
//  SelectOriginImageBar.swift
//  Meepoo
//
//  Created by 黄辉 on 4/22/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit
import Photos

protocol AHSelectOriginImageBarDelegate: NSObjectProtocol {

    func loadSelectOriginImagesPhAssetIdentifiers() -> [String]
}

class AHSelectOriginImageBar: UIView {

    private var selectBtn: UIButton!
    private var titleLabel: UILabel!
    private var imageSizeLabel: UILabel!
    private var loadingView: UIActivityIndicatorView!

    // 是否已经选择原图
    private var _isSelectOrigin: Bool = false
    var isSelectOrigin: Bool {
        get {
            return self._isSelectOrigin
        }
        set {
            self._isSelectOrigin = newValue

            if self._isSelectOrigin {
                self.selectBtn.setImage(AHImagesPickerConfig.ImageOriginSelected, for: UIControlState.normal)
                self.calculateSize()
            } else {
                self.selectBtn.setImage(AHImagesPickerConfig.ImageOriginUnSelected, for: UIControlState.normal)
                self.imageSizeLabel.text = ""
                self.loadingView.stopAnimating()
                self.loadingView.isHidden = true
            }
        }
    }

    weak var delegate: AHSelectOriginImageBarDelegate?

    init() {

        super.init(frame: CGRect(x: 0, y: AHImagesPickerConfigScreenHeight - 48, width: AHImagesPickerConfigScreenWidth, height: 48))

        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)

        // 选择按钮
        self.selectBtn = UIButton()
        self.selectBtn.setImage(AHImagesPickerConfig.ImageOriginUnSelected, for: UIControlState.normal)
        self.selectBtn.addTarget(self, action: #selector(self.selectBtnAction), for: UIControlEvents.touchUpInside)
        self.selectBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.selectBtn)

        self => self.selectBtn.top == self.top
        self => self.selectBtn.bottom == self.bottom
        self => self.selectBtn.left == self.left + 10
        self => self.selectBtn.width == 40

        // 标题
        self.titleLabel = self.makeLabel()
        self.titleLabel.text = AHImagesPickerConfig.StringOriginImage
        self.addSubview(self.titleLabel)

        self => self.titleLabel.left == self.selectBtn.right
        self => self.titleLabel.centerY == self.centerY

        // 原图大小
        self.imageSizeLabel = self.makeLabel()
        self.addSubview(self.imageSizeLabel)

        self => self.imageSizeLabel.left == self.titleLabel.right
        self => self.imageSizeLabel.centerY == self.centerY

        // 菊花
        self.loadingView = UIActivityIndicatorView()
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.loadingView)

        self => self.loadingView.centerY == self.centerY
        self => self.loadingView.left == self.titleLabel.right + 5

        // 分界线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lineView)

        self => lineView.left == self.left
        self => lineView.right == self.right
        self => lineView.top == self.top
        self => lineView.height == AHImagesPickerConfigPix
    }

    func calculateSize() {

        self.imageSizeLabel.text = ""
        self.loadingView.isHidden = false
        self.loadingView.startAnimating()
        self.selectBtn.isEnabled = false

        if let identifiers = self.delegate?.loadSelectOriginImagesPhAssetIdentifiers() {

            if identifiers.count == 0 {
                self.updateSize(0)
                return
            }

            var size: Int = 0
            var loadCount: Int = 0

            // 获取图片
            let results = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)

            results.enumerateObjects({ (asset, idx, stop) in

                PHCachingImageManager().requestImageData(for: asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, info) in

                    loadCount += 1

                    if let imageData = imageData {
                        size += imageData.count
                    }

                    if loadCount == identifiers.count {
                        self.updateSize(size)
                    }
                })
            })
        } else {
            self.updateSize(0)
        }
    }

    /**
     更新大小

     - parameter size: 字节
     */
    private func updateSize(_ size: Int) {

        self.imageSizeLabel.text = ""

        if size > 0 {

            let delayTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {

                self.selectBtn.isEnabled = true
                self.loadingView.isHidden = true
                self.loadingView.stopAnimating()

                if size < 1024 * 1024 { // 小于1MB
                    let kb = String(format: "%0.1f", Float(size) / 1024.0)
                    self.imageSizeLabel.text = " (\(kb)K)"
                } else {
                    let mb = String(format: "%0.1f", Float(size) / 1024.0 / 1024.0)
                    self.imageSizeLabel.text = " (\(mb)M)"
                }
            })
        } else {
            self.selectBtn.isEnabled = true
            self.loadingView.isHidden = true
            self.loadingView.stopAnimating()
        }
    }

    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.textColor = AHImagesPickerConfig.ColorNormalText
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func selectBtnAction() {
        if self.isSelectOrigin {
            self.isSelectOrigin = false
        } else {
            self.isSelectOrigin = true
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
