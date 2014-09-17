#
# Be sure to run `pod lib lint CloudIt.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CloudIt"
  s.version          = "0.1.0"
  s.summary          = "311Labs CloudIT IOS SDK"
  s.description      = <<-DESC
      311Labs IOS SDK for rapid Cloud development
                       DESC
  s.homepage         = "https://github.com/istarnes/cloudit-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "istarnes" => "ian@starnes.us" }
  s.source           = { :git => "https://github.com/istarnes/cloudit-ios.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/311labs'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.public_header_files = 'CloudIt/*.h'

  s.source_files = 'CloudIt', 'CloudIt/Helpers', 'CloudIt/Models', 'CloudIt/Social'
  # s.resources = 'Pod/Assets/*.png'

  s.public_header_files = 'CloudIt/*.h', 'CloudIt/Helpers/*.h', 'CloudIt/Models/*.h', 'CloudIt/Social/*.h'
  s.ios.frameworks = 'MobileCoreServices', 'CoreGraphics', 'Security'
  s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Facebook-iOS-SDK', '~> 3.18'
  s.dependency 'googleplus-ios-sdk', '~> 1.7.1'
  s.dependency 'SSZipArchive', '~> 0.3'
end
