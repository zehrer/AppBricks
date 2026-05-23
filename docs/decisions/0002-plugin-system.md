# ADR-0002: Plugin System via PluginContainer

Status: Accepted

## Decision

We introduce a `PluginContainer` held inside `AppEnvironment` as the mechanism for
registering and resolving plugin-provided services. Plugins conform to the `AppPlugin`
protocol and are wired by the host app at startup.

## Rationale

- Keeps the "no global singletons" principle from ADR-0001
- The host app remains the single composition root — it decides which plugins exist
- Features stay ignorant of each other; they only resolve what they need from the container
- Supporting both eager instances and lazy factories lets the developer choose the
  appropriate lifetime per service without the framework imposing one

## Registration patterns

**Eager** — use when the service is cheap to create and should be shared:

```swift
container.register(AnalyticsService())
```

**Lazy factory** — use when creation is deferred or a fresh instance is needed per resolve:

```swift
container.register(ImageCache.self) { ImageCache() }
```

## Consequences

- Plugin order of registration is the responsibility of the host app
- No automatic dependency resolution between plugins (YAGNI for v1.0)
- `PluginContainer` is `@unchecked Sendable`; registration must complete before
  concurrent access begins (i.e. before the SwiftUI scene is created)
