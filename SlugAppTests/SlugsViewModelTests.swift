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
        /// **Demo commentary:**
        /// - Tests must call `run` to establish the lifecycle task context for the view model.
        /// - Cancelling the run task allows one to test the lifecycle awareness of the view model.
        async let _ = viewModel.run()

        /// **Demo commentary:**
        /// - Tests can await task milestones to ensure they make their assertions at the right time.
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
