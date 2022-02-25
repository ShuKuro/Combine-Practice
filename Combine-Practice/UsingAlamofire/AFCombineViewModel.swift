//
//  CombineViewModel.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/18.
//

import Foundation
import Combine

class AFCombineViewModel: ObservableObject {
  @Published var user: User?
  var model = AFCombineModel()
  var anyCancellables = Set<AnyCancellable>()
  deinit {
    anyCancellables.removeAll()
  }
  
  func fetchUser() {
    model.fetchUser()
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .failure(let error):
          print(error.localizedDescription)
        case .finished:
          print("completion")
        }
      }, receiveValue: { user in
        self.user = user
      })
      .store(in: &anyCancellables)
  }
  
  func clear() {
    user = nil
  }
}
