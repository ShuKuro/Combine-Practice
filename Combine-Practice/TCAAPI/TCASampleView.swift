//
//  TCASampleView.swift
//  SwiftUI-Combine-TCA
//
//  Created by shuhei.kuroda on 2022/02/24.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Identifiable, Equatable {
  // same User struct
  var id: Int = 0
  var name: String = ""
  var age: Int = 0
  
}

enum AppAction {
  case viewAppear
  case buttonTapped
  case fetchUserResponse(Result<User, ProviderError>)
}

struct AppEnvironment {
  var userClient: UserClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .viewAppear:
    state.id = 0
    state.name = "reset"
    state.age = 0
    return .none
    
  case .buttonTapped:
    return environment.userClient.fetch()
      .receive(on: environment.mainQueue)
      .catchToEffect(AppAction.fetchUserResponse)
      
  case .fetchUserResponse(.success(let response)):
    state.id = response.id
    state.name = response.name
    state.age = response.age
    return .none
    
  case .fetchUserResponse(.failure):
    return .none
  }
}

struct TCASampleView: View {
  var store: Store<AppState, AppAction>
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Text(viewStore.state.name)
        
        Text("\(viewStore.state.age)")
        
        Button(action: {
          viewStore.send(.buttonTapped)
        }) {
          Text("Get UserInfo")
            .padding()
        }
      }
      .onAppear {
        viewStore.send(.viewAppear)
      }
    }
  }
}

struct TCASampleView_Previews: PreviewProvider {
  static var previews: some View {
    TCASampleView(
      store: Store(
        initialState: AppState(id: 0, name: "test user", age: 30),
        reducer: appReducer,
        environment: AppEnvironment(
          userClient: .mockPreview(),
          mainQueue: .main
        )
      )
    )
  }
}
