# CXExtensions

![release](https://img.shields.io/github/release-pre/cx-org/CXExtensions)
![install](https://img.shields.io/badge/install-spm%20%7C%20cocoapods%20%7C%20carthage-ff69b4)
![platform](https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey)
![license](https://img.shields.io/github/license/cx-org/CXExtensions?color=black)

A collection of useful extensions for [Combine](https://developer.apple.com/documentation/combine) and [CombineX](https://github.com/cx-org/CombineX).

## API

### Publisher

#### DiscardError

Discard error from upstream and complete.

```swift
// Output: (data: Data, response: URLResponse), Failure: URLError
let upstream = URLSession.shared.cx.dataTaskPublisher(for: url)

// Output: (data: Data, response: URLResponse), Failure: Never
let pub = upstream.discardError()
```

### Cancellable

- DelayedAutoCancellable

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