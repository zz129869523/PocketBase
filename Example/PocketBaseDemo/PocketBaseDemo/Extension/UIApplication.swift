//
//  UIApplication.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/18.
//

import SwiftUI

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
