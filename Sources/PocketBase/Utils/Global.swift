//
//  Global.swift
//
//
//  Created by 陳勇辰 on 2022/12/24.
//

import Foundation

class Global {
  static let defaultBaseUrlString = "http://0.0.0.0:8090"
  static let baseUrlStringUserDefaultsKey = "io.pocketbase.baseUrl"
  
  static let authStoreUserDefaultsKey = "io.pocketbase.suthStore"
  static let identityUserDefaultsKey = "io.pocketbase.identity"
}

extension Global {
  static func dicToStruct<T: Codable>(dictionary: [String: Any]) throws -> T {
    return try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary))
  }
}
