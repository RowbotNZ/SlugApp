//
//  SlugApp.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 03/12/2025.
//

import SwiftUI
import WebKit

import LifetimeProxy
import TaskScheduler

@main
struct SlugApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                TabView {
                    SlugsLifetimeTabView()
                        .tabItem {
                            Label("Persistent", systemImage: "infinity")
                        }

                    SlugsOnScreenTabView()
                        .tabItem {
                            Label("On Screen", systemImage: "eye")
                        }

                    WebView(
                        url: URL(string: "https://en.wikipedia.org/wiki/Slug")
                    )
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

extension SlugApp {
    /// Scopes the run context to the view model's lifetime via `LifetimeProxy`. Slugs continue spawning even while this tab is offscreen.
    private struct SlugsLifetimeTabView: View {
        var body: some View {
            slugsViewModel.subject.buildView()
        }

        @State
        private var slugsViewModel: LifetimeProxy<SlugsViewModel>

        init() {
            _slugsViewModel = State(
                wrappedValue: LifetimeProxy {
                    SlugsViewModel(taskScheduler: $0)
                }
            )

            slugsViewModel.subject.startSpawning()
        }
    }

    /// Scopes the run context to the view's on-screen status via the `.task` modifier. When this view goes offscreen the run context is cancelled. Slugs resume spawning when the view reappears.
    private struct SlugsOnScreenTabView: View {
        var body: some View {
            viewModel.buildView()
                .task {
                    await taskScheduler.run {
                        viewModel.startSpawning()
                    }
                }
        }

        @State
        private var viewModel: SlugsViewModel

        @State
        private var taskScheduler: TaskScheduler

        init() {
            let taskScheduler = TaskScheduler()
            _viewModel = State(wrappedValue: SlugsViewModel(taskScheduler: taskScheduler))
            _taskScheduler = State(wrappedValue: taskScheduler)
        }
    }
}
