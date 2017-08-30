Pod::Spec.new do |s|
  s.name         = "SwiftyWeibo"
  s.version      = "1.0.0"
  s.summary      = "SwiftyWeibo"
  s.homepage     = "https://github.com/maxseyLau/Mix"
  s.license      = { :type => 'MIT', :file => '../../LICENSE' }
  s.author       = "Maxwell Lau"
  s.source       = { :git => "https://github.com/maxseyLau/Mix.git", :tag => s.version.to_s }
  s.dependency 'Alamofire'
  s.dependency 'Result'
  s.requires_arc = true
  s.ios.deployment_target = '9.0'
  s.source_files = '**/*.swift'
end
