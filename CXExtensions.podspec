Pod::Spec.new do |s|

    s.name         = "CXExtensions"
    s.version      = "0.0.1-beta.3"
    s.summary      = "A collection of useful extensions for Combine and CombineX."
    s.homepage     = "https://github.com/cx-org/CXExtensions"
    s.license      = { :type => "MIT", :file => "LICENSE" }
    s.author       = { "Quentin Jin" => "luoxiustm@gmail.com" }

    s.swift_versions              = ['5.0']
    s.osx.deployment_target       = "10.10"
    s.ios.deployment_target       = "8.0"
    s.tvos.deployment_target      = "9.0"
    s.watchos.deployment_target   = "2.0"

    s.source = { :git => "https://github.com/cx-org/CXExtensions.git", :tag => "#{s.version}" }
    s.source_files = "Sources/CXExtensions/**/*.swift"

    s.dependency 'CXFoundation', '~> 0.0.1-beta.3'
    s.dependency 'CXCompatible', '~> 0.0.1-beta.2'
  
end
  
