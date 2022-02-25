//
//  ApiAccessPublisher.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/22.
//

import Foundation
import Combine
import Alamofire


struct APIAccessPublisher {
  private static let successRange = 200..<300
  private static let contentType = "application/json"
  static let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return jsonDecoder
  }()
   
  static func publish<V>(_ urlString: String) -> Future<V, Error> where V: Codable {
     
    return Future { promise in
      guard let url = URL(string: urlString) else {
        return promise(.failure(AFError.invalidURL(url: urlString)))
      }
      
      let api = ApiSessionManager.shared
        .request(url)
        .validate(statusCode: successRange)
        .validate(contentType: [self.contentType])
        .responseData { response in
          switch response.result {
          case .success:
            do {
              if let data = response.data {
//                print("success : \(String(describing: String(data: data, encoding: .utf8))) path: \(url)")
                let json = try self.decoder.decode(V.self, from: data)
                promise(.success(json))
              } else {
                promise(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
              }

            } catch {
              promise(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
            }
          case .failure:
            if let data = response.data {
//              print("failure : \(String(describing: String(data: data, encoding: .utf8))) path: \(url)")
            }
            promise(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
          }
        }
      api.resume()
    }
  }
}

class ApiSessionManager: Session {
    static let shared: ApiSessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 1000
        
        let interceptor = Interceptor(retriers: [RetryPolicy(retryLimit: 3)])
        let manager = ApiSessionManager(configuration: configuration, interceptor: interceptor)
        return manager
    }()

    func request(_ url: URL) -> Alamofire.DataRequest {
        let request = URLRequest.init(
          url: url,
          cachePolicy: .reloadIgnoringLocalCacheData,
          timeoutInterval: 10.0
        )
        return self.request(request)
    }
}
