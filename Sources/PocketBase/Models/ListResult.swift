//
//  ListResult.swift
//  
//
//  Created by zz129869523 on 2022/12/23.
//

import Foundation

public struct ListResult<T: Codable>: Codable {
  public let page: Int
  public let perPage: Int
  public let totalItems: Int
  public let totalPages: Int?
  public let items: [T]
}
