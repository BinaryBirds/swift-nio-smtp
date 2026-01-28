# SwiftNIO SMTP

Lightweight SMTP client built on top of SwiftNIO.

[![Release: 1.0.0-beta.1](https://img.shields.io/badge/Release-1%2E0%2E0--beta%2E1-F05138)](https://github.com/BinaryBirds/swift-nio-smtp/releases/tag/1.0.0-beta.1)

## Features

- Async SMTP client build over SwiftNIO
- STARTTLS and SSL support
- AUTH LOGIN
- Raw DATA payload support
- No Foundation framework dependency

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: macOS, iOS, tvOS, watchOS, visionOS](https://img.shields.io/badge/Platforms-macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS-F05138)

- Swift 6.1+
- Platforms:
    - macOS 15+
    - iOS 18+
    - tvOS 18+
    - watchOS 11+
    - visionOS 2+

## Installation

Use Swift Package Manager; add the dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/BinaryBirds/swift-nio-smtp", exact: "1.0.0-beta.1"),
```

Then add `NIOSMTP` to your target dependencies:

```swift
.product(name: "NIOSMTP", package: "swift-nio-smtp"),
```

## Usage

[ 
    ![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)
](
    https://binarybirds.github.io/swift-nio-smtp/
)

API documentation is available at the following link.

### Example

Create an `SMTPEnvelope` with a raw DATA payload and send it using `NIOSMTP`.

```swift
import NIOSMTP
import NIO
import Logging

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let smtp = NIOSMTP(
    eventLoopGroup: eventLoopGroup,
    configuration: .init(
        hostname: "smtp.example.com",
        signInMethod: .credentials(
            username: "user@example.com",
            password: "app-password"
        )
    ),
    logger: .init(label: "nio-smtp")
)

let raw = [
    "From: sender@example.com",
    "To: recipient@example.com",
    "Subject: Hello",
    "Date: Mon, 01 Jan 2024 00:00:00 +0000",
    "Message-ID: <message@example.com>",
    "Content-Type: text/plain; charset=\"UTF-8\"",
    "Mime-Version: 1.0",
    "",
    "Hello from SwiftNIO SMTP.",
    ""
].joined(separator: "\r\n")

let envelope = try SMTPEnvelope(
    from: "sender@example.com",
    recipients: ["recipient@example.com"],
    data: raw
)

try await smtp.send(envelope)
try await eventLoopGroup.shutdownGracefully()
```

## Development

- Build: `swift build`
- Test:
    - local: `make test`
    - using Docker: `make docker-test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/BinaryBirds/swift-nio-smtp/pulls) are welcome. Please keep changes focused and include tests for new logic.

## Credits
The NIOSMTP library is heavily inspired by [Mikroservices/Smtp](https://github.com/Mikroservices/Smtp).
