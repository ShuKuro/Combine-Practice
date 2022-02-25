//
//  ContentView.swift
//  Combine-Practice
//
//  Created by Shuhei Kuroda on 2022/02/20.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink("API with Combine") {
          SimpleAPIView()
        }
        
        NavigationLink("API with Combine and Alamofire") {
          AFCombineView()
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
