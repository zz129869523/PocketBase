//
//  AuthStore.swift
//  
//
//  Created by zz129869523 on 2022/12/22.
//

import Foundation

public class AuthStore<UserModel: AuthModel> {
  public var isValid: Bool? {
    return self.model?.verified
  }
  
  public var model: UserModel? {
    get {
      if let savedUser = UserDefaults.standard.object(forKey: Global.authStoreUserDefaultsKey) as? Data {
        return try? JSONDecoder().decode(UserModel.self, from: savedUser)
      }
      return nil
    }
    
    set {
      if let encoded = try? JSONEncoder().encode(newValue) {
        UserDefaults.standard.set(newValue?.id, forKey: Global.identityUserDefaultsKey)
        UserDefaults.standard.set(encoded, forKey: Global.authStoreUserDefaultsKey)
      }
    }
  }
  
  public var token: String? {
    get {
      if let id = self.model?.id {
        return Keychain.read(Global.authStoreUserDefaultsKey + id)
      }
      return nil
    }
    
    set {
      if let token = newValue, let id = self.model?.id {
        if Keychain.read(Global.authStoreUserDefaultsKey + id) != nil {
          let _ = Keychain.update(Global.authStoreUserDefaultsKey + id, token)
        } else {
          let _ = Keychain.create(Global.authStoreUserDefaultsKey + id, token)
        }
      }
    }
  }
  
  public func clear() {
    if let id = self.model?.id {
      Keychain.delete(Global.authStoreUserDefaultsKey + id)
    }
    
    self.token = nil
    self.model = nil
    UserDefaults.standard.removeObject(forKey: Global.authStoreUserDefaultsKey)
    UserDefaults.standard.removeObject(forKey: Global.identityUserDefaultsKey)
  }
  
  func storageWith(_ dic: [String: Any]?) {
    let authResponse = try? Global.dicToStruct(dictionary: dic ?? [:]) as AuthResponse<UserModel>
    self.token = authResponse?.token
    self.model = authResponse?.record
  }
}
