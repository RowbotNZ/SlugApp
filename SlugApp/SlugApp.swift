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
                    SlugsView(
                        viewModelHolder: ViewModelHolder(
                            viewModel: SlugsViewModel.init(lifetimeTaskScheduler:)
                        )
                    )
                    .tabItem {
                        Label("Slugs", systemImage: "list.bullet")
                    }

                    WebView(url: URL(string: "https://en.wikipedia.org/wiki/Slug"))
                        .tabItem {
                            Label("Info", systemImage: "network")
                        }
                }
                .transition(.blurReplace)
                .id(id)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                id = UUID()
                            }
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
