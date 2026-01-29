//
//  TestSMTPConfig.swift
//  swift-nio-smtp
//
//  Created by Binary Birds on 2026. 01. 26..
//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

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
        //   SMTP_HOST
        //   SMTP_USER
        //   SMTP_PASS
        //   SMTP_FROM
        //   SMTP_TO
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
            host: env["SMTP_HOST"] ?? "",
            user: env["SMTP_USER"] ?? "",
            pass: env["SMTP_PASS"] ?? "",
            from: env["SMTP_FROM"] ?? "",
            to: env["SMTP_TO"] ?? ""
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
