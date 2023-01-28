//
//  CustomSecureField.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/17.
//

import SwiftUI

struct CustomSecureField: View {
  @Binding var text: String
  @State private var isSecure: Bool = true
  @State private var isFocused = false
  
  @State var isTapped: Bool = false
  @State var isColorChange: Bool = false
  @FocusState private var isFocusedState: Bool
  private var title: String = ""
  
  init(_ title: String, text: Binding<String>) {
    self.title = title
    _text = text
  }
  
  var body: some View {
    VStack {
      ZStack(alignment: .trailing) {
        MyTextField(text: $text, isSecure: $isSecure, isFocused: $isFocused)
        .onChange(of: isFocused) { newValue in
          if newValue {
            withAnimation(.interactiveSpring(response: 0.15)) {
              isTapped = true
              isColorChange = true
            }
          } else {
            withAnimation(.interactiveSpring(response: 0.15)) {
              isColorChange = false
              
              if text == "" {
                isTapped = false
              }
            }
          }
        }
        .frame(height: 20)
        .padding(.top)
        .background (
          Text(title)
            .scaleEffect(isTapped ? 0.8 : 1)
            .offset(x: isTapped ? -7 : 0, y: isTapped ? -15 : 0)
            .foregroundColor(.gray)
          
          , alignment: .leading
        )
        .focused($isFocusedState)
        .onTapGesture {
          isFocusedState = true
        }
        
        Button(action: {
          isSecure.toggle()
        }, label: {
          if text != "" {
            Image(systemName: self.isSecure ? "eye.slash.fill" : "eye.fill")
              .foregroundColor(.gray)
          }
        })
      }
    }
    .padding(.vertical, 16)
    .padding(.horizontal)
    .background(Color.gray.opacity(isColorChange ? 0.18: 0.1))
    .cornerRadius(5)
    .contentShape(Rectangle())
  }
}

struct CustomSecureField_Previews: PreviewProvider {
  static var previews: some View {
    CustomSecureField("Text", text: .constant(""))
  }
}

struct MyTextField: UIViewRepresentable {

    // 1
    @Binding var text: String
    @Binding var isSecure: Bool
    @Binding var isFocused: Bool

     // 2
    func makeUIView(context: UIViewRepresentableContext<MyTextField>) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
        return tf
    }

    func makeCoordinator() -> MyTextField.Coordinator {
        return Coordinator(text: $text, isFocused: $isFocused)
    }

    // 3
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isSecure
    }

    // 4
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool

        init(text: Binding<String>, isFocused: Binding<Bool>) {
            _text = text
            _isFocused = isFocused
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
               self.isFocused = true
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFocused = false
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
    }
}
