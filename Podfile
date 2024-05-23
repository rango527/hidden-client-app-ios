# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'Hidden Client' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hidden Client

    inhibit_all_warnings!
    
    pod 'AlamofireObjectMapper'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'RxDataSources'
    pod 'RealmSwift', '~> 3.18.0'
    pod 'Hero'
    pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
    pod 'IQKeyboardManagerSwift'
    pod 'PKHUD'
    pod 'Kingfisher'
    pod 'BonMot'
    pod 'RSKPlaceholderTextView', '~> 5.0.2'
    pod 'UrbanAirship-iOS-SDK'
    pod 'RxDocumentPicker'
    pod 'CCBottomRefreshControl'
    pod 'SwiftyGif'
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == 'SwiftyGif'
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '4.2'
                end
            end
        end
    end

  target 'Hidden ClientTests' do
    inherit! :search_paths
  end

end
