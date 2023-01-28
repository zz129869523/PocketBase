//
//  Post.swift
//  PocketBaseDemo
//
//  Created by zz129869523 on 2023/1/13.
//

import Foundation
import PocketBase

struct Post: BaseModel {
  var id: String?
  var collectionId: String?
  var collectionName: String?
  var created: String?
  var updated: String?
  var expand: PostExpand?
  
  var user: String
  var text: String = ""
  var images: [String] = []
  var liked: [String] = []
}

struct PostExpand: Codable {
  var user: User?
}

extension Post {
  static var mockPosts = [Post(id: "elkb4w1764tjnpw", collectionId: "1wi612c3xp75658", collectionName: "posts", created: "2023-01-21 06:39:56", updated: "2023-01-21 06:39:56", expand: PostExpand(user: User(id: "nk2l3yhrg9urcem", collectionId: "", collectionName: "user", created: "2023-01-21 06:39:56", updated: "2023-01-21 06:39:56", username: "user00001", verified: true, emailVisibility: true, email: "user00001@gmail.com", name: "使用者", avatar: nil)), user: "nk2l3yhrg9urcem", text: "hello", images: [])]
}
