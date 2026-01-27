import XCTest
import Foundation
import NIO
import NIOSMTP
import Logging

final class NIOSMTPTests: XCTestCase {

    var host: String {
        ProcessInfo.processInfo.environment["SMTP_HOST"]!
    }

    var user: String {
        ProcessInfo.processInfo.environment["SMTP_USER"]!
    }

    var pass: String {
        ProcessInfo.processInfo.environment["SMTP_PASS"]!
    }

    var from: String {
        ProcessInfo.processInfo.environment["MAIL_FROM"]!
    }

    var to: String {
        ProcessInfo.processInfo.environment["MAIL_TO"]!
    }

    private func send(_ envelope: SMTPEnvelope) async throws {

        let eventLoopGroup = MultiThreadedEventLoopGroup(
            numberOfThreads: 1
        )
        let smtp = NIOSMTP(
            eventLoopGroup: eventLoopGroup,
            configuration: .init(
                hostname: host,
                signInMethod: .credentials(
                    username: user,
                    password: pass
                )
            ),
            logger: .init(label: "nio-smtp")
        )
        try await smtp.send(envelope)

        try await eventLoopGroup.shutdownGracefully()
    }

    // MARK: - test cases

    func testPlainText() async throws {
        let raw = rawMessage(
            from: from,
            to: to,
            subject: "Test plain text email",
            body: "This is a plain text email."
        )
        let envelope = try SMTPEnvelope(
            from: from,
            recipients: [to],
            data: raw
        )
        try await send(envelope)
    }

    func testHMTL() async throws {
        let raw = rawMessage(
            from: from,
            to: to,
            subject: "Test HTML email",
            contentType: "text/html; charset=\"UTF-8\"",
            body: "This is a <b>HTML</b> email."
        )
        let envelope = try SMTPEnvelope(
            from: from,
            recipients: [to],
            data: raw
        )
        try await send(envelope)
    }

    func testAttachment() async throws {
        let boundary = "boundary-test"
        let raw = rawMultipartMessage(
            from: from,
            to: to,
            subject: "Test with attachment",
            boundary: boundary,
            body: "This is an email with a very small attachment.",
            attachmentName: "test.png",
            attachmentType: "image/png",
            attachmentBase64: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII="
        )
        let envelope = try SMTPEnvelope(
            from: from,
            recipients: [to],
            data: raw
        )
        try await send(envelope)
    }
}

private extension NIOSMTPTests {
    func rawMessage(
        from: String,
        to: String,
        subject: String,
        contentType: String = "text/plain; charset=\"UTF-8\"",
        body: String
    ) -> String {
        [
            "From: \(from)",
            "To: \(to)",
            "Subject: \(subject)",
            "Date: Mon, 01 Jan 2024 00:00:00 +0000",
            "Message-ID: <test@example.com>",
            "Content-Type: \(contentType)",
            "Mime-Version: 1.0",
            "",
            body,
            ""
        ].joined(separator: "\r\n")
    }

    func rawMultipartMessage(
        from: String,
        to: String,
        subject: String,
        boundary: String,
        body: String,
        attachmentName: String,
        attachmentType: String,
        attachmentBase64: String
    ) -> String {
        [
            "From: \(from)",
            "To: \(to)",
            "Subject: \(subject)",
            "Date: Mon, 01 Jan 2024 00:00:00 +0000",
            "Message-ID: <test@example.com>",
            "Content-type: multipart/mixed; boundary=\"\(boundary)\"",
            "Mime-Version: 1.0",
            "",
            "--\(boundary)",
            "Content-Type: text/plain; charset=\"UTF-8\"",
            "Mime-Version: 1.0",
            "",
            body,
            "",
            "--\(boundary)",
            "Content-type: \(attachmentType)",
            "Content-Transfer-Encoding: base64",
            "Content-Disposition: attachment; filename=\"\(attachmentName)\"",
            "",
            attachmentBase64,
            "",
            "--\(boundary)--",
            ""
        ].joined(separator: "\r\n")
    }
}
