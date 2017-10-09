Pod::Spec.new do |s|
  s.name         = "MixKit"
  s.version      = "1.0.0"
  s.summary      = "MixKit"
  s.homepage     = "https://github.com/maxseyLau/Mix"
  s.license      = { :type => 'MIT', :file => '../../LICENSE' }
  s.author       = "Maxwell Lau"
  s.source       = { :git => "https://github.com/maxseyLau/Mix.git", :tag => s.version.to_s }
  s.dependency "RxSwift"
  s.dependency "RealmSwift"
  s.framework = ["UIKit", "Foundation"]
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.source_files = 'MixKit/**/*.{swift,h,m}'
end
