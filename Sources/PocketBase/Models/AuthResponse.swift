//
//  AuthResponse.swift
//  
//
//  Created by zz129869523 on 2022/12/23.
//

import Foundation

public struct AuthResponse<UserModel: AuthModel>: Codable {
  public let token: String
  public let record: UserModel
  public let meta: Metadata?
  
  public struct Metadata: Codable {
    public let id: String
    public let name: String
    public let email: String
    public let username: String
    public let avatarUrl: String
  }
}
