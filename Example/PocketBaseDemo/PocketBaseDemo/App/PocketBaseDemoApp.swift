//
//  PocketBaseDemoApp.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2022/12/29.
//

import SwiftUI
import PocketBase

@main
struct PocketBaseDemoApp: App {
  @AppStorage("logStatus") var logStatus: Bool = false
  @StateObject var client = PocketBase<User>()
  
  var body: some Scene {
    WindowGroup {
      if logStatus {
        MainView()
          .environmentObject(client)
      } else {
        LoginView()
          .environmentObject(client)
      }
    }
  }
}
