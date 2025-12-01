//
//  CanvasItem.swift
//  CanvasTestApp
//
//  Created by HoJoonKim on 12/1/25.
//

import SwiftUI
import SwiftData

enum CanvasItemType: Codable {
    case text
    case emoji
    case image
}

@Model
class CanvasItem {
    var id: UUID
    var type: CanvasItemType
    var content: String
    var imageData: Data?
    var x: Double
    var y: Double
    
    init(
        id: UUID = UUID(),
        type: CanvasItemType,
        content: String = "",
        imageData: Data? = nil,
        x: Double = 100,
        y: Double = 100
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.imageData = imageData
        self.x = x
        self.y = y
    }
}
