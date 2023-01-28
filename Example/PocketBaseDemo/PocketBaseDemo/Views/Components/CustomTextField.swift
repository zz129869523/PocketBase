//
//  CustomTextField.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/17.
//

import SwiftUI

struct CustomTextField: View {
  @Binding var text: String
  @State var isTapped: Bool = false
  @State var isColorChange: Bool = false
  @FocusState private var isFocused: Bool
  private var title: String = ""
  
  init(_ title: String, text: Binding<String>) {
    self.title = title
    _text = text
  }
  
  var body: some View {
    VStack {
      TextField("", text: $text, onEditingChanged: { editingChanged in
        if editingChanged {
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
      })
      .padding(.top)
      .background (
        Text(title)
          .scaleEffect(isTapped ? 0.8 : 1)
          .offset(x: isTapped ? -7 : 0, y: isTapped ? -15 : 0)
          .foregroundColor(.gray)
        
        , alignment: .leading
      )
      .focused($isFocused)
      .onTapGesture {
        isFocused = true
      }
    }
    .padding(.vertical, 16)
    .padding(.horizontal)
    .background(Color.gray.opacity(isColorChange ? 0.18: 0.1))
    .cornerRadius(5)
    .contentShape(Rectangle())
  }
}

struct CustomTextField_Previews: PreviewProvider {
  static var previews: some View {
    CustomTextField("Text", text: .constant(""))
  }
}
