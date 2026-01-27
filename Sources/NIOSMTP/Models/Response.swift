//
//  Response.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

enum Response {
    case ok(Int, String)
    case error(String)
}
