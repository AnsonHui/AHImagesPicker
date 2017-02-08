## AHImagePicker

多图选择相册图片以及拍照

## Usage

```swift

var selectResults = [(String, UIImage)]()

let imagesPicker = AHImagesPicker(selectResult: self.selectResults, selectImageMode: AHImagesPickerMode.Multiple)
imagesPicker.delegate = self
self.present(imagesPicker, animated: true, completion: nil)


// MARK -- AHImagesPickerDelegate

func ahImagesPicker(viewController: AHImagesPicker!, selectResult: [(String, UIImage)]!, isOrigin: Bool) {
    self.selectResults = selectResult
}

```

## CocoaPods

CocoaPods is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate AHImagePicker into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'AHImagePicker', :git => 'https://github.com/AnsonHui/AHImagesPicker.git'
```

Then, run the following command:

```bash
$ pod install
```
