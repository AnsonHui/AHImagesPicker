//
//  AHImagesPickerConfig.swift
//  AHImagesPicker
//
//  Created by 黄辉 on 7/6/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit
import AHCategories

let AHImagesPickerConfigScreenWidth: CGFloat = UIScreen.main.bounds.width
let AHImagesPickerConfigScreenHeight: CGFloat = UIScreen.main.bounds.height
let AHImagesPickerConfigNavigationBarHeight: CGFloat = 64
let AHImagesPickerConfigPix: CGFloat = 1 / UIScreen.main.scale
let AHImagesPickerConfigStatusBarHeight: CGFloat = 20

// 每行显示的个数
let AHImagesPickerConfigImagesCountOfPerline: Int = 3
// 格子之间的间距
let AHImagesPickerConfigImagePadding: CGFloat = 3.0
// 左右间距
let AHImagesPickerConfigScreenPadding: CGFloat = 3.0
// 格子的最小宽度
let kSizeImageCollectionCellWidth = floor((AHImagesPickerConfigScreenWidth - CGFloat(AHImagesPickerConfigImagesCountOfPerline - 1) * AHImagesPickerConfigImagePadding - AHImagesPickerConfigScreenPadding * 2) / CGFloat(AHImagesPickerConfigImagesCountOfPerline))

internal func LoadImage(_ imageName: String) -> UIImage? {
    let podBundle = Bundle(for: AHImagesPickerConfig.self)
    return UIImage(named: imageName, in: podBundle, compatibleWith: nil)
}

class AHImagesPickerConfig: NSObject {

    // 最多选择图片的数量
    static var MaxCountSelectImage: Int = 9

    // 裁剪图片的最大尺寸
    static var MaxThumbImageSize: CGFloat = 220 * UIScreen.main.scale

    // 颜色
    static var ColorNavigationBar = UIColor(argb: 0xffe33f33)
    static var ColorNormalText = UIColor.black
    static var ColorSeparatorLine = UIColor.lightGray
    static var ColorCommonBackground = UIColor(argb: 0xffebeff5)

    // 文本
    static var StringTapChangeAlbum = "轻触这里切换相册"
    static var StringImageNotSyncFromiCloud = "iCloud未同步"
    static var StringCompleted = "完成"
    static var StringOverLimit = "最多只能选9张图片"
    static var StringAllPhotos = "所有照片"
    static var StringOriginImage = "原图"
    static var StringAlertFine = "好"

    // 图片
    static var ImageTapChangeAlbum = LoadImage("navigationbar_drop_down@3x")
    static var ImageNavigationBarBack = LoadImage("navigation_bar_back")
    static var ImageSelected = LoadImage("selected")
    static var ImageUnSelected = LoadImage("unselected")
    static var ImageOriginSelected = LoadImage("origin_image_selected")
    static var ImageOriginUnSelected = LoadImage("origin_image_unselected")
    static var ImagePhotoSelectFromCamera = LoadImage("photo_select_camera")
}
