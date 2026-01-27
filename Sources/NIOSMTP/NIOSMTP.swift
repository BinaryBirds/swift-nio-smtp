//
//  NIOSMTP.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

@preconcurrency import NIO
import Logging

/// Send an Email with an SMTP provider
public struct NIOSMTP: Sendable {

    /// event llop group
    public let eventLoopGroup: EventLoopGroup
    /// config
    public let config: Configuration
    /// logger
    public let logger: Logger?

    /// nio smtp init function
    public init(
        eventLoopGroup: EventLoopGroup,
        configuration: Configuration,
        logger: Logger? = nil
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.config = configuration
        self.logger = logger
    }

    ///
    /// Send an Email with SMTP sender
    ///
    /// - Parameter email: Email struct to send
    /// - Throws: Sending errors
    public func send(_ envelope: SMTPEnvelope) async throws(NIOSMTPError) {
        do {
            let result = try await sendWithPromise(envelope: envelope).get()
            switch result {
            case .success:
                break
            case .failure(let error):
                throw error
            }
        } catch let error as NIOSMTPError {
            throw error
        } catch {
            throw .unknown(error)
        }
    }

    private func sendWithPromise(
        envelope: SMTPEnvelope
    ) -> EventLoopFuture<Result<Bool, NIOSMTPError>> {
        let eventLoop = eventLoopGroup.next()
        let promise: EventLoopPromise<Void> = eventLoop.makePromise()
        let bootstrap = ClientBootstrap(group: eventLoop)
            .connectTimeout(config.timeout)
            .channelOption(
                ChannelOptions.socket(
                    SocketOptionLevel(SOL_SOCKET),
                    SO_REUSEADDR
                ),
                value: 1
            )
            .channelInitializer { channel in
                let secureChannelFuture = config.security.configureChannel(
                    on: channel,
                    hostname: config.hostname
                )
                return secureChannelFuture.flatMap {
                    let defaultHandlers: [ChannelHandler] = [
                        DuplexMessagesHandler(logger: logger),
                        ByteToMessageHandler(InboundLineBasedFrameDecoder()),
                        InboundSMTPResponseDecoder(),
                        MessageToByteHandler(OutboundSMTPRequestEncoder()),
                        StartTLSHandler(
                            configuration: config,
                            promise: promise
                        ),
                        InboundSendEmailHandler(
                            config: config,
                            envelope: envelope,
                            promise: promise
                        ),
                    ]
                    do {
                        try channel.pipeline.syncOperations.addHandlers(
                            defaultHandlers
                        )
                        return channel.eventLoop.makeSucceededFuture(())
                    } catch {
                        return channel.eventLoop.makeFailedFuture(error)
                    }
                }
            }

        let connection = bootstrap.connect(
            host: config.hostname,
            port: config.port
        )
        connection.cascadeFailure(to: promise)

        return promise.futureResult
            .map { () -> Result<Bool, NIOSMTPError> in
                connection.whenSuccess { $0.close(promise: nil) }
                return .success(true)
            }
            .flatMapError { error -> EventLoopFuture<Result<Bool, NIOSMTPError>> in
                let smtpError = (error as? NIOSMTPError) ?? .unknown(error)
                return eventLoop.makeSucceededFuture(.failure(smtpError))
            }
    }

}
