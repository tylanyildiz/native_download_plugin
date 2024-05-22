#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_download_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_download_plugin'
  s.version          = '0.1.3'
  s.summary          = 'Flutter Native Download Plugin Project'
  s.description      = <<-DESC
Download File by Native
                       DESC
  s.homepage         = 'https://github.com/tylanyildiz/native_download_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'CSI' => 'tyildiz@csicxt.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
