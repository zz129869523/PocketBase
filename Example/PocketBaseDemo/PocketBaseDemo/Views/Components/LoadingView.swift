//
//  LoadingView.swift
//  PocketBaseDemo
//
//  Created by 陳勇辰 on 2023/1/18.
//

import SwiftUI

struct LoadingView: View {
  @Binding var show: Bool
  
  var body: some View {
    ZStack {
      if show {
        Group {
          Rectangle()
            .fill(.black.opacity(0.25))
            .ignoresSafeArea()
          
          ProgressView()
            .padding(15)
            .background(.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
      }
    }
  }
}

struct LoadingView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingView(show: .constant(true))
  }
}
