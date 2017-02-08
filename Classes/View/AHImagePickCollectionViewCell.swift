//
//  ImagePickCollectionViewCell.swift
//  Meepoo
//
//  Created by 黄辉 on 3/15/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit

protocol AHImagePickCollectionViewCellDelegate: NSObjectProtocol {
    func didTapSelectBtnWidthImagePickCollectionViewCell(_ cell: AHImagePickCollectionViewCell!)
    func didTapBrowseImageWithImagePickCollectionViewCell(_ cell: AHImagePickCollectionViewCell!)
}

class AHImagePickCollectionViewCell: UICollectionViewCell {

    private var imageView: UIImageView!
    private var selectImageView: UIImageView!
    private var isImageSelected: Bool = false

    weak var delegate: AHImagePickCollectionViewCellDelegate?

    let cellColor = UIColor(argb: 0xffe9e9e9)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = cellColor
        self.contentView.backgroundColor = cellColor

        self.imageView = UIImageView(frame: self.contentView.bounds)
        self.imageView.backgroundColor = cellColor
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)

        // 是否已经选择
        self.selectImageView = UIImageView()
        self.selectImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.selectImageView)

        self => self.selectImageView.top == self.contentView.top + 3
        self => self.selectImageView.right == self.contentView.right - 3
    }

    func config(image: UIImage?, isSelected: Bool, selectIndex: Int = 0, showSelectBtn: Bool = true, isMultipleSelected: Bool) {

        self.isImageSelected = isSelected

        if let _ = image {
            self.imageView.contentMode = UIViewContentMode.scaleAspectFill
            self.imageView.image = image
            self.selectImageView.isHidden = !showSelectBtn
            if isSelected {
                self.updateSelectViewStatus(isSelected: true, index: selectIndex, isMultipleSelected: isMultipleSelected)
            } else {
                self.updateSelectViewStatus(isSelected: false, isMultipleSelected: isMultipleSelected)
            }
        } else {
            if showSelectBtn {
                self.imageView.image = nil
            } else {
                self.imageView.contentMode = UIViewContentMode.center
                self.imageView.image = AHImagesPickerConfig.ImagePhotoSelectFromCamera
            }
            self.selectImageView.isHidden = true
        }
    }

    func selectBtnHidden(hidden: Bool) {
        self.selectImageView.isHidden = hidden
    }

    private func updateSelectViewStatus(isSelected: Bool, index: Int = 0, isMultipleSelected: Bool) {
        if isSelected {
            if isMultipleSelected {
                let imageName = "image_selected_\(index + 1)"
                self.selectImageView.image = LoadImage(imageName)
            } else {
                self.selectImageView.image = AHImagesPickerConfig.ImageSelected
            }
        } else {
            self.selectImageView.image = AHImagesPickerConfig.ImageUnSelected
        }
    }

    func isSelectedImage() -> Bool {
        return self.isImageSelected
    }

    func updateSelectedStatus(selected: Bool, selectIndex: Int = 0, animation: Bool = true, isMultipleSelected: Bool) {
        self.isImageSelected = selected
        if selected {
            self.updateSelectViewStatus(isSelected: true, index: selectIndex, isMultipleSelected: isMultipleSelected)
            if animation {
                self.selectImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.selectImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
            }
        } else {
            self.updateSelectViewStatus(isSelected: false, isMultipleSelected: isMultipleSelected)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        touches.forEach { (touch) -> () in

            let point = touch.location(in: self)

            if point.x <= (self.selectImageView.frame.maxX + 10)
                && point.x >= (self.selectImageView.frame.minX - 20)
                && point.y <= self.selectImageView.frame.maxY + 20
                && point.y >= self.selectImageView.frame.minY - 10 { // 选择

                    self.delegate?.didTapSelectBtnWidthImagePickCollectionViewCell(self)
                    return
            } else {
                self.delegate?.didTapBrowseImageWithImagePickCollectionViewCell(self)
            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func reuseIdentifier() -> String {
        return "ImagePickCollectionViewCellReuseIdentifier"
    }
}
