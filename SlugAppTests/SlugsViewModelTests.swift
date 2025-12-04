//
//  SlugsViewModelTests.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 03/12/2025.
//

import Foundation
import Testing

@testable import SlugApp

@MainActor
struct SlugsViewModelTests {
    let taskScheduler: TaskScheduler
    let viewModel: SlugsViewModel

    init() {
        self.taskScheduler = TaskScheduler()
        self.viewModel = SlugsViewModel(taskScheduler: taskScheduler)
    }

    @Test
    func testStartsWithASingleSlug() {
        #expect(viewModel.viewState.slugs.count == 1)
    }

    @Test
    func testSlugsReproduceOnTheirOwn() async throws {
        async let _ = viewModel.run()

        try await taskScheduler.next()

        #expect(viewModel.viewState.slugs.count == 2)
    }

    @Test
    func testSlugsReproduceWhenTapped() async throws {
        async let _ = viewModel.run()

        viewModel.viewState.slugs.first?.onTap()

        try await taskScheduler.next()

        #expect(viewModel.viewState.slugs.count == 2)
    }
}
