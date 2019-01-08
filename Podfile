source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
inhibit_all_warnings!

target 'HyperKeySDK' do
    pod 'AFNetworking'
    pod 'Masonry'
    pod 'SDWebImage', '~> 3.8'
    pod 'FLAnimatedImage', '~> 1.0'
    pod 'OAuthConsumer', '~> 1.0.3'
    pod 'ObjectiveDropboxOfficial'
    pod 'MBProgressHUD', '~> 1.0.0'
    pod 'YelpAPI'
    pod 'AWSS3', '~> 2.4.3'
end

# workaround for error: 'sharedApplication' is unavailable: not available on iOS (App Extension)
post_install do |installer|
    installer.pods_project.targets.each do |target|
        case target.name
            when 'GTMSessionFetcher', 'Branch', 'OAuthConsumer', 'Bolts', 'FBSDKCoreKit'
            target.build_configurations.each do |config|
                config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
                puts "* #{target.name}: set APPLICATION_EXTENSION_API_ONLY to NO"
            end
        end
    end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
