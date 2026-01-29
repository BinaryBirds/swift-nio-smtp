//
//  TestSMTPConfig.swift
//  swift-nio-smtp
//
//  Created by Binary Birds on 2026. 01. 26..
//

import Foundation

struct TestSMTPConfig {
    let host: String
    let user: String
    let pass: String
    let from: String
    let to: String

    static func load() -> TestSMTPConfig {
        // NOTE: Tests read from environment variables first and then fall back
        // to hardcoded values below.
        //
        // Environment variables (preferred):
        //   NIO_SMTP_TEST_HOST / SMTP_HOST
        //   NIO_SMTP_TEST_USER / SMTP_USER
        //   NIO_SMTP_TEST_PASS / SMTP_PASS
        //   NIO_SMTP_TEST_FROM / SMTP_FROM
        //   NIO_SMTP_TEST_TO   / SMTP_TO
        //
        // To run integration tests locally without env vars, fill in the values
        // below with a real SMTP host, credentials and valid from/to addresses.
        // Keep these values out of source control.
        // Example:
        //   host: "smtp.example.com"
        //   user: "user@example.com"
        //   pass: "app-password"
        //   from: "sender@example.com"
        //   to: "recipient@example.com"
        //
        // When values are empty, tests will skip by checking isComplete.
        let env = ProcessInfo.processInfo.environment
        return TestSMTPConfig(
            host: env["NIO_SMTP_TEST_HOST"] ?? env["SMTP_HOST"] ?? "",
            user: env["NIO_SMTP_TEST_USER"] ?? env["SMTP_USER"] ?? "",
            pass: env["NIO_SMTP_TEST_PASS"] ?? env["SMTP_PASS"] ?? "",
            from: env["NIO_SMTP_TEST_FROM"] ?? env["SMTP_FROM"] ?? "",
            to: env["NIO_SMTP_TEST_TO"] ?? env["SMTP_TO"] ?? ""
        )
    }

    var isComplete: Bool {
        !host.isEmpty
            && !user.isEmpty
            && !pass.isEmpty
            && !from.isEmpty
            && !to.isEmpty
    }
}
