//
//  AFCombineModel.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/22.
//

import Foundation
import Combine

class AFCombineModel {

  func fetchUser() -> AnyPublisher<User, Error>  {
    let urlStr = "https://run.mocky.io/v3/de739466-7439-41cb-b9b9-514448ab26ae"
    
    return APIAccessPublisher.publish(urlStr).eraseToAnyPublisher()
  }
}
