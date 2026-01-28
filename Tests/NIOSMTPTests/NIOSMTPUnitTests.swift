//
//  NIOSMTPUnitTests.swift
//  swift-nio-smtp
//
//  Created by Binary Birds on 2026. 01. 27..

import Testing
import NIOCore
@testable import NIOSMTP

@Suite
struct NIOSMTPUnitTests {

    @Test
    func smtpEnvelopeValidation() throws {
        #expect(throws: (any Error).self) {
            try SMTPEnvelope(from: "a", recipients: [], data: "x")
        }
        #expect(throws: (any Error).self) {
            try SMTPEnvelope(from: "a", recipients: [""], data: "x")
        }
        #expect(throws: (any Error).self) {
            try SMTPEnvelope(from: "a", recipients: ["b"], data: "")
        }
        #expect(
            (try? SMTPEnvelope(from: "a", recipients: ["b"], data: "x")) != nil
        )
    }

    @Test
    func smtpEnvelopeWhitespaceRecipients() {
        #expect(throws: (any Error).self) {
            try SMTPEnvelope(from: "a", recipients: ["   "], data: "x")
        }
    }

    @Test
    func outboundRequestEncodingAdditionalCommands() {
        var buffer = ByteBufferAllocator().buffer(capacity: 128)
        let encoder = OutboundSMTPRequestEncoder()

        encoder.encode(data: .startTLS, out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes) == "STARTTLS\r\n"
        )

        buffer.clear()
        encoder.encode(
            data: .sayHello(serverName: "smtp.example.com", helloMethod: .helo),
            out: &buffer
        )
        #expect(
            buffer.readString(length: buffer.readableBytes)
                == "HELO smtp.example.com\r\n"
        )

        buffer.clear()
        encoder.encode(
            data: .sayHelloAfterTLS(
                serverName: "smtp.example.com",
                helloMethod: .ehlo
            ),
            out: &buffer
        )
        #expect(
            buffer.readString(length: buffer.readableBytes)
                == "EHLO smtp.example.com\r\n"
        )

        buffer.clear()
        encoder.encode(data: .quit, out: &buffer)
        #expect(buffer.readString(length: buffer.readableBytes) == "QUIT\r\n")
    }

    @Test
    func helloMethodRawValues() {
        #expect(HelloMethod.helo.rawValue == "HELO")
        #expect(HelloMethod.ehlo.rawValue == "EHLO")
    }

    @Test
    func signInMethodCases() {
        let anonymous = SignInMethod.anonymous
        switch anonymous {
        case .anonymous:
            #expect(Bool(true))
        case .credentials:
            #expect(Bool(false), "unexpected credentials")
        }

        let credentials = SignInMethod.credentials(username: "u", password: "p")
        switch credentials {
        case .credentials(let username, let password):
            #expect(username == "u")
            #expect(password == "p")
        case .anonymous:
            #expect(Bool(false), "unexpected anonymous")
        }
    }

    @Test
    func securityStartTLSFlags() {
        #expect(!Security.none.isStartTLSEnabled)
        #expect(!Security.ssl.isStartTLSEnabled)
        #expect(Security.startTLS.isStartTLSEnabled)
        #expect(Security.startTLSIfAvailable.isStartTLSEnabled)
    }

    @Test
    func outboundRequestEncoding() {
        var buffer = ByteBufferAllocator().buffer(capacity: 128)
        let encoder = OutboundSMTPRequestEncoder()

        encoder.encode(
            data: .sayHello(serverName: "smtp.example.com", helloMethod: .ehlo),
            out: &buffer
        )
        #expect(
            buffer.readString(length: buffer.readableBytes)
                == "EHLO smtp.example.com\r\n"
        )

        buffer.clear()
        encoder.encode(data: .mailFrom("sender@example.com"), out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes)
                == "MAIL FROM:<sender@example.com>\r\n"
        )

        buffer.clear()
        encoder.encode(data: .recipient("to@example.com"), out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes)
                == "RCPT TO:<to@example.com>\r\n"
        )

        buffer.clear()
        encoder.encode(data: .data, out: &buffer)
        #expect(buffer.readString(length: buffer.readableBytes) == "DATA\r\n")

        buffer.clear()
        encoder.encode(data: .beginAuthentication, out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes)
                == "AUTH LOGIN\r\n"
        )

        buffer.clear()
        encoder.encode(data: .authUser("user"), out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes) == "dXNlcg==\r\n"
        )

        buffer.clear()
        encoder.encode(data: .authPassword("pass"), out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes) == "cGFzcw==\r\n"
        )
    }

    @Test
    func transferDataAppendsTerminator() {
        var buffer = ByteBufferAllocator().buffer(capacity: 128)
        let encoder = OutboundSMTPRequestEncoder()

        encoder.encode(data: .transferData("Hello"), out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes) == "Hello\r\n.\r\n"
        )

        buffer.clear()
        encoder.encode(data: .transferData("Hello\r\n"), out: &buffer)
        #expect(
            buffer.readString(length: buffer.readableBytes) == "Hello\r\n.\r\n"
        )
    }
}
