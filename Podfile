# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

target 'SectionRepeater' do
  use_frameworks!
  
  pod 'Swinject', '~> 2.0'
  pod 'SnapKit', '~> 3.1.2' 
  pod 'RealmSwift', '~> 2.8'
  pod 'Then', '~> 2.1'
  pod 'URLNavigator', '~> 1.2'
  pod 'SwiftyImage', '~> 1.1'  
  pod 'pop', '~> 1.0'

  # Report
  pod 'Firebase/Core'
  pod 'Fabric'
  pod 'Crashlytics'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
