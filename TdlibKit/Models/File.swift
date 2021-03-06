//
//  File.swift
//  tl2swift
//
//  Created by Code Generator
//

import Foundation


/// Represents a file
public struct File: Codable, Hashable, Equatable {

    /// Expected file size in case the exact file size is unknown, but an approximate size is known. Can be used to show download/upload progress
    public let expectedSize: Int

    /// Unique file identifier
    public let id: Int

    /// Information about the local copy of the file
    public let local: LocalFile

    /// Information about the remote copy of the file
    public let remote: RemoteFile

    /// File size; 0 if unknown
    public let size: Int


    public init (
        expectedSize: Int,
        id: Int,
        local: LocalFile,
        remote: RemoteFile,
        size: Int) {

        self.expectedSize = expectedSize
        self.id = id
        self.local = local
        self.remote = remote
        self.size = size
    }
}

