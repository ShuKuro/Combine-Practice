//
//  SimpleAPIViewModel.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/24.
//

import Foundation
import Combine

class SimpleAPIViewModel: ObservableObject {
  @Published var user: User?
  let client = APIClient()
  var anyCancellables = Set<AnyCancellable>()
  deinit {
    anyCancellables.removeAll()
  }
  
  func fetchUser() {
    guard let url = URL(string: "https://run.mocky.io/v3/de739466-7439-41cb-b9b9-514448ab26ae") else { return }
    
    client.fetch(url: url)
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
