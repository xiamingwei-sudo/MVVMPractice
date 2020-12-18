#
# Be sure to run `pod lib lint CUGatewaySDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CUGatewaySDK'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CUGatewaySDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/xiamingwei-sudo/CUGatewaySDK-Swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Come-Mile' => 'xiamwei@hotmail.com' }
  s.source           = { :git => 'https://github.com/xiamingwei-sudo/CUGatewaySDK-Swift', :tag => "0.1.0" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CUGatewaySDK/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CUGatewaySDK' => ['CUGatewaySDK/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/CUGatewaySDK.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Dollar'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'RHSocketKit/RPC', '2.2.4'
  s.dependency 'SwiftyJSON', '~> 4.0'
  s.dependency 'XCGLogger', '~> 7.0.0'
end
