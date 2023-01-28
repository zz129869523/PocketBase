//
//  ProfileView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/17.
//

import SwiftUI
import PocketBase

struct ProfileView: View {
  @EnvironmentObject var client: PocketBase<User>
  
  @AppStorage("logStatus") var logStatus: Bool = false
  
  @State var userProfile: User?
  
  @State var isLoading: Bool = false
  @State var showAlert: Bool = false
  @State var alertMessage: String = ""
  
  var body: some View {
    NavigationStack {
      VStack {
        if userProfile != nil {
          ReusableProfileContent(userProfile: userProfile)
            .refreshable {
              // MARK: Update User Data
              await fetchUserData()
            }
        } else {
          ProgressView()
        }
      }
      .navigationTitle("My Profile")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            // MARK: Two action's
            // 1. Logout
            // 2. Delete Account
            Button("Logout", action: logoutUser)
            Button("Delete Account", role: .destructive, action: deleteAccount)
          } label: {
            Image(systemName: "ellipsis")
          }
        }
      }
      .task {
        // MARK: Initial Fetch
        guard userProfile == nil else { return }
        await fetchUserData()
      }
    }
    .overlay {
      LoadingView(show: $isLoading)
    }
    .alert(alertMessage, isPresented: $showAlert, actions: {})
  }
  
  // MARK: Fetch User Data
  func fetchUserData() async {
    Task {
      guard let userID = client.authStore.model?.id else {
        await setAlert("Fetch User Data Cannot Get ID")
        return
      }
      
      let record: User? = await client.collection("users").getOne(id: userID)
      client.authStore.model = record
      userProfile = record
    }
  }
  
  // MARK: Logging User Out
  func logoutUser() {
    client.authStore.clear()
    logStatus = false
//    userProfile = nil
  }
  
  // MARK: Delete User Account
  func deleteAccount() {
    isLoading = true
    Task {
      guard let userId = client.authStore.model?.id else {
        await setAlert("Cannot Get ID")
        return
      }
      
      // MARK: delete user
      if let dict = await client.collection("users").delete(userId) {
        if let err = try? ErrorResponse(dictionary: dict) {
          await setAlert(err.message)
        }
      } else {
        await setAlert("Account Deleted")
        logoutUser()
      }
    }
  }
  
  func setAlert(_ message: String) async {
    await MainActor.run(body: {
      alertMessage = message
      showAlert = true
      isLoading = false
    })
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
      .environmentObject(PocketBase<User>())
  }
}

