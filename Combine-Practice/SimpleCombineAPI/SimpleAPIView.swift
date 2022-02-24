//
//  SimpleAPIView.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/24.
//

import SwiftUI

struct SimpleAPIView: View {
  @StateObject var viewModel: SimpleAPIViewModel
  
  init(viewModel: SimpleAPIViewModel = SimpleAPIViewModel()) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
      VStack {
        Text(viewModel.user?.name ?? "user name")
        
        Text("\(viewModel.user?.age ?? 0) year old")
        
        Button(action: {
          viewModel.fetchUser()
        }) {
          Text("Get UserInfo")
            .padding()
        }
      }
      .onAppear {
        viewModel.clear()
      }
    }
}

struct SimpleAPIView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleAPIView()
    }
}
