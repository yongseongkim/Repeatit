# Uncomment this line to define a global platform for your project
platform :ios, '13.0'

target 'Repeatit' do
  use_frameworks!

  pod 'youtube-ios-player-helper'
  # Report
  pod 'Firebase/Analytics'
  pod 'Fabric'
  pod 'Crashlytics'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['VALID_ARCHS'] = '$(VALID_ARCHS)'
  end
end

