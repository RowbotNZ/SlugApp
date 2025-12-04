# SlugApp

Sample app repository to demonstrate `TaskScheduler` for SLUG December 2025 meetup.

## Task Scheduler

### Background

As an iOS app developer who had been using MVVM and Combine for a while, I was interested in Swift Structured Concurrency, and finding ways to weave this into my familiar and comfortable ways of working.

Two considerations were top of mind for me at the time:

- How can view models create lifecycle-aware async operations? Often we want to spawn some long-running or resource intensive async task while the user is looking at a particular screen, but as they navigate away we want to cancel those operations to save resources.
- How can we unit test async view model operations, without exposing the functions directly? Often we will have internal async operations that we don't necessarily want to expose as part of the object's interface, but we need a way for our unit tests to know when these operations complete, so that we know when it's time to make our assertions.

I was curious about ways to leverage SwiftUI's `task` modifier to couple these async operations to the lifecycle of a view. `TaskScheduler` is what I ended up with; it uses a `TaskGroup` and an `AsyncStream` to inject concurrent async operations into the `Task` context provided by the SwiftUI `task` modifier`. In this way, any async operations that we inject will be cancelled when the parent `task` is cancelled.

