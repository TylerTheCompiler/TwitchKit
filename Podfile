target 'TwitchKit-iOS' do
  platform :ios, '12.0'
  use_frameworks!
  inhibit_all_warnings!
  pod 'SwiftLint'
end

target 'TwitchKit-macOS' do
  platform :macos, '10.15'
  use_frameworks!
  inhibit_all_warnings!
  pod 'SwiftLint'
end

target 'TwitchKitTester-iOS' do
  platform :ios, '12.0'
  use_frameworks!
  inhibit_all_warnings!
  pod 'SwiftLint'
end

target 'TwitchKitTester-macOS' do
  platform :macos, '10.15'
  use_frameworks!
  inhibit_all_warnings!
  pod 'SwiftLint'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.name.end_with?('-macOS')
        config.build_settings.delete('ARCHS')
      else
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
