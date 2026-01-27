//
//  OutboundSMTPRequestEncoder.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIO

final class OutboundSMTPRequestEncoder: MessageToByteEncoder {
    typealias OutboundIn = Request

    func encode(data: Request, out: inout ByteBuffer) {
        switch data {
        case .sayHello(serverName: let server, let helloMethod):
            out.writeString("\(helloMethod.rawValue) \(server)")
        case .startTLS:
            out.writeString("STARTTLS")
        case .sayHelloAfterTLS(serverName: let server, let helloMethod):
            out.writeString("\(helloMethod.rawValue) \(server)")
        case .mailFrom(let from):
            out.writeString("MAIL FROM:<\(from)>")
        case .recipient(let rcpt):
            out.writeString("RCPT TO:<\(rcpt)>")
        case .data:
            out.writeString("DATA")
        case .transferData(let message):
            out.writeString(message)
            if !message.hasSuffix("\r\n") {
                out.writeString("\r\n")
            }
            out.writeString(".")
        case .quit:
            out.writeString("QUIT")
        case .beginAuthentication:
            out.writeString("AUTH LOGIN")
        case .authUser(let user):
            out.writeString(user.base64EncodedSMTPValue())
        case .authPassword(let password):
            out.writeString(password.base64EncodedSMTPValue())
        }
        out.writeString("\r\n")
    }
}

// MARK: - Helpers

private extension String {

    func base64EncodedSMTPValue() -> String {
        Array(utf8).base64EncodedString()
    }
}
