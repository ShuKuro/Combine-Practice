//
//  APIClient.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/22.
//

import Foundation
import Combine
import Alamofire

class APIClient {
  let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
  }()
  
  var anyCancellables: Set<AnyCancellable> = []
  deinit {
    anyCancellables.removeAll()
  }
  
  func fetchUser(url: URL) -> Future<User, Error> {
    return Future { promise in
      let request = URLRequest(url: url)
      URLSession.shared
        .dataTaskPublisher(for: request)
        .map( { (data, response) in
          return data
        })
        .decode(type: User.self, decoder: self.decoder)
        .sink(receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            print(error.localizedDescription)
            promise(.failure(NetworkError.userError))
          case .finished:
            print("completion")
          }
        }, receiveValue: { user in
          promise(.success(user))
        })
        .store(in: &self.anyCancellables)
    }
  }
  
  func fetch<T>(url: URL) -> Future<T, Error> where T: Decodable {
    return Future { promise in
      let request = URLRequest(url: url)
      URLSession.shared
        .dataTaskPublisher(for: request)
        .map( { (data, response) in
          return data
        })
        .decode(type: T.self, decoder: self.decoder)
        .sink(receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            print(error.localizedDescription)
            promise(.failure(APIError.responseError))
          case .finished:
            print("completion")
          }
        }, receiveValue: { user in
          promise(.success(user))
        })
        .store(in: &self.anyCancellables)
    }
  }
}

enum NetworkError: Error {
  case userError
}


enum APIError: Error {
  case notFound
  case badStatus
  case responseError
}

extension Publisher {
  func asFuture() -> Future<Output, Failure> {
    return Future { promise in
      var ticket: AnyCancellable? = nil
      ticket = self.sink(
        receiveCompletion: {
          ticket?.cancel()
          ticket = nil
          switch $0 {
          case .failure(let error):
            promise(.failure(error))
          case .finished:
            // WHAT DO WE DO HERE???
            fatalError()
          }
        },
        receiveValue: {
          ticket?.cancel()
          ticket = nil
          promise(.success($0))
        })
    }
  }
}
