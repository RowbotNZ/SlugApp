//
//  SlugsViewModel.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 03/12/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class SlugsViewModel {
    var viewState: ViewState { _viewState }

    @ObservationIgnored
    private var model: Model {
        didSet {
            _viewState = createViewState()
        }
    }

    private var _viewState: ViewState!

    @ObservationIgnored
    private let taskScheduler: TaskScheduler

    @ObservationIgnored
    private var spawnSlugsTask: Task<Void, Never>?

    init(
        taskScheduler: TaskScheduler = TaskScheduler()
    ) {
        self.model = Model(slugs: [Model.Slug()])
        self.taskScheduler = taskScheduler

        _viewState = createViewState()

        spawnSlugsTask = taskScheduler.task { [weak self] in
            try? await self?.spawnSlugs()
        }
    }

    deinit {
        print("SLUGS - DEINIT")

        spawnSlugsTask?.cancel()
    }

    func run() async {
        await taskScheduler.run {}
    }

    private func createViewState() -> ViewState {
        ViewState(
            title: "Slugs",
            slugs: model.slugs.map { slug in
                ViewState.Slug(
                    id: slug.id.uuidString,
                    isReproducing: slug.isReproducing
                ) { [weak self] in
                    guard let self else { return }

                    triggerSlugReproduction(slugId: slug.id)
                }
            }
        )
    }

    private func spawnSlugs() async throws(CancellationError) {
        while true {
            try? await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)

            if Task.isCancelled {
                throw CancellationError()
            } else {
                if let randomSlug = model.slugs.randomElement() {
                    triggerSlugReproduction(slugId: randomSlug.id)
                }
            }
        }
    }

    private func triggerSlugReproduction(slugId: UUID) {
        guard let slugIndex = model.slugs.firstIndex(where: { $0.id == slugId }) else { return }

        let slug = model.slugs[slugIndex]

        guard !slug.isReproducing else { return }

        model.slugs[slugIndex].isReproducing = true

        taskScheduler.addRunContextTask { @MainActor [self] in
            try? await Task.sleep(nanoseconds: 5 * NSEC_PER_SEC)

            guard let slugIndex = model.slugs.firstIndex(where: { $0.id == slugId }) else { return }

            model.slugs = {
                var slugs = model.slugs

                slugs[slugIndex].isReproducing = false

                if !Task.isCancelled {
                    slugs.append(Model.Slug())
                }

                return slugs
            }()
        }
    }
}

// MARK: - Model

extension SlugsViewModel {
    struct Model {
        var slugs: [Slug]

        struct Slug: Identifiable {
            var id: UUID = UUID()
            var isReproducing: Bool = false
        }
    }
}

// MARK: - View State

extension SlugsViewModel {
    struct ViewState {
        var title: String
        var slugs: [Slug]

        struct Slug: Identifiable {
            var id: String
            var isReproducing: Bool
            var onTap: () -> Void
        }
    }
}
