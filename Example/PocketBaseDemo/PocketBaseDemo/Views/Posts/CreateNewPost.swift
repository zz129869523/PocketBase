//
//  CreateNewPost.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/19.
//

import SwiftUI
import PhotosUI
import PocketBase

struct CreateNewPost: View {
  @EnvironmentObject var client: PocketBase<User>
  @Environment(\.dismiss) var dismiss
  
  @State var postText: String = ""
  @State var postImages: [Data] = []
  
  @State var showImagePicker: Bool = false
  @State var photoItems: [PhotosPickerItem] = []
  
  @State var isLoading: Bool = false
  @State var showAlert: Bool = false
  @State var alertMessage: String = ""
  
  var body: some View {
    VStack {
      // MARK: Header
      HStack {
        Menu {
          Button("Cancel", role: .destructive) {
            dismiss()
          }
        } label: {
          Text("Cancel")
            .font(.callout)
            .foregroundColor(.gray)
        }
        
        Spacer()
        
        Button(action: createPost){
          Text("Post")
            .font(.callout)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
            .background(.black, in: Capsule())
            .opacity(postText == "" ? 0.5 : 1)
        }
        .disabled(postText == "")
      }
      .padding(.horizontal, 15)
      .padding(.vertical, 10)
      .background(
        Rectangle()
          .fill(.gray.opacity(0.05))
          .ignoresSafeArea()
      )
      
      // MARK: Display Image
      ScrollView {
        VStack {
          TextField("What's happening?", text: $postText, axis: .vertical)
          
          ForEach(0 ..< postImages.count, id: \.self) { i in
            if let image = UIImage(data: postImages[i]) {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
          }
        }
        .padding(15)
      }
      
      Divider()
      
      HStack {
        Button {
          showImagePicker = true
        } label: {
          Image(systemName: "photo.on.rectangle")
            .font(.title3)
          
        }
      }
      .foregroundColor(.primary)
      .padding(.horizontal, 15)
      .padding(.vertical, 10)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .overlay {
      LoadingView(show: $isLoading)
    }
    .alert(alertMessage, isPresented: $showAlert, actions: {})
    .photosPicker(isPresented: $showImagePicker, selection: $photoItems, maxSelectionCount: 5)
    .onChange(of: photoItems) { newValues in
      if newValues.count != 0 {
        postImages = []
        Task {
          for newValue in newValues {
            if let rawImageData = try? await newValue.loadTransferable(type: Data.self),
               let image = UIImage(data: rawImageData),
               let compressedImageData = image.jpegData(compressionQuality: 0.5) {
              await MainActor.run(body: {
                postImages.append(compressedImageData)
              })
            }
          }
        }
      }
    }
    
  }
  
  func createPost() {
    isLoading = true
    UIApplication.shared.endEditing()
    
    Task {
      guard let id = client.authStore.model?.id else {
        await setAlert("userID is not exist")
        return
      }
      
      var files: [File] = []
      for (i, imageData) in postImages.enumerated() {
        files.append(File(mimeType: "", filename: "post_img\(i+1)", data: imageData))
      }
      
      let request = PostRequest(
        user: id,
        text: postText,
        images: files.isEmpty ? nil : files
      )
      
      if let record = await client.collection("posts").create(request) {
        if let err = try? ErrorResponse(dictionary: record) {
          print(err)
          await setAlert("\(err.message)\n\(err.data.first?.value.message ?? "")")
        } else {
          if let _: Post = try? Utils.dictionaryToStruct(dictionary: record) {
            // MARK: Create Successful
            dismiss()
          }
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

struct CreateNewPost_Previews: PreviewProvider {
  static var previews: some View {
    CreateNewPost()
      .environmentObject(PocketBase<User>())
  }
}

fileprivate struct PostRequest: Identifiable, Codable, MultipartFormData {
  var id: String?
  var user: String
  var text: String
  var images: [File]?
}
