//
//  CanvasView.swift
//  CanvasTestApp
//
//  Created by HoJoonKim on 12/1/25.
//

import SwiftUI
import SwiftData

struct CanvasView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var items: [CanvasItem]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.gray.opacity(0.1).ignoresSafeArea()
                
                // Canvas Items
                ForEach(items) { item in
                    ItemView(item: item)
                }
            }
            .navigationTitle("My Canvas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button("Add Text") { addItem(type: .text) }
                        Button("Add Emoji") { addItem(type: .emoji) }
                    }
                }
            }
        }
    }
    
    func addItem(type: CanvasItemType) {
        let newItem = CanvasItem(
            type: type,
            content: type == .text ? "Hello" : "😎",
            x: 150,
            y: 300
        )
        modelContext.insert(newItem)
    }
}


struct ItemView: View {
    @Bindable var item: CanvasItem
    
    var body: some View {
        VStack {
            if item.type == .image,
               let data = item.imageData,
               let uiImage = UIImage(data: data) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                
            } else {
                Text(item.content)
                    .font(.system(size: 40))
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 2)
            }
        }
        .position(x: item.x, y: item.y)
        .gesture(
            DragGesture()
                .onChanged({ value in
                    item.x = value.location.x
                    item.y = value.location.y
                })
        )
    }
}
