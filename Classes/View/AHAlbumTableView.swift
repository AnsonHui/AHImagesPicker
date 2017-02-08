//
//  AlbumTableView.swift
//  Meepoo
//
//  Created by 黄辉 on 3/15/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit
import Photos

class AHAlbumTableViewCell: UITableViewCell {

    var albumImageView: UIImageView!
    var albumNameLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(argb: 0xffe7e7e7)
        self.selectedBackgroundView = selectedView
        self.contentView.backgroundColor = UIColor.white

        // 图片
        self.albumImageView = UIImageView()
        self.albumImageView.backgroundColor = UIColor.lightGray
        self.albumImageView.clipsToBounds = true
        self.albumImageView.layer.cornerRadius = 1.0
        self.albumImageView.layer.masksToBounds = true
        self.contentView.addSubview(self.albumImageView)

        self.albumImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView => self.albumImageView.left == self.contentView.left + 10
        self.contentView => self.albumImageView.centerY == self.contentView.centerY
        self.contentView => self.albumImageView.height == 60
        self.contentView => self.albumImageView.width == 60

        // 文字
        self.albumNameLabel = UILabel()
        self.albumNameLabel.backgroundColor = UIColor.clear
        self.albumNameLabel.textAlignment = NSTextAlignment.left
        self.albumNameLabel.font = UIFont.systemFont(ofSize: 16.0)
        self.albumNameLabel.textColor = AHImagesPickerConfig.ColorNormalText
        self.albumNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.albumNameLabel)

        self.contentView => self.albumNameLabel.left == self.albumImageView.right + 16
        self.contentView => self.albumNameLabel.centerY == self.contentView.centerY
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func reuseIdentifier() -> String {
        return "AlbumTableViewCellReuseIdentifier"
    }

    class func height() -> CGFloat {
        return 70
    }
}

protocol AHAlbumTableViewDelegate: NSObjectProtocol {
    func albumTableViewSelect(index: Int)
    func albumTableViewDismiss()
}

class AHAlbumTableView: UIView, UITableViewDelegate, UITableViewDataSource {

    private var backgroundView: UIView!
    private var tableViewBackView: UIView!
    private var tableView: UITableView!

    var albumGroup: [AHImagesPickGroup]!

    weak var delegate: AHAlbumTableViewDelegate?

    private var selectIndex: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = true

        // 背景半透明
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0.5
        self.backgroundView.isUserInteractionEnabled = true
        self.backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backgroundViewTapAction)))
        self.addSubview(self.backgroundView)

        // 列表背景
        let height = 4.5 * AHAlbumTableViewCell.height()
        self.tableViewBackView = UIView(frame: CGRect(x: 0, y: -height, width: AHImagesPickerConfigScreenWidth, height: height))
        self.tableViewBackView.backgroundColor = AHImagesPickerConfig.ColorCommonBackground
        self.addSubview(self.tableViewBackView)

        // 列表
        self.tableView = UITableView(frame: CGRect(x: 0, y: -tableViewBackView.bounds.size.height, width: AHImagesPickerConfigScreenWidth, height: tableViewBackView.bounds.size.height))
        self.tableView.backgroundColor = AHImagesPickerConfig.ColorCommonBackground
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = AHAlbumTableViewCell.height()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        self.tableView.register(AHAlbumTableViewCell.classForCoder(), forCellReuseIdentifier: AHAlbumTableViewCell.reuseIdentifier())

        self.addSubview(self.tableView)
    }

    // UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumGroup.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AHAlbumTableViewCell.height()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: AHAlbumTableViewCell.reuseIdentifier(), for: indexPath as IndexPath) as? AHAlbumTableViewCell {

            let album = self.albumGroup[indexPath.row]

            // 获取相册图标
            if let asset = album.albumIconAsset {
                PHImageManager().requestImage(for: asset, targetSize: CGSize(width: 50, height: 50), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, data) in

                    if let image = image {
                        cell.albumImageView.image = image
                    }
                })
            } else {
                cell.albumImageView.image = nil
            }
            cell.albumNameLabel.text = "\(album.albumName ?? "") (\(album.imagesAsset!.count))"
            cell.isSelected = indexPath.row == self.selectIndex

            return cell
        }

        return UITableViewCell()
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.selectIndex = indexPath.row

        self.delegate?.albumTableViewSelect(index: indexPath.row)
        self.dismiss()
    }

    func backgroundViewTapAction() {
        self.delegate?.albumTableViewDismiss()
        self.dismiss()
    }

    func presentInView(_ view: UIView) {

        view.addSubview(self)

        self.backgroundView.alpha = 0.0
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.backgroundView.alpha = 0.6
        }

        self.tableView.ahTop = -self.tableView.ahHeight
        self.tableViewBackView.ahTop = -self.tableView.ahHeight

        UIView.animate(withDuration: 0.4) { () -> Void in
            self.tableViewBackView.ahTop = 0
        }

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { 
            self.tableView.ahTop = 0
            }) { (finished) in
                self.tableView.selectRow(at: IndexPath(row: self.selectIndex, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.none)
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.backgroundView.alpha = 0.0
            self.tableView.ahTop = -self.tableView.ahHeight
            self.tableViewBackView.ahTop = -self.tableView.ahHeight
            }) { (finished) -> Void in
                self.removeFromSuperview()
                self.backgroundView.alpha = 1.0
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
