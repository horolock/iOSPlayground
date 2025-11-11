//
//  PersonViewModel.swift
//  ClosureDemo
//
//  Created by HoJoonKim on 11/11/25.
//

import Foundation
import Combine

class PersonViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    func save() {
        print("Save to dist")
    }
}
