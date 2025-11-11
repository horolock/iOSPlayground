//
//  ContentView.swift
//  BookShelf
//
//  Created by HoJoonKim on 11/11/25.
//

import SwiftUI

struct BookListView: View {
    var books: [Book]
    
    var body: some View {
        List(books) { book in
            BookRowView(book: book)
                .listStyle(.plain)
        }
    }
}



#Preview {
    BookListView(books: Book.sampleBooks)
}
