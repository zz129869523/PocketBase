//
//  Utils.swift
//  
//
//  Created by 陳勇辰 on 2022/12/29.
//

import Foundation

public class Utils {
  static func dictionaryToStruct<T: Codable>(dictionary: [String: Any]) throws -> T {
    return try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary))
  }
  
  static func stringToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
}
