# CXExtensions

[![GitHub CI](https://github.com/cx-org/CXExtensions/workflows/CI/badge.svg)](https://github.com/cx-org/CXExtensions/actions)
[![Release](https://img.shields.io/github/release-pre/cx-org/CXExtensions)](https://github.com/cx-org/CXExtensions/releases)
![Install](https://img.shields.io/badge/install-Swift_PM%20%7C%20CocoaPods-ff69b4)
![Supported Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey)
[![Discord](https://img.shields.io/badge/chat-discord-9cf)](https://discord.gg/9vzqgZx)

A collection of useful extensions for Combine.

CXExtensions is [Combine Compatible Package](https://github.com/cx-org/CombineX/wiki/Combine-Compatible-Package). You're free to switch underlying Combine implementation between [CombineX](https://github.com/cx-org/CombineX) and [Combine](https://developer.apple.com/documentation/combine).

## Installation

### Requirements

- Swift 5.2 (Xcode 11.4)

#### Swift Package Manager

```swift
package.dependencies += [
    .package(url: "https://github.com/cx-org/CXExtensions", .upToNextMinor(from: "0.3.0")),
]
```


## Operators

- [IgnoreError](#IgnoreError)
- [WeakAssign](#WeakAssign)
- [Invoke](#Invoke)
- [Blocking](#Blocking)
- [DelayedAutoCancellable](#DelayedAutoCancellable)

---

#### IgnoreError

Ignore error from upstream and complete.

```swift
// Output: (data: Data, response: URLResponse), Failure: URLError
let upstream = URLSession.shared.cx.dataTaskPublisher(for: url)

// Output: (data: Data, response: URLResponse), Failure: Never
let pub = upstream.ignoreError()
```

#### WeakAssign

Like `Subscribers.Assign`, but capture its target weakly.

```swift
pub.assign(to: \.output, weaklyOn: self)
```

#### Invoke

Invoke method on an object with each element from a `Publisher`.

```swift
pub.invoke(handleOutput, weaklyOn: self)
//  Substitute for the following common pattern:
//
//      pub.sink { [weak self] output in
//          self?.handleOutput(output)
//      }
```

#### Blocking

Get element from a `Publisher` synchronously. It's useful for command line tool and unit testing.

```swift
let sequence = pub.blocking()
for value in sequence {
    // process value
}
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
