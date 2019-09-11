# CXExtensions

[![release](https://img.shields.io/github/release-pre/cx-org/CXExtensions)](https://github.com/cx-org/CXExtensions/releases)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![license](https://img.shields.io/github/license/cx-org/CXExtensions?color=black)
[![dicord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/cresT3X)

A collection of useful extensions for [Combine](https://developer.apple.com/documentation/combine) and [CombineX](https://github.com/cx-org/CombineX).

## API

### Publisher

#### IgnoreError

Ignore error from upstream and complete.

```swift
// Output: (data: Data, response: URLResponse), Failure: URLError
let upstream = URLSession.shared.cx.dataTaskPublisher(for: url)

// Output: (data: Data, response: URLResponse), Failure: Never
let pub = upstream.ignoreError()
```

### Cancellable

#### DelayedAutoCancellable

Auto cancel after delay.

```swift
let delayedCancel = upstream
    .sink { o in
    }
    .cancel(after .second(1), scheduler: mainScheduler)
```

## Install

### Swift Package Manager

```swift
dependencies.append(
    .package(url: "https://github.com/cx-org/CXExtensions", .branch("master"))
)
```

### CocoaPods

```ruby
pod 'CXExtensions', :git => 'https://github.com/cx-org/CXExtensions.git', :branch => 'master'
```

### Carthage

```carthage
github "cx-org/CXExtensions" "master"
```

## Use with Combine

You can change the underlying dependency to `Combine` by passing `USE_COMBINE` to the target's build configurations. For example, if you are using CocoaPods, you can modify your podfile like below:

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'CXExtensions'
            target.build_configurations.each do |config|
                config.build_settings['OTHER_SWIFT_FLAGS'] = '-DUSE_COMBINE'
            end
        end
    end
end
```

If you are using Carthage, you should be able to use `XCODE_XCCONFIG_FILE` to do that.
