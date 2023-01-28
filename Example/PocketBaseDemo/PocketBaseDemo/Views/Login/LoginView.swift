//
//  LoginView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/17.
//

import SwiftUI
import PocketBase

struct LoginView: View {
  @EnvironmentObject var client: PocketBase<User>
  @AppStorage("logStatus") var logStatus: Bool = false
  
  @State var identity: String = ""
  @State var password: String = ""
  
  @State var showRegisterView: Bool = false
  
  @State var isLoading: Bool = false
  @State var showAlert: Bool = false
  @State var alertMessage: String = ""
  
  
  var body: some View {
    VStack {
      Text("Welcome to PocketBase!")
        .font(.title.bold())
        .frame(maxWidth: .infinity)

      Image("pocketbase")
        .resizable()
        .scaledToFit()
        .cornerRadius(5)
        .padding(.horizontal, 60)
        .padding(.bottom)
      
      CustomTextField("Username or Email", text: $identity)
        .padding(.horizontal)
        .textContentType(.emailAddress)
      
      CustomSecureField("Password", text: $password)
        .padding(.horizontal)
        .textContentType(.password)
      
      Button(action: loginUser){
        Text("Login")
          .frame(maxWidth: .infinity)
          .foregroundColor(.white)
          .bold()
          .padding()
          .background(Color.blue.cornerRadius(5))
          .padding()
      }
      
      Button("Reset password?") {
        resetPassword()
      }
      .bold()
      
      Spacer()
      
      HStack {
        Text("Don't have an account?")
          .foregroundColor(.gray)
        
        Button("Register Now") {
          showRegisterView = true
        }
        .bold()
      }
      .font(.callout)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .contentShape(Rectangle())
    .onTapGesture {
      UIApplication.shared.endEditing()
    }
    .overlay {
      LoadingView(show: $isLoading)
    }
    // MARK: Register View VIA Sheets
    .fullScreenCover(isPresented: $showRegisterView) {
      RegisterView()
    }
    .alert(alertMessage, isPresented: $showAlert, actions: {})
  }
  
  func loginUser() {
    isLoading = true
    UIApplication.shared.endEditing()
    Task {
      if let dict = await client.collection("users").authWithPassword(identity, password) {
        if let err = try? ErrorResponse(dictionary: dict) {
          let errString = "\(err.message)\n\(err.data.first?.value.message ?? "")"
          await setAlert(errString)
        } else {
          // MARK: Login Successful
          isLoading = false
          logStatus = true
        }
      }
    }
  }
  
  func resetPassword() {
    isLoading = true
    Task {
      if let dict = await client.collection("users").requestPasswordReset(identity) {
        if let err = try? ErrorResponse(dictionary: dict) {
          let errString = "\(err.message)\n\(err.data.first?.value.message ?? "")"
          await setAlert(errString)
        }
      } else {
        await setAlert("Link Sent. (If mail is not registered, no letter will be sent.)")
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

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
      .environmentObject(PocketBase<User>())
  }
}
