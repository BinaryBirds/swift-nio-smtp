//
//  swift-nio-smtpTests.swift
//  swift-nio-smtp
//
//  Created by Binary Birds on 2026. 01. 27..

import Testing
import NIO
import NIOSMTP
import Logging

@Suite
struct NIOSMTPTests {

    private let config = TestSMTPConfig.load()

    private func send(_ envelope: SMTPEnvelope) async throws {

        let eventLoopGroup = MultiThreadedEventLoopGroup(
            numberOfThreads: 1
        )
        let smtp = NIOSMTP(
            eventLoopGroup: eventLoopGroup,
            configuration: .init(
                hostname: config.host,
                signInMethod: .credentials(
                    username: config.user,
                    password: config.pass
                )
            ),
            logger: .init(label: "nio-smtp")
        )
        try await smtp.send(envelope)

        try await eventLoopGroup.shutdownGracefully()
    }

    // MARK: - test cases

    @Test
    func plainText() async throws {
        if !config.isComplete { return }
        let raw = rawMessage(
            from: config.from,
            to: config.to,
            subject: "Test plain text email",
            body: "This is a plain text email."
        )
        let envelope = try SMTPEnvelope(
            from: config.from,
            recipients: [config.to],
            data: raw
        )
        try await send(envelope)
    }

    @Test
    func hmtl() async throws {
        if !config.isComplete { return }
        let raw = rawMessage(
            from: config.from,
            to: config.to,
            subject: "Test HTML email",
            contentType: "text/html; charset=\"UTF-8\"",
            body: "This is a <b>HTML</b> email."
        )
        let envelope = try SMTPEnvelope(
            from: config.from,
            recipients: [config.to],
            data: raw
        )
        try await send(envelope)
    }

    @Test
    func attachment() async throws {
        if !config.isComplete { return }
        let boundary = "boundary-test"
        let raw = rawMultipartMessage(
            from: config.from,
            to: config.to,
            subject: "Test with attachment",
            boundary: boundary,
            body: "This is an email with a very small attachment.",
            attachmentName: "test.txt",
            attachmentType: "text/plain",
            attachmentBase64: "SGVsbG8gYXR0YWNobWVudAo="
        )
        let envelope = try SMTPEnvelope(
            from: config.from,
            recipients: [config.to],
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
            "",
        ]
        .joined(separator: "\r\n")
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
            "",
        ]
        .joined(separator: "\r\n")
    }
}
