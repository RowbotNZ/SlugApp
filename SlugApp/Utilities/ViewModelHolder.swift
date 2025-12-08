//
//  ViewModelHolder.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 08/12/2025.
//

import Observation

@MainActor
@Observable
final class ViewModelHolder<ViewModel: Observable> {
    let viewModel: ViewModel

    @ObservationIgnored
    private let task: Task<Void, Never>!

    init(
        viewModel: (_ lifetimeTaskScheduler: TaskScheduler) -> ViewModel
    ) {
        let lifetimeTaskScheduler = TaskScheduler()

        self.viewModel = viewModel(lifetimeTaskScheduler)

        /// **Demo commentary:**
        /// - We establish a run context for the task scheduler inside a `Task` which we will cancel when this object is released.
        task = Task { [lifetimeTaskScheduler] in
            await lifetimeTaskScheduler.run()
        }
    }

    deinit {
        task.cancel()
    }
}
