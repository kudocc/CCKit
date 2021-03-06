Pod::Spec.new do |s|

  s.name         = "KudoCCKit"
  s.version      = "0.0.4"
  s.summary      = "My Kit for iOS."
  s.homepage     = "https://github.com/kudocc/CCKit"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "KudoCC" => "cangmuma@gmail.com" }

  s.ios.deployment_target = "7.0"

  s.source       = { :git => "https://github.com/kudocc/CCKit.git", :tag => "0.0.4" }
  s.source_files = "CCKit/*.{h,m}", "CCKit/**/*.{h,m}"

  s.requires_arc = true
end
