# Uncomment this line to define a global platform for your project
platform :ios, '9.0'

# Uncomment this line if you're using Swift
# use_frameworks!
inhibit_all_warnings!

# Import CocoaPods sources
source 'https://github.com/CocoaPods/Specs.git'

target 'ChatDemo-UI3.0' do
  
#    pod 'Hyphenate'

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

    pod 'MWPhotoBrowser', '~> 2.1.2'
    pod 'MJRefresh'
    pod 'Masonry'
    pod 'WHToast'
#    pod 'AgoraChat'

end





