//
//  InboundSendEmailHandler.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIO
import NIOSSL

final class InboundSendEmailHandler: ChannelInboundHandler {
    typealias InboundIn = Response
    typealias OutboundOut = Request

    enum Expect {
        case initialMessageFromServer
        case okAfterHello
        case okAfterStartTls
        case okAfterStartTlsHello
        case okAfterAuthBegin
        case okAfterUsername
        case okAfterPassword
        case okAfterMailFrom
        case okAfterRecipient
        case okAfterDataCommand
        case okAfterMailData
        case okAfterQuit
        case nothing
        case error
    }

    private var currentlyWaitingFor = Expect.initialMessageFromServer
    private let envelope: SMTPEnvelope
    private let config: Configuration
    private let promise: EventLoopPromise<Void>
    private var recipients: [String] = []

    init(
        config: Configuration,
        envelope: SMTPEnvelope,
        promise: EventLoopPromise<Void>
    ) {
        self.config = config
        self.envelope = envelope
        self.promise = promise
        self.recipients = envelope.recipients
    }

    func send(context: ChannelHandlerContext, command: Request) {
        context.writeAndFlush(wrapOutboundOut(command))
            .cascadeFailure(
                to: promise
            )
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let result = unwrapInboundIn(data)
        switch result {
        case .error(let message):
            promise.fail(NIOSMTPError.custom(message))
            return
        case .ok:
            ()
        }

        switch currentlyWaitingFor {
        case .initialMessageFromServer:
            send(
                context: context,
                command: .sayHello(
                    serverName: config.hostname,
                    helloMethod: config.helloMethod
                )
            )
            currentlyWaitingFor = .okAfterHello
        case .okAfterHello:
            if config.security.isStartTLSEnabled {
                send(context: context, command: .startTLS)
                currentlyWaitingFor = .okAfterStartTls
            }
            else {
                switch config.signInMethod {
                case .credentials(_, _):
                    send(context: context, command: .beginAuthentication)
                    currentlyWaitingFor = .okAfterAuthBegin
                case .anonymous:
                    send(context: context, command: .mailFrom(envelope.from))
                    currentlyWaitingFor = .okAfterMailFrom
                }
            }
        case .okAfterStartTls:
            send(
                context: context,
                command: .sayHelloAfterTLS(
                    serverName: config.hostname,
                    helloMethod: config.helloMethod
                )
            )
            currentlyWaitingFor = .okAfterStartTlsHello
        case .okAfterStartTlsHello:
            send(context: context, command: .beginAuthentication)
            currentlyWaitingFor = .okAfterAuthBegin
        case .okAfterAuthBegin:
            switch config.signInMethod {
            case .credentials(let username, _):
                send(context: context, command: .authUser(username))
                currentlyWaitingFor = .okAfterUsername
            case .anonymous:
                promise.fail(
                    NIOSMTPError.custom(
                        "After auth begin executed for anonymous sign in method"
                    )
                )
                break
            }
        case .okAfterUsername:
            switch config.signInMethod {
            case .credentials(_, let password):
                send(context: context, command: .authPassword(password))
                currentlyWaitingFor = .okAfterPassword
            case .anonymous:
                promise.fail(
                    NIOSMTPError.custom(
                        "After user name executed for anonymous sign in method"
                    )
                )
                break
            }
        case .okAfterPassword:
            send(context: context, command: .mailFrom(envelope.from))
            currentlyWaitingFor = .okAfterMailFrom
        case .okAfterMailFrom:
            if let recipient = recipients.popLast() {
                send(context: context, command: .recipient(recipient))
            }
            else {
                fallthrough
            }
        case .okAfterRecipient:
            send(context: context, command: .data)
            currentlyWaitingFor = .okAfterDataCommand
        case .okAfterDataCommand:
            send(context: context, command: .transferData(envelope.data))
            currentlyWaitingFor = .okAfterMailData
        case .okAfterMailData:
            send(context: context, command: .quit)
            currentlyWaitingFor = .okAfterQuit
        case .okAfterQuit:
            promise.succeed(())
            currentlyWaitingFor = .nothing
        case .nothing:
            ()
        case .error:
            promise.fail(
                NIOSMTPError.custom(
                    "Communication error state"
                )
            )
        }
    }
}
