//
//  swift-nio-smtpError.swift
//  swift-nio-smtp
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

/// Errors that can occur during SMTP delivery.
public enum NIOSMTPError: Error, Sendable {
    case invalidRecipient
    case invalidMessage
    case custom(String)
    case unknown(Error)
}
