//
//  Request.swift
//  NIOSMTP
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

enum Request {
    case sayHello(serverName: String, helloMethod: HelloMethod)
    case startTLS
    case sayHelloAfterTLS(serverName: String, helloMethod: HelloMethod)
    case beginAuthentication
    case authUser(String)
    case authPassword(String)
    case mailFrom(String)
    case recipient(String)
    case data
    case transferData(String)
    case quit
}
