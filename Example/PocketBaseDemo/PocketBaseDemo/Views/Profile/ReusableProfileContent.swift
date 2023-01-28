//
//  ReusableProfileContent.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/19.
//

import SwiftUI
import PocketBase
import Kingfisher

struct ReusableProfileContent: View {
  var userProfile: User?
  
  @State var fetchPosts: [Post] = []
  
  var body: some View {
    ScrollView {
      LazyVStack {
        HStack(spacing: 12) {
          KFImage(getProfileUrl())
            .resizable()
            .cacheMemoryOnly()
            .placeholder {
              Image("NullProfile")
                .resizable()
                .scaledToFill()
                .padding()
                .background(Color.cyan.gradient)
                .clipShape(Circle())
                .frame(width: 100, height: 100)
            }
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: 100, height: 100)
          
          VStack(alignment: .leading) {
            Text(userProfile?.name ?? "No Name")
              .font(.title3)
              .fontWeight(.semibold)

            Text(userProfile?.username ?? "No Username")
              .font(.callout)
              .foregroundColor(.gray)
          }
          
          Spacer()
        }
        
        // MARK: Post's
        Text("Post's")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundColor(.primary)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 15)
        
        ReusablePostsView(userId: userProfile?.id, posts: $fetchPosts)
      }
      .padding(15)
    }
  }
  
  func getProfileUrl() -> URL? {
    guard let id = userProfile?.id,
          let avatar = userProfile?.avatar else {
      return nil
    }

    return PocketBase<User>.getFileUrl(id, "users", avatar, query: ["thumb": "100x100"])
  }
}

struct ReusableProfileContent_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      ReusableProfileContent()
        .navigationTitle("My Profile")
    }
  }
}
