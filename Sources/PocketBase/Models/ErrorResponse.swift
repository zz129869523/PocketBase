//
//  ErrorResponse.swift
//  
//
//  Created by zz129869523 on 2022/12/23.
//

import Foundation

public struct ErrorResponse: Codable {
  public let code: Int
  public let message: String
  public let data: [String: SubErrResponse]
  
  public struct SubErrResponse: Codable {
    public let code: String
    public let message: String
  }
}

public extension ErrorResponse {
  init(dictionary: [String: Any]?) throws {
    self = try JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary ?? [:]))
  }
}
