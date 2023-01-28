//
//  User.swift
//  
//
//  Created by zz129869523 on 2022/12/23.
//

import Foundation

public struct User: AuthModel {
  public var id: String?
  public var collectionId: String?
  public var collectionName: String?
  public var created: String?
  public var updated: String?
  public var username: String?
  public var verified: Bool?
  public var emailVisibility: Bool?
  public var email: String?
  public var name: String?
  public var avatar: String?
  
  public init(id: String? = nil,
              collectionId: String? = nil,
              collectionName: String? = nil,
              created: String? = nil,
              updated: String? = nil,
              username: String? = nil,
              verified: Bool? = nil,
              emailVisibility: Bool? = nil,
              email: String? = nil,
              name: String? = nil,
              avatar: String? = nil
  ) {
    self.id = id
    self.collectionId = collectionId
    self.collectionName = collectionName
    self.created = created
    self.updated = updated
    self.username = username
    self.verified = verified
    self.emailVisibility = emailVisibility
    self.email = email
    self.name = name
    self.avatar = avatar
  }
}

public extension User {
  init(dictionary: [String: Any]?) throws {
    self = try JSONDecoder().decode(Self.self, from: JSONSerialization.data(withJSONObject: dictionary ?? [:]))
  }
}

public protocol BaseModel: Codable, Identifiable {
  var id: String? { get set }
  var collectionId: String? { get set }
  var collectionName: String? { get set }
  var created: String? { get set }
  var updated: String? { get set }
}

public protocol AuthModel: BaseModel {
  var id: String? { get set }
  var collectionId: String? { get set }
  var collectionName: String? { get set }
  var created: String? { get set }
  var updated: String? { get set }
  var username: String? { get set }
  var verified: Bool? { get set }
  var emailVisibility: Bool? { get set }
  var email: String? { get set }
}
