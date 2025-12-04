//
//  SlugApp.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 03/12/2025.
//

import SwiftUI
import WebKit

@main
struct SlugApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TabView {
                    SlugsView(viewModel: SlugsViewModel())
                        .tabItem {
                            Label("Slugs", systemImage: "list.bullet")
                        }

                    WebView(url: URL(string: "https://en.wikipedia.org/wiki/Slug"))
                        .tabItem {
                            Label("Info", systemImage: "network")
                        }
                }
                .id(id)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            id = UUID()
                        } label: {
                            Label("Clear", systemImage: "xmark")
                        }
                    }
                }
            }
        }
    }

    @State
    private var id: UUID = UUID()
}
