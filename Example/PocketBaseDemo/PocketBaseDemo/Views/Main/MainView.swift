//
//  MainView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/17.
//

import SwiftUI
import PocketBase

struct MainView: View {
  var body: some View {
    TabView {
      PostsView()
        .tabItem {
          Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
        }
      
      ProfileView()
        .tabItem {
          Image(systemName: "person.circle")
        }
    }
    // Changing Tab Label Tint to Primary
    .tint(.primary)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
