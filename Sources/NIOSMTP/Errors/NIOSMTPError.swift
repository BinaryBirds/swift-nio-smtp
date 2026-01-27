//
//  NIOSMTPError.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

public enum NIOSMTPError: Error, Sendable {
    case invalidRecipient
    case invalidMessage
    case custom(String)
    case unknown(Error)
}
