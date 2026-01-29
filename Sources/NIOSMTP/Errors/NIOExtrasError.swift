//
//  NIOExtrasError.swift
//  swift-nio-smtp
//
//  Created by Tibor Bodecs on 2020. 04. 28..
//

import NIOCore

protocol NIOExtrasError: Equatable, Error {}

/// Errors that are raised in NIOExtras.
enum NIOExtrasErrors {

    /// Error indicating that after an operation some unused bytes are left.
    struct LeftOverBytesError: NIOExtrasError {
        let leftOverBytes: ByteBuffer
    }
}
