//
//  File.swift
//  
//
//  Created by zz129869523 on 2023/1/8.
//

import Foundation

public protocol MultipartFormData { }

public struct File: Codable {
  public var mimeType: String
  public var filename: String
  public var data: Data
  
  public init(mimeType: String, filename: String, data: Data) {
    self.mimeType = mimeType
    self.filename = filename
    self.data = data
  }
}
