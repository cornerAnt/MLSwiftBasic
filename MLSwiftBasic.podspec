Pod::Spec.new do |s|
  s.name             = "MLSwiftBasic"
  s.version          = "0.1.0"
  s.summary          = "UI and animation of the basic framework of swift!"
  s.homepage         = "https://github.com/MakeZL/MLSwiftBasic"
  s.license          = 'MIT'
  s.author           = { "MakeZL" => "ios.makezl@gmail.com" }
  s.source           = { :git => "https://github.com/MakeZL/MLSwiftBasic.git", :tag => s.version.to_s }

  s.platform         = :ios, '6.0'
  s.requires_arc     = true

  s.frameworks       = 'AssetsLibrary'
  s.source_files     = 'Classes/**/*'
  s.resource         = "Classes/Refresh/ZLSwifthRefresh/ZLSwifthRefresh.bundle"

end
