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
    let viewModel: SlugsViewModel

    init() {
        self.viewModel = SlugsViewModel()
    }

    @Test
    func testStartsWithASingleSlug() {
        #expect(viewModel.viewState.slugs.count == 1)
    }

    @Test
    func testSlugsReproduceOnTheirOwn() async throws {
        /// **Demo commentary:**
        /// - Tests have arbitrary sleeps in them to allow internal view model tasks to complete before making assertions.
        try await Task.sleep(nanoseconds: 9 * NSEC_PER_SEC)

        #expect(viewModel.viewState.slugs.count == 2)
    }

    @Test
    func testSlugsReproduceWhenTapped() async throws {
        viewModel.viewState.slugs.first?.onTap()

        try await Task.sleep(nanoseconds: 6 * NSEC_PER_SEC)

        #expect(viewModel.viewState.slugs.count == 2)
    }
}
