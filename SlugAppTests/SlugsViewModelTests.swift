//
//  SlugsViewModelTests.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 03/12/2025.
//

import Foundation
import Testing

@testable import ViewModelTaskScheduler

@testable import SlugApp

@MainActor
struct SlugsViewModelTests {
    let viewModelTaskScheduler: ViewModelTaskScheduler
    let viewModel: SlugsViewModel

    init() {
        self.viewModelTaskScheduler = ViewModelTaskScheduler()
        self.viewModel = SlugsViewModel(viewModelTaskScheduler: viewModelTaskScheduler)
    }

    @Test
    func testStartsWithASingleSlug() {
        #expect(viewModel.viewState.slugs.count == 1)
    }

    @Test
    func testSlugsReproduceOnTheirOwn() async throws {
        async let _ = viewModelTaskScheduler.run()

        try await viewModelTaskScheduler.next()

        #expect(viewModel.viewState.slugs.count == 2)
    }

    @Test
    func testSlugsReproduceWhenTapped() async throws {
        async let _ = viewModelTaskScheduler.run()

        viewModel.viewState.slugs.first?.onTap()

        try await viewModelTaskScheduler.next()

        #expect(viewModel.viewState.slugs.count == 2)
    }
}
