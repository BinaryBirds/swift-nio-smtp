//
//  TestSMTPConfig.swift
//  swift-nio-smtp
//
//  Created by Binary Birds on 2026. 01. 26..
//

struct TestSMTPConfig {
    let host: String
    let user: String
    let pass: String
    let from: String
    let to: String

    static func load() -> TestSMTPConfig {
        // NOTE: This test config is intentionally hardcoded and does not read
        // environment variables or .env files. The swift-nio-smtp package is
        // Foundation-free, so tests avoid ProcessInfo/FileManager/getenv.
        //
        // To run integration tests locally, fill in the values below with a
        // real SMTP host, credentials (or leave user/pass empty for anonymous),
        // and valid from/to addresses. Keep these values out of source control.
        // Example:
        //   host: "smtp.example.com"
        //   user: "user@example.com"
        //   pass: "app-password"
        //   from: "sender@example.com"
        //   to: "recipient@example.com"
        //
        // When values are empty, tests will skip by checking isComplete.
        return TestSMTPConfig(
            host: "",
            user: "",
            pass: "",
            from: "",
            to: ""
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
