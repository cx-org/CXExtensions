# CXExtensions

[![GitHub CI](https://github.com/cx-org/CXExtensions/workflows/CI/badge.svg)](https://github.com/cx-org/CXExtensions/actions)
[![Release](https://img.shields.io/github/release-pre/cx-org/CXExtensions)](https://github.com/cx-org/CXExtensions/releases)
![Install](https://img.shields.io/badge/install-Swift_PM%20%7C%20CocoaPods-ff69b4)
![Supported Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)
[![Discord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/9vzqgZx)

A collection of useful extensions for Combine.

CXExtensions is [Combine Compatible Package](https://github.com/cx-org/CombineX/wiki/Combine-Compatible-Package). You're free to switch underlying Combine implementation between [CombineX](https://github.com/cx-org/CombineX) and [Combine](https://developer.apple.com/documentation/combine).

## API

#### IgnoreError

Ignore error from upstream and complete.

```swift
// Output: (data: Data, response: URLResponse), Failure: URLError
let upstream = URLSession.shared.cx.dataTaskPublisher(for: url)

// Output: (data: Data, response: URLResponse), Failure: Never
let pub = upstream.ignoreError()
```

#### DelayedAutoCancellable

Auto cancel after delay.

```swift
let delayedCanceller = upstream
    .sink { o in
        print(o)
    }
    .cancel(after .second(1), scheduler: DispatchQueue.main.cx)
```

## Get Started

### Requirements

- Swift 5.0 (Xcode 10.2)

### Installation

#### Swift Package Manager (Recommended)

```swift
package.dependencies.append(
    .package(url: "https://github.com/cx-org/CXExtensions", .upToNextMinor(from: "0.1.0"))
)
```

#### CocoaPods

```ruby
pod 'CXExtensions', '~> 0.1.0'
```
