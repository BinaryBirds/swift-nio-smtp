//
//  HelloMethod.swift
//  swift-nio-smtp
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

/// SMTP greeting method used during session negotiation.
public enum HelloMethod: String, Sendable {
    case helo = "HELO"
    case ehlo = "EHLO"
}
