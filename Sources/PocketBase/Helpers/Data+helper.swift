//
//  File.swift
//  
//
//  Created by zz129869523 on 2023/1/8.
//

import Foundation

extension Data {
  mutating func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
