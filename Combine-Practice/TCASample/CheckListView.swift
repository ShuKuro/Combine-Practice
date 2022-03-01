//
//  CheckListView.swift
//  Combine-Practice
//
//  Created by Shuhei Kuroda on 2022/02/26.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct CheckListState: Equatable {
  var checks: IdentifiedArrayOf<CheckState> = []
  var selectedCount = 0
}

enum CheckListAction {
  case onAppear
  case check(index: UUID, action: CheckRowAction)
  case addButtonTapped
  case updateCountButton
}

struct CheckListEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
//  var uuid: () -> UUID
}

let checkListReducer = Reducer<CheckListState, CheckListAction, CheckListEnvironment>.combine(
  checkRowReducer.forEach(
    state: \.checks,
    action: /CheckListAction.check(index:action:),
    environment: { _ in CheckRowEnvironment() }
  ), Reducer { state, action, environment in
    switch action {
    case .onAppear:
      // TODO: APIで取得予定
      state.checks = [
        CheckState(id: UUID(), isChecked: false, title: "Buy MacBook Pro 14inch", memo: "Apple M1 Max"),
        CheckState(id: UUID(), isChecked: false, title: "Buy ice cream", memo: "31"),
        CheckState(id: UUID(), isChecked: true, title: "Check E-Mail", memo: "Reply")
      ]
      
      return Effect(value: .updateCountButton)
      
//    case .check(index: _, action: .checkboxTapped):
//      return .none

    case .check(index: let index, action: let action):
      return Effect(value: .updateCountButton)
      
    case .addButtonTapped:
      // TODO: 追加画面実装
      return .none
      
    case .updateCountButton:
      state.selectedCount = state.checks.filter { $0.isChecked }.count
      return .none
    }
  }
)

struct CheckListView: View {
  let store: Store<CheckListState, CheckListAction>
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      ZStack(alignment: .bottomTrailing) {
        List {
          ForEachStore(
            self.store.scope(state: \.checks, action: CheckListAction.check(index:action:)),
            content: CheckRowView.init(store:)
          )
        }
        .navigationTitle("Todos")
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Add") {
               viewStore.send(.addButtonTapped)
            }
          }
        }
        
        Button(action: {
          // TODO: チェックを外す
        }) {
          Group {
            if viewStore.selectedCount > 0 {
              Text("\(viewStore.selectedCount)")
            } else {
              Image(systemName: "star.fill")
            }
          }
          .foregroundColor(.black)
          .font(.system(size: 20))
          .frame(width: 55, height: 55)
          .background(Color.yellow)
          .clipShape(Circle())
          .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
        }
        
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
    
  }
}

struct CheckListView_Previews: PreviewProvider {
    static var previews: some View {
        CheckListView(
          store: Store(
            initialState: CheckListState(),
            reducer: checkListReducer,
            environment: CheckListEnvironment(
              mainQueue: .main
            )
          )
        )
    }
}
