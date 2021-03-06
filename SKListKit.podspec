#
# Be sure to run `pod lib lint SKListKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SKListKit'
  s.version          = '0.1.4'
  s.summary          = 'SKListKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/NeverAgain11/SKListKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ljk' => 'liujk0723@foxmail.com' }
  s.source           = { :git => 'https://github.com/NeverAgain11/SKListKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.swift_version = '5'
  s.ios.deployment_target = '9.0'
  
  s.source_files = 'SKListKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SKListKit' => ['SKListKit/Assets/*.png']
  # }

  s.frameworks = 'UIKit', 'CoreFoundation'
  
  s.dependency "Texture/Core", '~> 3.0'
  s.dependency 'DifferenceKit'
  
end
