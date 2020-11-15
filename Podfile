# Uncomment this line to define a global platform for your project
platform :ios, '14.0'
use_frameworks!
# ignore all warnings from all pods
inhibit_all_warnings!

target 'Repeatit' do
    # UI
    pod 'SnapKit', '~> 5.0.0'
    pod 'PinLayout', '~> 1.9.2'
    pod 'youtube-ios-player-helper', '~> 1.0.2'
    pod 'SwiftEntryKit', '~> 1.2.6'

    # Rx
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'

    # Report
    pod 'Firebase/Analytics'
    pod 'FirebaseCrashlytics'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['VALID_ARCHS'] = '$(VALID_ARCHS)'
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end
end
