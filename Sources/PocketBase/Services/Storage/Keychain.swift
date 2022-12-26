//
//  Keychain.swift
//  
//
//  Created by zz129869523 on 2022/12/23.
//

import Foundation

class Keychain {
  static func create(_ key: String, _ value: String) -> OSStatus {
    let data = value.data(using: .utf8)!
    let query = [
      kSecValueData: data,
      kSecAttrAccount: key,
      kSecClass: kSecClassGenericPassword] as CFDictionary
    
    return SecItemAdd(query, nil)
  }
  
  static func read(_ key: String) -> String? {
    var retrivedData: AnyObject? = nil
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: key,
      kSecReturnData: true] as CFDictionary
    
    let _ = SecItemCopyMatching(query, &retrivedData)
    
    if let data = retrivedData as? Data {
      return String(data: data, encoding: .utf8)
    }
    
    return nil
  }
  
  static func update(_ key: String, _ value: String) -> OSStatus {
    let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key] as CFDictionary
    let updateFields = [kSecValueData: value.data(using: .utf8)!] as CFDictionary
    
    return SecItemUpdate(query, updateFields)
  }
  
  static func delete(_ key: String) {
    let query = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key] as CFDictionary
    SecItemDelete(query)
  }
}
