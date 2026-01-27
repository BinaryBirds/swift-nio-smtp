//
//  NIOSMTPUnitTests.swift
//  swift-nio-smtp
//
//  Created by Binary Birds on 2026. 01. 27..

import XCTest
import NIOCore
@testable import NIOSMTP

final class NIOSMTPUnitTests: XCTestCase {

    func testSMTPEnvelopeValidation() throws {
        XCTAssertThrowsError(
            try SMTPEnvelope(from: "a", recipients: [], data: "x")
        )
        XCTAssertThrowsError(
            try SMTPEnvelope(from: "a", recipients: [""], data: "x")
        )
        XCTAssertThrowsError(
            try SMTPEnvelope(from: "a", recipients: ["b"], data: "")
        )
        XCTAssertNoThrow(
            try SMTPEnvelope(from: "a", recipients: ["b"], data: "x")
        )
    }

    func testSMTPEnvelopeWhitespaceRecipients() {
        XCTAssertThrowsError(
            try SMTPEnvelope(from: "a", recipients: ["   "], data: "x")
        )
    }

    func testOutboundRequestEncodingAdditionalCommands() {
        var buffer = ByteBufferAllocator().buffer(capacity: 128)
        let encoder = OutboundSMTPRequestEncoder()

        encoder.encode(data: .startTLS, out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "STARTTLS\r\n"
        )

        buffer.clear()
        encoder.encode(
            data: .sayHello(serverName: "smtp.example.com", helloMethod: .helo),
            out: &buffer
        )
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "HELO smtp.example.com\r\n"
        )

        buffer.clear()
        encoder.encode(
            data: .sayHelloAfterTLS(
                serverName: "smtp.example.com",
                helloMethod: .ehlo
            ),
            out: &buffer
        )
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "EHLO smtp.example.com\r\n"
        )

        buffer.clear()
        encoder.encode(data: .quit, out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "QUIT\r\n"
        )
    }

    func testHelloMethodRawValues() {
        XCTAssertEqual(HelloMethod.helo.rawValue, "HELO")
        XCTAssertEqual(HelloMethod.ehlo.rawValue, "EHLO")
    }

    func testSignInMethodCases() {
        let anonymous = SignInMethod.anonymous
        switch anonymous {
        case .anonymous:
            XCTAssertTrue(true)
        case .credentials:
            XCTFail("unexpected credentials")
        }

        let credentials = SignInMethod.credentials(username: "u", password: "p")
        switch credentials {
        case .credentials(let username, let password):
            XCTAssertEqual(username, "u")
            XCTAssertEqual(password, "p")
        case .anonymous:
            XCTFail("unexpected anonymous")
        }
    }

    func testSecurityStartTLSFlags() {
        XCTAssertFalse(Security.none.isStartTLSEnabled)
        XCTAssertFalse(Security.ssl.isStartTLSEnabled)
        XCTAssertTrue(Security.startTLS.isStartTLSEnabled)
        XCTAssertTrue(Security.startTLSIfAvailable.isStartTLSEnabled)
    }

    func testOutboundRequestEncoding() {
        var buffer = ByteBufferAllocator().buffer(capacity: 128)
        let encoder = OutboundSMTPRequestEncoder()

        encoder.encode(
            data: .sayHello(serverName: "smtp.example.com", helloMethod: .ehlo),
            out: &buffer
        )
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "EHLO smtp.example.com\r\n"
        )

        buffer.clear()
        encoder.encode(data: .mailFrom("sender@example.com"), out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "MAIL FROM:<sender@example.com>\r\n"
        )

        buffer.clear()
        encoder.encode(data: .recipient("to@example.com"), out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "RCPT TO:<to@example.com>\r\n"
        )

        buffer.clear()
        encoder.encode(data: .data, out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "DATA\r\n"
        )

        buffer.clear()
        encoder.encode(data: .beginAuthentication, out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "AUTH LOGIN\r\n"
        )

        buffer.clear()
        encoder.encode(data: .authUser("user"), out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "dXNlcg==\r\n"
        )

        buffer.clear()
        encoder.encode(data: .authPassword("pass"), out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "cGFzcw==\r\n"
        )
    }

    func testTransferDataAppendsTerminator() {
        var buffer = ByteBufferAllocator().buffer(capacity: 128)
        let encoder = OutboundSMTPRequestEncoder()

        encoder.encode(data: .transferData("Hello"), out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "Hello\r\n.\r\n"
        )

        buffer.clear()
        encoder.encode(data: .transferData("Hello\r\n"), out: &buffer)
        XCTAssertEqual(
            buffer.readString(length: buffer.readableBytes),
            "Hello\r\n.\r\n"
        )
    }
}
