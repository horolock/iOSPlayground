//
//  BookShelfApp.swift
//  BookShelf
//
//  Created by HoJoonKim on 11/11/25.
//

import SwiftUI

@main
struct BookShelfApp: App {
    var body: some Scene {
        WindowGroup {
            BookListView(books: Book.sampleBooks)
        }
    }
}
