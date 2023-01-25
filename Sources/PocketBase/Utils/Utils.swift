//
//  Utils.swift
//  
//
//  Created by 陳勇辰 on 2022/12/29.
//

import Foundation

public class Utils {
  public static func dictionaryToStruct<T: Codable>(dictionary: [String: Any]?) throws -> T {
    return try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: dictionary ?? [:]))
  }
  
  public static func stringToDictionary(text: String) -> [String: Any] {
    if let data = text.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
      } catch {
        print(error.localizedDescription)
      }
    }
    
    return [:]
  }
  
  public static func structToDictionary<T: Encodable>(_ t: T) -> [String: Any] {
    do {
      let data = try JSONEncoder().encode(t)
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
    } catch {
      print(error)
    }
    
    return [:]
  }
  
  static func parametersToFormData(_ boundary: String, key: String, value: Any) -> Data {
    var body = Data()
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
    body.append("\(value)\r\n")
    return body
  }
  
  static func fileToFormData(_ boundary: String, key: String, value: Data, filename: String, mimeType: String) -> Data {
    var body = Data()
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
    body.append("Content-Type: \(mimeType)\r\n\r\n") // image/png
    body.append(value)
    body.append("\r\n")
    return body
  }
}
