//
//  SignInMethod.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

public enum SignInMethod: Sendable {
    case anonymous
    case credentials(username: String, password: String)
}
