//
//  Security.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

@preconcurrency import NIO
@preconcurrency import NIOSSL

public enum Security: Sendable {

    /// Communication without any encryption (even password is send as a plain text).
    case none

    /// The connection should use SSL or TLS encryption immediately.
    case ssl

    /// Elevates the connection to use TLS encryption immediately after
    /// reading the greeting and capabilities of the server. If the server
    /// does not support the STARTTLS extension, then the connection will
    /// fail and error will be thrown.
    case startTLS

    /// Elevates the connection to use TLS encryption immediately after
    /// reading the greeting and capabilities of the server, but only if
    /// the server supports the STARTTLS extension.
    case startTLSIfAvailable
}

extension Security {

    var isStartTLSEnabled: Bool {
        self == .startTLS || self == .startTLSIfAvailable
    }

    func configureChannel(
        on channel: Channel,
        hostname: String
    ) -> EventLoopFuture<Void> {
        switch self {
        case .ssl:
            do {
                let sslContext = try NIOSSLContext(
                    configuration: .makeClientConfiguration()
                )
                let sslHandler = try NIOSSLClientHandler(
                    context: sslContext,
                    serverHostname: hostname
                )
                do {
                    try channel.pipeline.syncOperations.addHandler(sslHandler)
                    return channel.eventLoop.makeSucceededFuture(())
                } catch {
                    return channel.eventLoop.makeFailedFuture(error)
                }
            }
            catch {
                return channel.eventLoop.makeSucceededFuture(())
            }
        default:
            return channel.eventLoop.makeSucceededFuture(())
        }
    }
}
