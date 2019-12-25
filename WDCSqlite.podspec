#
# Be sure to run `pod lib lint WDCSqlite.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WDCSqlite'
  s.version          = '0.2.0'
  s.summary          = '轻量级ORM框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC  delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
轻量级ORM框架。支持向数据库中插入模型，查询模型，删除模型。支持自动建表，自动更新表结构，旧数据迁移。
                       DESC

  s.homepage         = 'https://github.com/WDCloudEdu/WDCSqlite'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiongwei' => 'xiongwei@wdcloud.cc' }
  s.source           = { :git => 'https://github.com/WDCloudEdu/WDCSqlite.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'WDCSqlite/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WDCSqlite' => ['WDCSqlite/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
