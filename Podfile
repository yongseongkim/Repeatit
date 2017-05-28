# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'SectionRepeater' do
  use_frameworks!
  pod 'Alamofire', '~> 4.4'
  pod 'Swinject', '~> 2.0'

  pod 'SnapKit', '~> 3.1.2'
  pod 'AudioKit', '~> 3.5'
  pod 'RealmSwift', '~> 2.4'
  pod 'Then', '~> 2.1'
  pod 'URLNavigator', '~> 1.2'
  
  # Reactive
  pod 'RxSwift',    '~> 3.0'
  pod 'RxCocoa',    '~> 3.0'
  pod 'RxDataSources', '~> 1.0'
  pod "RxGesture"
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
