# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'SectionRepeater' do
  use_frameworks!
  pod 'Swinject', '~> 2.0'
  pod 'Alamofire', '~> 4.3'
  pod 'SnapKit', '~> 3.1.2'
  pod 'AudioKit', '~> 3.5'
  pod 'RealmSwift', '~> 2.4'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
