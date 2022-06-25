#
# Be sure to run `pod lib lint dragSort.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'dragSort'
  s.version          = '0.1.0'
  s.summary          = '推动排序'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
UICollectionView 拖动排序
                       DESC

  s.homepage         = 'https://github.com/vsguji/dragSort.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lipeng' => '1162423147@qq.com' }
  s.source           = { :git => 'https://github.com/vsguji/dragSort.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.jianshu.com/u/40ea8f672608'

  s.ios.deployment_target = '10.0'

  s.source_files = 'dragSort/Classes/*.swift'
  
#   s.resource_bundles = {
#     'dragSort' => ['dragSort/Assets/*.png']
#   }
  s.swift_version = '5.0'
  # s.public_header_files = 'Pod/Classes/*.swift'
   s.frameworks = 'UIKit','Foundation'
   s.dependency 'Reusable'
   s.dependency 'SnapKit'
end
