require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "YaloChatReactNativeSdk"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/yalochat/chat-sdk.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.private_header_files = "ios/**/*.h"
  s.swift_version = "5.9"

  # YALO_CHAT_IOS_SDK_PATH points at a local checkout of this repository,
  # which the example app uses to build against the ios-sdk next to it.
  spm_dependency(s,
    url: ENV["YALO_CHAT_IOS_SDK_PATH"] || "https://github.com/yalochat/chat-sdk.git",
    requirement: { kind: "upToNextMinorVersion", minimumVersion: "0.5.1" },
    products: ["YaloChatSDK"]
  )

  install_modules_dependencies(s)
end
