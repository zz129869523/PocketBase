//
//  PostView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2022/12/29.
//

import SwiftUI
import PocketBase

struct PostsView: View {
  @EnvironmentObject var client: PocketBase<User>
  
  @State var recentsPosts: [Post] = []
  @State var showCreateNewPost: Bool = false
  
  var body: some View {
    NavigationStack {
      ReusablePostsView(posts: $recentsPosts)
        .environmentObject(client)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) {
          Button {
            showCreateNewPost = true
          } label: {
            Image(systemName: "plus")
              .font(.title3)
              .fontWeight(.semibold)
              .foregroundColor(.white)
              .padding()
              .background(.black, in: Circle())
          }
          .padding()
        }
        .navigationTitle("Post's")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
              SearchUserView()
                .environmentObject(client)
            } label: {
              Image(systemName: "magnifyingglass")
                .tint(.primary)
                .scaleEffect(0.9)
            }
          }
        }
    }
    .fullScreenCover(isPresented: $showCreateNewPost) {
      CreateNewPost()
    }
  }
}

struct PostsView_Previews: PreviewProvider {
  static var previews: some View {
    PostsView()
      .environmentObject(PocketBase<User>())
  }
}

