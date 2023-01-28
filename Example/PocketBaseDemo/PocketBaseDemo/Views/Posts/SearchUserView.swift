//
//  SearchUserView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/25.
//

import SwiftUI
import PocketBase

struct SearchUserView: View {
  @EnvironmentObject var client: PocketBase<User>
  @Environment(\.dismiss) var dismiss
  
  @State var fetchUsers: [User] = []
  @State var searchText: String = ""
  
  var body: some View {
    List(fetchUsers) { user in
      NavigationLink {
        ReusableProfileContent(userProfile: user)
      } label: {
        Text(user.username ?? "")
          .font(.callout)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .listStyle(.plain)
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("Search User")
    .searchable(text: $searchText)
    .onChange(of: searchText) { newValue in
      if newValue.isEmpty {
        fetchUsers = []
      } else {
        Task { await fetchUsers() }
      }
    }
  }
  
  func fetchUsers() async {
    Task {
      fetchUsers = await client.collection("users").getFullList(filter: "username ?~ '\(searchText)'")
    }
  }
}

struct SearchUserView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      SearchUserView()
        .environmentObject(PocketBase<User>())
    }
  }
}
