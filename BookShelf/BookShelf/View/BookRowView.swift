//
//  BookRowView.swift
//  BookShelf
//
//  Created by HoJoonKim on 11/11/25.
//
import SwiftUI

struct BookRowView: View {
    var book: Book
    
    var body: some View {
        HStack(alignment: .top) {
            Image(book.mediumCoverImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 90)
            
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text("by \(book.author)")
                    .font(.subheadline)
                
                HStack(alignment: .top) {
                    Text("\(book.pages) pages")
                        .font(.subheadline)
                    Spacer()
                    Text("ISBN: \(book.isbn)")
                        .font(.subheadline)
                }
                
            }
            
            Spacer()
        }
    }
}

#Preview {
    let books = Book.sampleBooks
    BookRowView(book: books[0])
}
