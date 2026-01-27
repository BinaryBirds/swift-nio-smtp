//
//  HelloMethod.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

public enum HelloMethod: String, Sendable {
    case helo = "HELO"
    case ehlo = "EHLO"
}
