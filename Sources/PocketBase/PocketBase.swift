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
}
