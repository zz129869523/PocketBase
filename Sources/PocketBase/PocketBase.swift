//
//  PocketBase.swift
//  
//
//  Created by zz129869523 on 2022/12/21.
//

import Foundation

/// A client for PocketBase.
public class PocketBase<UserModel: AuthModel>: ObservableObject {
  public let authStore: AuthStore<UserModel> = .init()
  
  public static var host: String {
    get {
      UserDefaults.standard.string(forKey: Global.baseUrlStringUserDefaultsKey) ?? Global.defaultBaseUrlString
    }
    set {
      UserDefaults.standard.set(newValue, forKey: Global.baseUrlStringUserDefaultsKey)
    }
  }
  
  public init(host: String = "http://0.0.0.0:8090") {
    Self.host = host
  }
  
  public func collection(_ collection: String) -> Collection<UserModel> {
    return Collection(authStore, collection)
  }
  
  public func getFileUrl(_ id: String, _ collectionName: String, _ filename: String, query: [String: String] = [:]) -> URL? {
    return Self.getFileUrl(["id": id, "collectionName": collectionName], filename, query: query)
  }
  
  public static func getFileUrl(_ id: String, _ collectionName: String, _ filename: String, query: [String: String] = [:]) -> URL? {
    return Self.getFileUrl(["id": id, "collectionName": collectionName], filename, query: query)
  }
  
  public func getFileUrl(_ record: [String: Any], _ filename: String, query: [String: String] = [:]) -> URL? {
    return Self.getFileUrl(record, filename, query: query)
  }
  
  public static func getFileUrl(_ record: [String: Any], _ filename: String, query: [String: String] = [:]) -> URL? {
    var queryItem: [URLQueryItem] = []
    var collectionName: String = ""
    var recordId: String = ""
    
    guard var components = URLComponents(string: PocketBase<User>.host) else {
      return nil
    }
    
    for (key, value) in record {
      if key != "id" && key != "collectionName" { continue }
      
      if key == "id" {
        recordId = value as? String ?? ""
        continue
      }
      
      if key == "collectionName" {
        collectionName = value as? String ?? ""
        continue
      }
    }
    
    guard recordId != "", collectionName != "" else { return nil }
    
    components.path = "/api/files/\(collectionName)/\(recordId)/\(filename)"
   
    for (key, value) in query {
      queryItem.append(URLQueryItem(name: key, value: value))
    }
    
    if queryItem.count > 0 {
      components.queryItems = queryItem
    }
    
    return components.url
  }
  
  public func getFileUrl<T: BaseModel>(_ record: T, _ filename: String, query: [String: String] = [:]) -> URL? {
    return Self.getFileUrl(record, filename, query: query)
  }
  
  public static func getFileUrl<T: BaseModel>(_ record: T, _ filename: String, query: [String: String] = [:]) -> URL? {
    var queryItem: [URLQueryItem] = []
    
    guard var components = URLComponents(string: PocketBase<User>.host) else {
      return nil
    }

    guard let collectionName = record.collectionName, let recordId = record.id else {
      return nil
    }
    
    components.path = "/api/files/\(collectionName)/\(recordId)/\(filename)"
    
    
    for (key, value) in query {
      queryItem.append(URLQueryItem(name: key, value: value))
    }
    
    if queryItem.count > 0 {
      components.queryItems = queryItem
    }
    
    return components.url
  }
}
