//
//  Envelope.swift
//  swift-nio-smtp
//
//  Created by Tibor Bodecs on 2026. 01. 26..
//

/// SMTP envelope and raw message payload.
public struct SMTPEnvelope: Sendable {

    /// Mail sender (envelope MAIL FROM address).
    public let from: String

    /// All recipients (envelope RCPT TO addresses).
    public let recipients: [String]

    /// Raw SMTP DATA payload without the terminating <CRLF>.<CRLF>.
    public let data: String

    /// Creates a new SMTP envelope.
    public init(
        from: String,
        recipients: [String],
        data: String
    ) throws(NIOSMTPError) {
        guard
            recipients.contains(where: {
                $0.contains(where: { !$0.isWhitespace })
            })
        else {
            throw .invalidRecipient
        }
        guard !data.isEmpty else {
            throw .invalidMessage
        }
        self.from = from
        self.recipients = recipients
        self.data = data
    }
}
