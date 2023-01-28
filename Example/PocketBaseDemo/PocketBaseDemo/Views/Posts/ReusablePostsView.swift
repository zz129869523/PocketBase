//
//  ReusablePostsView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/22.
//


import SwiftUI
import PocketBase

struct ReusablePostsView: View {
  @EnvironmentObject var client: PocketBase<User>
  
  var userId: String?
  @Binding var posts: [Post]
  
  @State private var isFetching: Bool = true
  
  // Pagination
  @State private var pagination: Post?
  
  var body: some View {
    ScrollView {
      LazyVStack {
        if isFetching {
          ProgressView()
            .padding(.top, 30)
        } else {
          if posts.isEmpty {
            Text("No Post's Found")
              .font(.caption)
              .foregroundColor(.gray)
              .padding(.top, 30)
          } else {
            Posts()
          }
        }
      }
      .padding(.horizontal)
    }
    .refreshable {
      isFetching = true
      posts.removeAll()
      pagination = nil
      await fetchPosts()
    }
    .task {
      await subscribePost()
      
      guard posts.isEmpty else { return }
      await fetchPosts()
    }
  }
  
  @ViewBuilder
  func Posts() -> some View {
    ForEach(posts) { post in
      PostCardView(post: post)
        .environmentObject(client)
        .onAppear {
          // When Last Post Appears, Fetch New Post. (If There)
          if post.id == posts.last?.id && pagination != nil {
            Task { await fetchPosts() }
          }
        }
      Divider()
        .padding(.horizontal, -15)
    }
  }
  
  func fetchPosts() async {
    Task {
      var filter = ""
      
      if let userId {
        filter = "user = '\(userId)'"
      }
      
      if let pagination, let id = pagination.id, let created = pagination.created {
        if userId != nil { filter += " && " }
        filter += "created <= '\(created)' && id != '\(id)'"
      }
      
      // Get posts
      self.posts += await client.collection("posts").getFullList(batch: 5, filter: filter, sort: "-created", expand: "user")
      
      // Fetch finish
      pagination = posts.last
      isFetching = false
    }
  }
  
  func subscribePost() async {
    Task {
      client.collection("posts").subscribe("*") { dict in
        if let result: Event<Post> = try? Utils.dictionaryToStruct(dictionary: dict ?? [:]) {
          guard userId == nil || userId == result.record.user else { return }
          
          switch result.action {
          case .create:
            Task {
              // Get user by userId because subscribe cannot yet join expand.
              if let user: User = await client.collection("users").getOne(id: result.record.user) {
                var post = result.record
                post.expand?.user = user
                withAnimation(.interactiveSpring(response: 0.3)) {
                  self.posts.insert(post, at: 0)
                }
              }
            }
          case .update:
            if let row = self.posts.firstIndex(where: { $0.id == result.record.id }) {
              Task {
                // Get user by userId because subscribe cannot yet join expand.
                if let user: User = await client.collection("users").getOne(id: result.record.user) {
                  var post = result.record
                  post.expand?.user = user
                  withAnimation(.interactiveSpring(response: 0.3)) {
                    self.posts[row] = post
                  }
                }
              }
            }
          case .delete:
            withAnimation(.interactiveSpring(response: 0.3)) {
              self.posts = self.posts.filter { $0.id != result.record.id }
            }
          }
        }
      }
    }
  }
}

struct ReusablePostsView_Previews: PreviewProvider {
  static var previews: some View {
    ReusablePostsView(posts: .constant(Post.mockPosts))
      .environmentObject(PocketBase<User>())
  }
}

