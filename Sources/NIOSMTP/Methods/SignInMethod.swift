//
//  SignInMethod.swift
//  swift-nio-smtp
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

/// Authentication methods supported by SMTP servers.
public enum SignInMethod: Sendable {
    case anonymous
    case credentials(username: String, password: String)
}
