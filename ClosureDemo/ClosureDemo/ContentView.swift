//
//  ContentView.swift
//  ClosureDemo
//
//  Created by HoJoonKim on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    @State var message = ""
    @State var dirty = false
    @StateObject private var viewModel = PersonViewModel()
    
    var body: some View {
        Form {
            Section("\(self.dirty ? "*" : "")Input fields") {
                TextField("First name", text: $viewModel.firstName)
                    .onChange(of: viewModel.firstName) { oldValue, newValue in
                        self.dirty = true
                    }
                TextField("Last name", text: $viewModel.lastName)
                    .onChange(of: viewModel.lastName) { oldValue, newValue in
                        self.dirty = true
                    }
            }
            .onSubmit {
                viewModel.save()
            }
        }
    }
}

#Preview {
    ContentView()
}
