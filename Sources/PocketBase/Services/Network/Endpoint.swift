//
//  Endpoint.swift
//  
//
//  Created by zz129869523 on 2021/12/14.
//

import Foundation

struct Endpoint<BodyType: Encodable> {
  var method: HTTPMethod = .get
  var host: String
  var path: String
  var queryItems: [URLQueryItem]?
  var body: BodyType? = nil
}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case patch = "PATCH"
  case delete = "DELETE"
}

extension Endpoint {
  var url: URL? {
    guard var components = URLComponents(string: host) else {
      return nil
    }
    
    components.path = path
    components.queryItems = queryItems
    
    guard let url = components.url else {
      preconditionFailure("Invalid URL components: \(components)")
    }
    
    return url
  }
  
  var headers: [String: String] {
    let os = ProcessInfo().operatingSystemVersion
    let bundleId = "\(Bundle.main.bundleIdentifier ?? "")"
    let iosVersion = "iOS \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
    let appVersion = "\(Bundle.main.displayName ?? "")/\(Bundle.main.releaseVersionNumber ?? "")"
    let buildVersion = "\(Bundle.main.buildVersionNumber ?? "")"
    
    var header = [
      "Content-type": "application/json",
      "User-Agent": "\(appVersion) (\(bundleId); build:\(buildVersion); \(iosVersion); \(Bundle.modelName))"
    ]
    
    if let id = UserDefaults.standard.string(forKey: Global.identityUserDefaultsKey) {
      if let token = Keychain.read(Global.authStoreUserDefaultsKey + id) {
        header["Authorization"] = "Bearer \(token)"
      }
    }

    return header
  }
}

extension Endpoint {
  // MARK: - CRUD
  static func fatch(_ collection: String, queryItems: [URLQueryItem]? = nil, id: String = "") -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .get,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/records/\(id)",
      queryItems: queryItems
    )
  }
  
  static func create<BodyType: Encodable>(_ collection: String, body: BodyType, queryItems: [URLQueryItem]? = nil) -> Endpoint<BodyType> {
    return Endpoint<BodyType>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/records",
      queryItems: queryItems,
      body: body
    )
  }
  
  static func update<BodyType: Encodable>(_ collection: String, body: BodyType, queryItems: [URLQueryItem]? = nil, id: String) -> Endpoint<BodyType> {
    return Endpoint<BodyType>(
      method: .patch,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/records/\(id)",
      queryItems: queryItems,
      body: body
    )
  }
  
  static func delete(_ collection: String, id: String) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .delete,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/records/\(id)"
    )
  }
  
  // MARK: - Realtime
  static func setSubscriptions(clientId: String, subscriptions: [String]) -> Endpoint<RealtimeRequset> {
    return Endpoint<RealtimeRequset>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/realtime",
      body: RealtimeRequset(clientId: clientId, subscriptions: subscriptions)
    )
  }
  
  // MARK: - Auth
  static func authWithPassword(_ collection: String, body: [String: String], queryItems: [URLQueryItem]? = nil) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/auth-with-password",
      queryItems: queryItems,
      body: body
    )
  }
  
  static func authWithOAuth2(_ collection: String, body: OAuth2Requset, queryItems: [URLQueryItem]? = nil) -> Endpoint<OAuth2Requset> {
    return Endpoint<OAuth2Requset>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/auth-with-oauth2",
      queryItems: queryItems,
      body: body
    )
  }
  
  static func authRefresh(_ collection: String, queryItems: [URLQueryItem]? = nil) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/auth-refresh",
      queryItems: queryItems
    )
  }
  
  static func requestVerification(_ collection: String, body: [String: String]) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/request-verification",
      body: body
    )
  }
  
  static func requestPasswordReset(_ collection: String, body: [String: String]) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/request-password-reset",
      body: body
    )
  }
  
  static func requestEmailChange(_ collection: String, body: [String: String]) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .post,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/request-email-change",
      body: body
    )
  }
  
  static func listAuthMethods(_ collection: String) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .get,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/auth-methods"
    )
  }
  
  static func listExternalAuths(_ collection: String, id: String) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .get,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/records/\(id)/external-auths"
    )
  }
  
  static func unlinkExternalAuth(_ collection: String, id: String, provider: OAuthProvider) -> Endpoint<[String: String]> {
    return Endpoint<[String: String]>(
      method: .delete,
      host: PocketBase<User>.host,
      path: "/api/collections/\(collection)/records/\(id)/external-auths/\(provider.rawValue)"
    )
  }
}
