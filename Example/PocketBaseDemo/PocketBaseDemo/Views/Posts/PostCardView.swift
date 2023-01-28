//
//  PostCardView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/23.
//

import SwiftUI
import PocketBase
import Kingfisher

struct PostCardView: View {
  @EnvironmentObject var client: PocketBase<User>
  @AppStorage("io.pocketbase.identity") var userId = "" // Default username key is "io.pocketbase.identity"
  
  var post: Post
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      KFImage(getAvatarUrl())
        .resizable()
        .fade(duration: 0.2)
        .cacheMemoryOnly()
        .aspectRatio(contentMode: .fill)
        .frame(width: 35, height: 35)
        .clipShape(Circle())
      
      VStack(alignment: .leading) {
        Text(post.expand?.user?.name ?? "")
          .font(.callout)
          .fontWeight(.semibold)
        
        + Text(" @\(post.expand?.user?.username ?? "")")
          .font(.callout)
          .foregroundColor(.gray)
        
        Text(post.created ?? "")
          .font(.caption2)
          .foregroundColor(.gray)
        
        Text(post.text)
          .textSelection(.enabled)
          .padding(.vertical, 8)
        
        // Post Image If Any
        if !post.images.isEmpty, let id = post.id {
          GeometryReader {
            let size = $0.size
            TabView {
              ForEach(post.images, id: \.self) { image in
                KFImage(client.getFileUrl(id, "posts", image))
                  .resizable()
                  .cacheMemoryOnly()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: size.width)
              }
            }
            .tabViewStyle(PageTabViewStyle())
          }
          .frame(height: 200)
          .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        
        PostInteraction()
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .topTrailing) {
      if post.expand?.user?.id == userId {
        Menu {
          Button("Delete Post", role: .destructive, action: deletePost)
        }label: {
          Image(systemName: "ellipsis")
            .font(.caption)
            .rotationEffect(.degrees(-90))
            .foregroundColor(.primary)
            .padding(8)
            .containerShape(Rectangle())
        }
        .offset(x: 8)
      }
    }
  }
  
  func getAvatarUrl() -> URL? {
    guard let id = post.expand?.user?.id,
          let avatar = post.expand?.user?.avatar else {
      return nil
    }

    return PocketBase<User>.getFileUrl(id, "users", avatar, query: ["thumb": "100x100"])
  }
  
  @ViewBuilder
  func PostInteraction() -> some View {
    HStack {
      Button(action: likePost){
        Image(systemName: post.liked.contains("\(userId)") ? "heart.fill" : "heart")
      }

      Text("\(post.liked.count)")
        .font(.caption)
        .foregroundColor(.gray)
    }
    .foregroundColor(.primary)
    .padding(.vertical, 8)
  }
  
  func likePost() {
    Task {
      guard let postId = post.id else {
        print("post not id.")
        return
      }

      // Update like to pocketbase
      let record = await client.collection("posts").update(postId, body: [post.liked.contains(userId) ? "liked-" : "liked+": userId])
      if let err = try? ErrorResponse(dictionary: record) {
        print("Like post error. \(err.message)")
      }
    }
  }
  
  /// - Delete Post
  func deletePost() {
    Task {
      guard let postId = post.id else {
        print("Delete post have not id.")
        return
      }
      
      let record = await client.collection("posts").delete(postId)
      if let err = try? ErrorResponse(dictionary: record) {
        print("Delete post error. \(err.message)")
      }
    }
  }
}
