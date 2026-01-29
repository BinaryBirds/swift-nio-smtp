//
//  Configuration.swift
//  swift-nio-smtp
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIO

/// Configuration for a SMTP provider
public struct Configuration: Sendable {
    /// hostname
    public let hostname: String
    /// port
    public let port: Int
    /// security
    public let security: Security
    /// timeout
    public let timeout: TimeAmount
    /// hello method
    public let helloMethod: HelloMethod
    /// sign in method
    public let signInMethod: SignInMethod

    /// configuration init
    public init(
        hostname: String,
        port: Int = 587,
        signInMethod: SignInMethod,
        security: Security = .startTLS,
        timeout: TimeAmount = .seconds(10),
        helloMethod: HelloMethod = .helo
    ) {
        self.hostname = hostname
        self.port = port
        self.security = security
        self.timeout = timeout
        self.helloMethod = helloMethod
        self.signInMethod = signInMethod
    }
}
