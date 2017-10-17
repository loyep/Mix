# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'Mix' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    inhibit_all_warnings!
    
    # Pods for Mix
    pod 'SnapKit'
    pod 'Alamofire'
    pod 'RealmSwift'

    pod 'SwiftyJSON'
    pod 'YYKit'
    pod 'SwiftTheme'
    pod 'RxSwift',  '~> 4.0.0-rc.0'
    pod 'RxCocoa',  '~> 4.0.0-rc.0'

    # Privarte podspec
    pod 'WeiboSDK',         :path => './Source/WeiboSDK'
    pod 'SwiftyWeibo',      :path => './Source/SwiftyWeibo'
    pod 'MixKit',           :path => './Source/MixKit'
    
    target 'MixTests' do
        inherit! :search_paths
        # Pods for testing
#        pod 'Quick'
        
    end
    
end

target 'MixShare' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    inhibit_all_warnings!

    # Pods for MixShare

end

