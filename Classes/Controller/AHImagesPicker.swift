//
//  AHImagesPicker.swift
//  Meepoo
//
//  Created by 黄辉 on 3/15/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

class AHImagesPickGroup: NSObject {
    var albumIconAsset: PHAsset?
    var albumName: String!
    var imagesAsset: [PHAsset]?
}

protocol AHImagesPickerDelegate: NSObjectProtocol {
    func ahImagesPicker(viewController: AHImagesPicker!, selectResult: [(String, UIImage)]!, isOrigin: Bool)
}

enum AHImagesPickerMode: Int {

    case Single = 0   // 单选
    case Multiple = 1 // 多选
}

class AHImagesPicker: UIViewController {

    weak var delegate: AHImagesPickerDelegate?

    fileprivate var navigationBarView: AHImagesPickerNavigationBar!

    fileprivate var collectionView: UICollectionView!
    fileprivate var selectOriginImageBar: AHSelectOriginImageBar!

    // 当前的相册序号
    fileprivate var currentIndex: Int = 0

    let imageManager = PHCachingImageManager()

    // 所有相册数据
    fileprivate var allAlbums = [AHImagesPickGroup]()

    // 所选照片 localIdentifier image
    fileprivate var selectResults = [(String, UIImage)]()

    fileprivate lazy var albumTableView: AHAlbumTableView = {
        [unowned self] in
        let tableView = AHAlbumTableView(frame: CGRect(x: 0, y: AHImagesPickerConfigNavigationBarHeight,
                                                       width: AHImagesPickerConfigScreenWidth,
                                                       height: AHImagesPickerConfigScreenHeight - AHImagesPickerConfigNavigationBarHeight))
        tableView.delegate = self
        return tableView
    }()

    fileprivate var selectImageMode = AHImagesPickerMode.Multiple

    init(selectResult: [(String, UIImage)]? = nil, selectImageMode: AHImagesPickerMode) {
        super.init(nibName: nil, bundle: nil)

        self.selectImageMode = selectImageMode

        if let _ = selectResult {
            self.selectResults = selectResult!
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBarView = AHImagesPickerNavigationBar()
        self.navigationBarView.frame = CGRect(x: 0, y: 0, width: AHImagesPickerConfigScreenWidth, height: AHImagesPickerConfigNavigationBarHeight)
        self.navigationBarView.titleLabel.text = AHImagesPickerConfig.StringAllPhotos
        self.navigationBarView.setRightBarItemTitle(AHImagesPickerConfig.StringCompleted)
        self.updateSelectImageCountToNavigationBar(count: self.selectResults.count)
        self.navigationBarView.tapTitleDelegate = self
        self.navigationBarView.delegate = self
        self.view.addSubview(self.navigationBarView)

        // 底部选择原图的工具栏
        self.selectOriginImageBar = AHSelectOriginImageBar()
        self.selectOriginImageBar.delegate = self
        self.view.addSubview(self.selectOriginImageBar)

        // 列表
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = AHImagesPickerConfigImagePadding
        collectionViewLayout.minimumLineSpacing = AHImagesPickerConfigImagePadding

        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: AHImagesPickerConfigNavigationBarHeight,
                                                             width: AHImagesPickerConfigScreenWidth,
                                                             height: AHImagesPickerConfigScreenHeight - AHImagesPickerConfigNavigationBarHeight),
                                collectionViewLayout: collectionViewLayout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsetsMake(AHImagesPickerConfigImagePadding, 0, self.selectOriginImageBar.bounds.height, 0)
        self.collectionView.register(AHImagePickCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: AHImagePickCollectionViewCell.reuseIdentifier())
        self.view.insertSubview(self.collectionView, belowSubview: self.selectOriginImageBar)

        self.getImages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.albumTableView.albumGroup = self.allAlbums
    }

    fileprivate func showWarning(withText text: String) {
        let alertController = UIAlertController(title: nil, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: AHImagesPickerConfig.StringAlertFine, style: UIAlertActionStyle.default, handler: { (action) in
        })
        )
        self.present(alertController, animated: true, completion: nil)
    }

    func imageBrowserDismiss(_ imageBrowser: AHImagesBrowser) {
        self.updateVisibleCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK -- Select index manager

extension AHImagesPicker {

    fileprivate func selectIndex(_ index: Int) -> Int {

        let asset = self.allAlbums[self.currentIndex].imagesAsset![index]

        for i in 0 ..< self.selectResults.count {
            if self.selectResults[i].0 == asset.localIdentifier {
                return i
            }
        }
        return -1
    }

    fileprivate func isSelectMultiSelectMode() -> Bool {
        return self.selectImageMode == .Multiple
    }
}


// MARK -- Update UI

extension AHImagesPicker {

    fileprivate func updateSelectImageCountToNavigationBar(count: Int) {

        if self.isSelectMultiSelectMode() {
            self.navigationBarView?.setRightBarItemEnable(count > 0)
        }
    }

    fileprivate func updateSelectViewStatus(selectButton: UIImageView, isSelected: Bool, index: Int = 0) {

        if isSelected {
            if self.isSelectMultiSelectMode() {
                let imageName = "image_selected_\(index + 1)"
                selectButton.image = UIImage(named: imageName)
            } else {
                selectButton.image = AHImagesPickerConfig.ImageSelected
            }
        } else {
            selectButton.image = AHImagesPickerConfig.ImageUnSelected
        }
    }

    fileprivate func updateVisibleCells() {

        let cells = self.collectionView.visibleCells
        cells.forEach { (cell) -> () in
            let imagePickCell = cell as! AHImagePickCollectionViewCell
            if imagePickCell.isSelectedImage() {
                if let indexPath = self.collectionView.indexPath(for: imagePickCell) {
                    let selectIndex = self.selectIndex(indexPath.item - 1)
                    if selectIndex == -1 {
                        imagePickCell.updateSelectedStatus(selected: false, isMultipleSelected: self.selectImageMode == .Multiple)
                    } else {
                        imagePickCell.updateSelectedStatus(selected: true, selectIndex: selectIndex, animation: false, isMultipleSelected: self.isSelectMultiSelectMode())
                    }
                }
            }
        }
    }
}


// MARK -- Select image action

extension AHImagesPicker {

    /**
     处理选择按钮的点击，包括cell和browser的选择按钮
     */
    fileprivate func didTapSelectBtnAction(index: Int, cell: AHImagePickCollectionViewCell? = nil, completedBlock: (() -> Void)? = nil) {

        let group = self.allAlbums[self.currentIndex]
        let asset = group.imagesAsset![index]

        let selectIndex = self.selectIndex(index)

        if selectIndex != -1 { // 当前已经选择

            for i in 0 ..< self.selectResults.count {
                if self.selectResults[i].0 == asset.localIdentifier {
                    self.selectResults.remove(at: i)
                    break
                }
            }

            if let cell = cell {
                cell.updateSelectedStatus(selected: false, isMultipleSelected: self.isSelectMultiSelectMode())
                self.updateVisibleCells()
            } else if let cell = self.collectionView.cellForItem(at: IndexPath(item: index + 1, section: 0)) as? AHImagePickCollectionViewCell {
                cell.updateSelectedStatus(selected: false, isMultipleSelected: self.isSelectMultiSelectMode())
                self.updateVisibleCells()
            }

            self.updateSelectImageCountToNavigationBar(count: self.selectResults.count)

            if selectOriginImageBar.isSelectOrigin { // 更新大小
                self.selectOriginImageBar.calculateSize()
            }
            if let _ = completedBlock {
                completedBlock!()
            }

        } else { // 当前未选

            if self.selectResults.count >= AHImagesPickerConfig.MaxCountSelectImage {
                self.showWarning(withText: AHImagesPickerConfig.StringOverLimit)
                return
            }

            let options = PHImageRequestOptions()
            options.isSynchronous = true

            self.imageManager.requestImageData(for: asset, options: options, resultHandler: { (imageData, dataUTI, orientation, info) in

                if let info = info, let isInCloudKey = info[PHImageResultIsInCloudKey] as? NSNumber, let imageData = imageData, let originImage = UIImage(data: imageData) {

                    if !isInCloudKey.boolValue { // 非iCloud存储的图片

                        // 压缩图片 220dp
                        let thumbImage = originImage.imageCompressForSize(maxSize: AHImagesPickerConfig.MaxThumbImageSize)

                        if self.isSelectMultiSelectMode() { // 多选

                            // 删除重复数据
                            for i in 0 ..< self.selectResults.count {
                                if self.selectResults[i].0 == asset.localIdentifier {
                                    self.selectResults[i].1 = thumbImage
                                    return
                                }
                            }

                            self.selectResults.append((asset.localIdentifier, thumbImage))

                            if let cell = cell {

                                cell.updateSelectedStatus(selected: true, selectIndex: self.selectResults.count - 1, isMultipleSelected: self.isSelectMultiSelectMode())

                            } else if let cell = self.collectionView.cellForItem(at: IndexPath(item: index + 1, section: 0)) as? AHImagePickCollectionViewCell {

                                cell.updateSelectedStatus(selected: true, selectIndex: self.selectResults.count - 1, isMultipleSelected: self.isSelectMultiSelectMode())

                            }

                            self.updateSelectImageCountToNavigationBar(count: self.selectResults.count)

                            if self.selectOriginImageBar.isSelectOrigin { // 更新大小
                                self.selectOriginImageBar.calculateSize()
                            }
                            if let _ = completedBlock {
                                completedBlock!()
                            }

                        } else { // 单选

                            if let cell = cell {

                                cell.updateSelectedStatus(selected: true, selectIndex: 1, isMultipleSelected: self.isSelectMultiSelectMode())

                            } else if let cell = self.collectionView.cellForItem(at: IndexPath(item: index + 1, section: 0)) as? AHImagePickCollectionViewCell {

                                cell.updateSelectedStatus(selected: true, selectIndex: 1, isMultipleSelected: self.isSelectMultiSelectMode())

                            }

                            self.updateSelectImageCountToNavigationBar(count: 1)
                            self.selectResults = [(asset.localIdentifier, thumbImage)]
                            self.updateVisibleCells()

                            if self.selectOriginImageBar.isSelectOrigin { // 更新大小
                                self.selectOriginImageBar.calculateSize()
                            }
                            if let _ = completedBlock {
                                completedBlock!()
                            }
                        }

                        return
                    }
                }

                // iCloud未同步
                self.showWarning(withText: AHImagesPickerConfig.StringImageNotSyncFromiCloud)

                if let _ = completedBlock {
                    completedBlock!()
                }
            })
        }
    }

    func browserSelectButtonAction(tap: UITapGestureRecognizer) {

        let selectButton = tap.view as! UIImageView

        self.didTapSelectBtnAction(index: selectButton.tag) {

            let isSelected = self.selectIndex(selectButton.tag) != -1 // 是否已经选择

            if isSelected { // 选择成功
                self.updateSelectViewStatus(selectButton: selectButton, isSelected: true, index: self.selectResults.count - 1)
            } else {
                self.updateSelectViewStatus(selectButton: selectButton, isSelected: false)
                self.updateVisibleCells()
            }
        }
    }
}


// MARK -- Images Helper

extension AHImagesPicker {

    fileprivate func getImages() {

        // 过滤规则
        let fetchImageOptions = PHFetchOptions()
        fetchImageOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchImageOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)

        // 所有图片
        let results = PHAsset.fetchAssets(with: fetchImageOptions)

        var allPhAssets = [PHAsset]()
        for i in 0 ..< results.count {
            allPhAssets.append(results[i] )
        }
        let allImageItem = AHImagesPickGroup()
        allImageItem.albumIconAsset = allPhAssets.first
        allImageItem.albumName = AHImagesPickerConfig.StringAllPhotos
        allImageItem.imagesAsset = allPhAssets
        self.allAlbums.append(allImageItem)

        // 所有相册
        let albums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)

        for i in 0 ..< albums.count {

            // 相册
            let collection = albums.object(at: i)

            var phAssets = [PHAsset]()

            // 获取相册图片
            let result = PHAsset.fetchAssets(in: collection, options: fetchImageOptions)

            // 遍历图片
            result.enumerateObjects({ (asset, index, stop) -> Void in
                phAssets.append(asset )
            })

            if phAssets.count > 0 { // 过滤空相册
                // 保存相册信息
                let album = AHImagesPickGroup()
                album.albumName = collection.localizedTitle
                album.albumIconAsset = phAssets.first
                album.imagesAsset = phAssets
                self.allAlbums.append(album)
            }
        }
    }

    /**
     获取拍照的图片信息
     */
    fileprivate func pickCameraImageFromAllPhotoAlbumPHAsset() -> PHAsset {

        // 过滤规则
        let fetchImageOptions = PHFetchOptions()
        fetchImageOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchImageOptions.predicate = NSPredicate(format: "mediaType = %i", PHAssetMediaType.image.rawValue)

        // 所有图片
        let results = PHAsset.fetchAssets(with: fetchImageOptions)
        let cameraPhAsset = results.firstObject!
        return cameraPhAsset
    }
}


// MARK -- AHSelectOriginImageBarDelegate

extension AHImagesPicker: AHSelectOriginImageBarDelegate {
    
    func loadSelectOriginImagesPhAssetIdentifiers() -> [String] {
        var phAssetIdentifiers = [String]()
        self.selectResults.forEach { (identifier, _) in
            phAssetIdentifiers.append(identifier)
        }
        return phAssetIdentifiers
    }
}


// MARK -- AHImagesPickerNavigationBarDelegate

extension AHImagesPicker: AHImagesPickerNavigationBarDelegate {

    func ahImagesPickerNavigationBarTapTitleAction() {

        if let _ = self.albumTableView.superview {
            self.albumTableView.dismiss()
            self.navigationBarView.updateTriangleDown(true)
        } else {
            self.albumTableView.presentInView(self.view)
            self.navigationBarView.updateTriangleDown(false)
        }
    }
}


// MARK -- AHAlbumTableViewDelegate

extension AHImagesPicker: AHAlbumTableViewDelegate {
    
    func albumTableViewSelect(index: Int) {
        self.currentIndex = index
        self.navigationBarView.titleLabel.text = self.allAlbums[index].albumName
        self.navigationBarView.updateTriangleDown(true)
        self.collectionView.reloadData()
    }

    func albumTableViewDismiss() {
        self.navigationBarView.updateTriangleDown(true)
    }
}


// MARK -- UICollectionViewDelegate, UICollectionViewDataSource

extension AHImagesPicker: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, AHImagesPickerConfigScreenPadding, 0, AHImagesPickerConfigScreenPadding)
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        return CGSize(width: kSizeImageCollectionCellWidth, height: kSizeImageCollectionCellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.allAlbums.count > self.currentIndex {
            if let assets = self.allAlbums[self.currentIndex].imagesAsset {
                return assets.count + 1
            } else {
                return 1
            }
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AHImagePickCollectionViewCell.reuseIdentifier(), for: indexPath as IndexPath) as? AHImagePickCollectionViewCell {

            if indexPath.item == 0 {
                cell.config(image: nil, isSelected: false, showSelectBtn: false, isMultipleSelected: self.isSelectMultiSelectMode())
            } else {

                if let assets = self.allAlbums[self.currentIndex].imagesAsset {
                    let asset = assets[indexPath.item - 1]

                    // 获取图片
                    imageManager.requestImage(for: asset, targetSize: CGSize(width: kSizeImageCollectionCellWidth, height: kSizeImageCollectionCellWidth), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, data) in

                        if let image = image {
                            let selectIndex = self.selectIndex(indexPath.item - 1)
                            cell.config(image: image, isSelected: selectIndex != -1, selectIndex: selectIndex, isMultipleSelected: self.isSelectMultiSelectMode())
                        } else {
                            cell.config(image: nil, isSelected: false, isMultipleSelected: self.isSelectMultiSelectMode())
                        }
                    })
                } else {
                    cell.config(image: nil, isSelected: false, isMultipleSelected: self.isSelectMultiSelectMode())
                }
            }
            cell.delegate = self
            return cell
        }

        return UICollectionViewCell()
    }
}


// MARK -- AHImagePickCollectionViewCellDelegate

extension AHImagesPicker: AHImagePickCollectionViewCellDelegate {

    /**
     点击cell的空白区域，浏览大图
     */
    func didTapBrowseImageWithImagePickCollectionViewCell(_ cell: AHImagePickCollectionViewCell!) {

        if let indexPath = self.collectionView.indexPath(for: cell) {
            if indexPath.item > 0 {

                let browser = AHImagesBrowser()
                browser.navigationBarView.setRightBarItemTitle(AHImagesPickerConfig.StringCompleted)
                browser.allImagesCount = self.allAlbums[self.currentIndex].imagesAsset!.count
                browser.delegate = self
                browser.currentIndex = indexPath.item - 1
                browser.showInParentView(self.view)

            } else {

                // 拍照
                if self.selectResults.count >= AHImagesPickerConfig.MaxCountSelectImage {
                    self.showWarning(withText: AHImagesPickerConfig.StringOverLimit)
                    return
                }

                let imagePicker = UIImagePickerController()
                imagePicker.modalPresentationStyle = UIModalPresentationStyle.currentContext
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }

    /**
     点击cell的选择按钮
     */
    func didTapSelectBtnWidthImagePickCollectionViewCell(_ cell: AHImagePickCollectionViewCell!) {

        if let indexPath = self.collectionView.indexPath(for: cell) {

            if indexPath.item > 0 {
                self.didTapSelectBtnAction(index: indexPath.item - 1, cell: cell)
            }
        }
    }
}


// MARK -- AHImagesBrowserDelegate

extension AHImagesPicker: AHImagesBrowserDelegate {

    func imageBrowser(_ imageBrowser: AHImagesBrowser, initCustomViewByIndex index: Int) -> UIView! {

        let selectIndex = self.selectIndex(index)

        let selectButton = UIImageView()
        selectButton.isUserInteractionEnabled = true
        selectButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.browserSelectButtonAction(tap:))))
        if selectIndex != -1 {
            self.updateSelectViewStatus(selectButton: selectButton, isSelected: true, index: selectIndex)
        } else {
            self.updateSelectViewStatus(selectButton: selectButton, isSelected: false)
        }
        selectButton.tag = index
        imageBrowser.addSubview(selectButton)

        selectButton.translatesAutoresizingMaskIntoConstraints = false

        imageBrowser => selectButton.right == imageBrowser.right - 12
        imageBrowser => selectButton.top == imageBrowser.top + (AHImagesPickerConfigNavigationBarHeight + 12)

        return selectButton
    }

    func imageBrowser(_ imageBrowser: AHImagesBrowser, configCustomView: UIView?, byIndex index: Int) {

        if let selectButton = configCustomView as? UIImageView {
            selectButton.tag = index
            let selectIndex = self.selectIndex(index)
            if selectIndex != -1 {
                self.updateSelectViewStatus(selectButton: selectButton, isSelected: true, index: selectIndex)
            } else {
                self.updateSelectViewStatus(selectButton: selectButton, isSelected: false)
            }
        }
    }

    func imageBrowser(_ imageBrowser: AHImagesBrowser, loadImageByIndex index: Int, imageViewer: AHImageViewer!) {

        let group = self.allAlbums[self.currentIndex]
        let asset = group.imagesAsset![index]

        let options = PHImageRequestOptions()
        options.isSynchronous = true

        self.imageManager.requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in

            if let info = info, let isInCloudKey = info[PHImageResultIsInCloudKey] as? NSNumber {
                if !isInCloudKey.boolValue { // 非iCloud存储，获取原图

                    self.imageManager.requestImage(for: asset, targetSize: CGSize(width: AHImagesPickerConfigScreenWidth, height: AHImagesPickerConfigScreenHeight), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, data) in

                        if let image = image, let info = data, let isDegrade = info[PHImageResultIsDegradedKey] as? NSNumber {
                            if !isDegrade.boolValue { // 显示原图
                                imageViewer.update(image: image)
                            }
                        }
                    })

                } else {

                    self.imageManager.requestImage(for: asset, targetSize: CGSize(width: kSizeImageCollectionCellWidth, height: kSizeImageCollectionCellWidth), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, data) in // 获取缩略图

                        if let image = image, let info = data, let isDegrade = info[PHImageResultIsDegradedKey] as? NSNumber {

                            if isDegrade.boolValue { // 获取缩略图
                                imageViewer.update(image: image)
                            }
                        }
                    })
                }
            }
        }

        //        let results = PHAsset.fetchAssetsWithLocalIdentifiers([asset.localIdentifier], options: nil)
        //
        //        let options = PHImageRequestOptions()
        //        options.synchronous = false
        //
        //        results.enumerateObjectsUsingBlock { (asset, idx, stop) in
        //            PHCachingImageManager().requestImageDataForAsset(asset as! PHAsset, options: options, resultHandler: { (imageData: NSData?, dataUTI, orientation, info: [NSObject : AnyObject]?) in
        //
        //                if let data = imageData {
        //                    if let image = YYImage(data: data) {
        //                        imageViewer.update(image)
        //                    }
        //                }
        //            })
        //        }
    }
}

// MARK -- UIImagePickerControllerDelegate

extension AHImagesPicker: UIImagePickerControllerDelegate {

    /**
     选择图片结束
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            if let collection = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil).firstObject {

                PHPhotoLibrary.shared().performChanges({

                    // 存储照片
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: chosenImage)

                    if let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset {

                        let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection)
                        let enumeration: NSArray = [assetPlaceholder]
                        albumChangeRequest?.addAssets(enumeration)
                    }

                }, completionHandler: { (success, error) in

                    if success {

                        // 获取拍照存储后的图片信息
                        let cameraPhAsset = self.pickCameraImageFromAllPhotoAlbumPHAsset()

                        // 获取缩略图
                        self.imageManager.requestImage(for: cameraPhAsset, targetSize: CGSize(width: kSizeImageCollectionCellWidth, height: kSizeImageCollectionCellWidth), contentMode: PHImageContentMode.aspectFill, options: nil, resultHandler: { (image, data) in // 获取缩略图

                            if let image = image, let info = data, let isDegrade = info[PHImageResultIsDegradedKey] as? NSNumber {

                                if !isDegrade.boolValue { // 获取原图

                                    if !self.isSelectMultiSelectMode() {
                                        self.selectResults.removeAll()
                                    }
                                    self.selectResults.append(cameraPhAsset.localIdentifier, image)

                                    self.delegate?.ahImagesPicker(viewController: self, selectResult: self.selectResults, isOrigin: self.selectOriginImageBar.isSelectOrigin)

                                    picker.dismiss(animated: false, completion: nil)
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        })
                    }
                })
            }
        }
    }
}


// MARK -- AHNavigationBarDelegate

extension AHImagesPicker: AHNavigationBarDelegate {
    
    // MARK -- AHNavigationBarDelegate

    func navigationBarPopAction() {
        self.dismiss(animated: true, completion: nil)
    }

    func navigationBarPushAction() {
        self.delegate?.ahImagesPicker(viewController: self, selectResult: self.selectResults, isOrigin: self.selectOriginImageBar.isSelectOrigin)
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK -- UINavigationControllerDelegate

extension AHImagesPicker: UINavigationControllerDelegate {

    /**
     取消拍照
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    
    func imageCompressForSize(maxSize: CGFloat) -> UIImage {

        let imageSize = self.size
        let width = imageSize.width * self.scale
        let height = imageSize.height * self.scale

        var targetWidth = imageSize.width
        var targetHeight = imageSize.height

        if targetWidth > maxSize || targetHeight > maxSize {

            if targetWidth > targetHeight {
                targetWidth = maxSize
                targetHeight = targetWidth * height / width
            } else {
                targetHeight = maxSize
                targetWidth = targetHeight * width / height
            }

            UIGraphicsBeginImageContext(CGSize(width: targetWidth, height: targetHeight))

            let rect = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if let newImage = newImage {
                return newImage
            }
        }
        return self
    }
}
