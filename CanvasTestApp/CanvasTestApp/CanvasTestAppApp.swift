//
//  CanvasTestAppApp.swift
//  CanvasTestApp
//
//  Created by HoJoonKim on 12/1/25.
//

import SwiftUI
import SwiftData

@main
struct CanvasTestAppApp: App {
    var body: some Scene {
        WindowGroup {
            CanvasView()
                .modelContainer(for: [CanvasItem.self])
        }
    }
}
