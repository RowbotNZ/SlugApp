# SlugApp

Sample app repository to demonstrate `TaskScheduler` for SLUG December 2025 meetup.

## Task Scheduler

### Background

As an iOS app developer who had been using MVVM and Combine for a while, I was interested in Swift Structured Concurrency, and finding ways to weave this into my familiar and comfortable ways of working.

Two considerations were top of mind for me at the time:

- How can view models create lifecycle-aware async operations? Sometimes we want to spawn some long-running or resource intensive async task that lives for as long as the view model does. Other times we want to tie that work to a narrower scope, e.g. a particular screen being visible, so that when the user navigates away we cancel it.
- How can we unit test async view model operations, without exposing the functions directly? Often we will have internal async operations that we don't necessarily want to expose as part of the object's interface, but we need a way for our unit tests to know when these operations complete, so that we know when it's time to make our assertions.

`TaskScheduler` is what I ended up with. It uses a `TaskGroup` and an `AsyncStream` to inject concurrent async operations into an external `Task` context, referred to as the "run context". The caller provides the run context by invoking `run()` from any parent `Task`, and when the parent task is cancelled all of the scheduled work is cancelled along with it. The scope of that cancellation - view model lifetime, view on-screen lifetime, something else entirely - is simply a matter of where `run()` is called from.

### Demonstration

The app has two slug tabs backed by instances of `SlugsViewModel`, differing only in how the view model's run context is scoped:

- **Persistent**: the view model is owned by a `LifetimeProxy`, which drives `run()` from a long-lived parent `Task` of its own. The run context lives for as long as the proxy does, so the slugs continue reproducing even while this tab is offscreen.
- **On Screen**: the view model and task scheduler are held in `@State` on the tab view, and `run()` is called from within a SwiftUI `.task` modifier. Switching to another tab cancels the run context and all of its queued work; switching back re-establishes it (the `willBegin` callback on `run()` begins the slug spawning each time). The view model itself is never deallocated.

Tapping the navigation bar "Clear" button changes the SwiftUI identity of the root view, discarding all of the associated `@State`, and demonstrating run context cancellation in that scenario.

### Lifetime Proxy

`LifetimeProxy` is a small wrapper that scopes a `TaskScheduler`'s run context to the lifetime of a subject object (typically a view model). It owns both the subject and the task scheduler, and kicks off a parent `Task` at init that calls `run()`. When the last reference to the proxy is released the parent task is cancelled, propagating cancellation to every scheduled operation in the run context. This means view model code can strongly capture `self` inside scheduled tasks without worrying about retain cycles. Such tasks are guaranteed to be cancelled, and the captured references released, when the proxy is deallocated.
