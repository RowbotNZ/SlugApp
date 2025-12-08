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
    let lifetimeTaskScheduler: TaskScheduler
    let viewModel: SlugsViewModel

    init() {
        self.lifetimeTaskScheduler = TaskScheduler()
        self.viewModel = SlugsViewModel(lifetimeTaskScheduler: lifetimeTaskScheduler)
    }

    @Test
    func testStartsWithASingleSlug() {
        #expect(viewModel.viewState.slugs.count == 1)
    }

    @Test
    func testSlugsReproduceOnTheirOwn() async throws {
        async let _ = lifetimeTaskScheduler.run()

        try await lifetimeTaskScheduler.next()

        #expect(viewModel.viewState.slugs.count == 2)
    }

    @Test
    func testSlugsReproduceWhenTapped() async throws {
        async let _ = lifetimeTaskScheduler.run()

        viewModel.viewState.slugs.first?.onTap()

        try await lifetimeTaskScheduler.next()

        #expect(viewModel.viewState.slugs.count == 2)
    }
}
