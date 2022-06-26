//
//  GetResourcePng.swift
//  dragSort
//
//  Created by 李朋 on 2022/6/26.
//

import Foundation

// podspec配置resource_bundles、resources不同
// resource_bundles 会包裹多一层
// resources 不会
class GetResourcePng {
    
    // MARK: -  成功
//    s.resource_bundles = {
//      'dragSort' => ['dragSort/Resources/*.png']
//    }
 static func getByResourceBuidleWithName(name:String) -> UIImage? {
        // 获取当前所在Bundle
      let bundle = Bundle(for: self)
        let dic = bundle.infoDictionary ?? ["":""]
        // 获取bundle名
        let bundleName =  dic["CFBundleExecutable"] as! String
        // 屏幕比例
        let scale = UIScreen.main.scale
        // 拼接图片名称
        let imageName = String(format: "%@@%dx", name,Int(scale))
       let bundleImagePath = String(format: "%@.bundle", bundleName)
        // 路径
        let bundlePath = Bundle(for: self).resourcePath?.appendingFormat("/%@", bundleImagePath) ?? ""
        let resourceBundle = Bundle.init(path: bundlePath) //由路径创建bundle失败
//     (NSBundle?) resourceBundle = 0x000060000151df90 {
//       baseNSObject@0 = {
//         isa = NSBundle
//       }
//       _flags = 131080
//       _attributedStringTable = 0x0000000000000000
//       _principalClass = 0x0000000000000000
//       _initialPath = 0x000060000386cea0 "/Users/lipeng/Library/Developer/CoreSimulator/Devices/E30A8D60-3DC8-4548-A4EB-5BF387802BFB/data/Containers/Bundle/Application/417DA6F0-C047-4A1A-8E6B-61139F742A19/dragSort_Example.app/Frameworks/dragSort.framework/dragSort.bundle"
//       _resolvedPath = 0x00007fa223f04a30 "/Users/lipeng/Library/Developer/CoreSimulator/Devices/E30A8D60-3DC8-4548-A4EB-5BF387802BFB/data/Containers/Bundle/Application/417DA6F0-C047-4A1A-8E6B-61139F742A19/dragSort_Example.app/Frameworks/dragSort.framework/dragSort.bundle"
//       _firstClassName = 0x0000000000000000
//     }
        let image  = UIImage(named: imageName, in: resourceBundle,compatibleWith: nil)
        return image
    }
    
    // MARK: - 成功
   //  # s.resources = 'dragSort/Resources/*.png'
    static func getBundleByResourcesWithName(name:String) -> UIImage? {
           // 获取当前所在Bundle
         let bundle = Bundle(for: self)
//        NSBundle </Users/lipeng/Library/Developer/CoreSimulator/Devices/E30A8D60-3DC8-4548-A4EB-5BF387802BFB/data/Containers/Bundle/Application/71ECFF24-011F-4130-8F13-FD22CC2386E7/dragSort_Example.app/Frameworks/dragSort.framework> (loaded)
           // 屏幕比例
           let scale = UIScreen.main.scale
           // 拼接图片名称
           let imageName = String(format: "%@@%dx", name,Int(scale))
           let image  = UIImage(named: imageName, in: bundle,compatibleWith: nil)
           return image
       }
    
}
