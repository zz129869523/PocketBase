//
//  Auth.swift
//  
//
//  Created by zz129869523 on 2022/12/23.
//

import Foundation

public struct AuthMethods: Codable {
  public let usernamePassword: Bool
  public let emailPassword: Bool
  public let authProviders: [AuthProvider]
}

public struct AuthProvider: Codable {
  public let name: String
  public let state: String
  public let codeVerifier: String
  public let codeChallenge: String
  public let codeChallengeMethod: String
  public let authUrl: URL
}

public struct OAuth2Requset: Codable {
  public var provider: OAuthProvider
  public var code: String
  public var codeVerifier: String
  public var redirectUrl: String
  public var createData: [String: String]?
}

public enum OAuthProvider: String, Codable {
  case apple
  case google
  case facebook
  case twitter
  case github
  case gitlab
  case discord
  case microsoft
  case spotify
  case kakao
  case twitch
}

public struct AuthMethod: Codable {
  public let id: UUID
  public let created: String
  public let updated: String
  public let userId: UUID
  public let provider: String
  public let providerId: String
}
