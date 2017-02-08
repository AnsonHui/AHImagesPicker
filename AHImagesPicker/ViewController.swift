//
//  ViewController.swift
//  AHImagesPicker
//
//  Created by 黄辉 on 8/30/16.
//  Copyright © 2016 Fantasy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AHImagesPickerDelegate {

    // 添加图片按钮
    private var editImagesView: AHMultipleImageEditView!

    // 选择的图片 localIdentifier image
    private var selectResults = [(String, UIImage)]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.backgroundColor = UIColor.gray

        let button = UIButton()
        button.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        button.backgroundColor = UIColor.red
        button.setTitle("选图", for: UIControlState.normal)
        button.addTarget(self, action: #selector(self.imagesPickerAction), for: UIControlEvents.touchUpInside)
        self.view.addSubview(button)

        // 添加图片
        self.editImagesView = AHMultipleImageEditView(frame: CGRect(x: 12, y: button.frame.maxY + 9,
                                                                    width: UIScreen.main.bounds.size.width - 24, height: 0))
        self.view.addSubview(self.editImagesView)

        // 隐藏添加图片按钮
        self.editImagesView.isHidden = true
    }

    func imagesPickerAction() {
        let imagesPicker = AHImagesPicker(selectResult: self.selectResults, selectImageMode: AHImagesPickerMode.Multiple)
        imagesPicker.delegate = self
        self.present(imagesPicker, animated: true, completion: nil)
    }

    // MARK -- AHImagesPickerDelegate

    func ahImagesPicker(viewController: AHImagesPicker!, selectResult: [(String, UIImage)]!, isOrigin: Bool) {

        self.selectResults = selectResult
        self.editImagesView.isHidden = selectResult.count <= 0
        self.editImagesView.images = self.selectResults
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

