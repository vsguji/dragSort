# dragSort

[![CI Status](https://img.shields.io/travis/1720177/dragSort.svg?style=flat)](https://travis-ci.org/1720177/dragSort)
[![Version](https://img.shields.io/cocoapods/v/dragSort.svg?style=flat)](https://cocoapods.org/pods/dragSort)
[![License](https://img.shields.io/cocoapods/l/dragSort.svg?style=flat)](https://cocoapods.org/pods/dragSort)
[![Platform](https://img.shields.io/cocoapods/p/dragSort.svg?style=flat)](https://cocoapods.org/pods/dragSort)

<video width="320" height="240" controls>
    <source src="dragSort.mp4" type="video/mp4">
    您的浏览器不支持 video 标签。
</video>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

dragSort is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'dragSort'
```

## Author

1720177, 1162423147@qq.com

## License

dragSort is available under the MIT license. See the LICENSE file for more info.


项目中导入私有库之后，报错如下：
Cannot find 'XXX' in scope
解决：
Swift的私有库文件，类、属性和方法前面用open修饰，init方法前面用public修饰，然后重新上传私有库，打新tag标签，BaseLibiOS.podspec文件的tag也要修改，请参考目录2-6和3、4、5、6，并把tag推送到远端


https://blog.csdn.net/Riven_wn/article/details/78751528


open：可以在任何地方被访问、继承、重写。

public：可以在任何地方被访问，在其他模块中不能被继承和重写。

internal：在整个模块内都可以被访问。

fileprivate：其修饰的属性可以再同一个文件被访问、继承和重写，同一个文件指同一个swift文件，一个文件中可以有多个类。

private：其修饰的属性和方法只能在本类被访问和使用。


# 单列

# 双列

# 自定义扩展

# 数据类型



# 问题  NSItemProviderWriting
<!--        let item = self.items[indexPath.section][indexPath.row]-->
<!--        let itemProvider = NSItemProvider(object: item as! NSItemProviderWriting)-->
<!--        let dragItem = UIDragItem(itemProvider: itemProvider)-->
<!--        dragItem.localObject = item-->

// NSObject 需完成NSItemProviderWriting协议
// 本实例 “let item = self.items[indexPath.section][indexPath.row]”,item 为字符串
