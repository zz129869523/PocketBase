//
//  RegisterView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/18.
//

import SwiftUI
import PhotosUI
import PocketBase

struct RegisterView: View {
  @EnvironmentObject var client: PocketBase<User>
  @Environment(\.dismiss) var dismiss
  
  @AppStorage("logStatus") var logStatus: Bool = false
  
  @State var username: String = ""
  @State var name: String = ""
  @State var email: String = ""
  @State var password: String = ""
  @State var passwordAgain: String = ""
  @State var avatarData: Data?
  
  @State var showImagePicker: Bool = false
  @State var photoItem: PhotosPickerItem?
  
  @State var isLoading: Bool = false
  @State var showAlert: Bool = false
  @State var alertMessage: String = ""

  var body: some View {
    VStack {
      Text("Register to PocketBase!")
        .font(.title.bold())
        .frame(maxWidth: .infinity)
      
      ZStack {
        if let avatarData, let image = UIImage(data: avatarData) {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        } else {
          Image("NullProfile")
            .resizable()
            .scaledToFill()
            .padding()
            .background(Color.cyan.gradient)
            .clipShape(Circle())
            .frame(width: 100, height: 100)
        }
      }
      .frame(width: 85, height: 85)
      .clipShape(Circle())
      .contentShape(Circle())
      .onTapGesture {
        showImagePicker = true
      }
      
      CustomTextField("Username", text: $username)
        .padding(.horizontal)
        .textContentType(.username)
      
      CustomTextField("Name", text: $name)
        .padding(.horizontal)
        .textContentType(.name)
      
      CustomTextField("Email", text: $email)
        .padding(.horizontal)
        .textContentType(.emailAddress)
      
      CustomSecureField("Password", text: $password)
        .padding(.horizontal)
        .textContentType(.password)
      
      CustomSecureField("Password Again", text: $passwordAgain)
        .padding(.horizontal)
        .textContentType(.password)
      
      Button(action: registerUser){
        Text("Register")
          .frame(maxWidth: .infinity)
          .foregroundColor(.white)
          .bold()
          .padding()
          .background(Color.blue.cornerRadius(5))
          .padding()
      }

      Spacer()
      
      HStack {
        Text("Already have an account?")
          .foregroundColor(.gray)
        
        Button("Login Now") {
          dismiss()
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
    .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
    .onChange(of: photoItem) { newValue in
      if let newValue {
        Task {
          do {
            guard let imageData = try await newValue.loadTransferable(type: Data.self),
                  let image = UIImage(data: imageData),
                  let compressedImageData = image.jpegData(compressionQuality: 0.5) else {
              return
            }
            await MainActor.run(body: {
              avatarData = compressedImageData
            })
          } catch {
            print("PhotosPicker Error: \(error.localizedDescription)")
          }
        }
      }
    }
    .alert(alertMessage, isPresented: $showAlert, actions: {})
  }
  
  func registerUser() {
    isLoading = true
    UIApplication.shared.endEditing()
    Task {
      var file: File?
      if let avatarData {
        file = File(mimeType: "", filename: username, data: avatarData)
      }
      
      let request = RegisterRequest(
        username: username,
        name: name,
        email: email,
        password: password,
        passwordConfirm: passwordAgain,
        avatar: file
      )
      
      // MARK: Create User
      if let record = await client.collection("users").create(request) {
        if let err = try? ErrorResponse(dictionary: record) {
          let errString = "\(err.message)\n\(err.data.first?.value.message ?? "")"
          await setAlert(errString)
        } else {
          // MARK: Send Request Verification
          if let dict = await client.collection("users").requestVerification(email) {
            if let err = try? ErrorResponse(dictionary: dict) {
              await setAlert(err.message)
            }
          } else {
            // MARK: Create User Successful
            // MARK: Let's Login
            loginUser()
          }
        }
      }
    }
  }
  
  func loginUser() {
    Task {
      if let dict = await client.collection("users").authWithPassword(email, password) {
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
  
  func setAlert(_ message: String) async {
    await MainActor.run(body: {
      alertMessage = message
      showAlert = true
      isLoading = false
    })
  }
}

struct RegisterView_Previews: PreviewProvider {
  static var previews: some View {
    RegisterView()
      .environmentObject(PocketBase<User>())
  }
}

fileprivate struct RegisterRequest: Codable, MultipartFormData {
  var username: String
  var name: String
  var email: String
  var password: String
  var passwordConfirm: String
  var avatar: File?
}
