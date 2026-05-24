# AppBricks

AppBricks is an open-source foundation for building high-quality SwiftUI
applications in a repeatable, structured, and maintainable way.

It provides a small runtime and a set of composable building blocks that help
industrialize app development without hiding Swift or SwiftUI.

AppBricks is designed to work with:
- SwiftUI
- Swift Package Manager
- Explicit dependency injection
- Modular feature packages
- iOS first, macOS later

---

## Motivation

Modern app development is fast, but architectural quality often degrades as
each new project reinvents the same foundations.

AI-assisted coding accelerates this even further, but without strong
constraints it amplifies inconsistency and technical debt.

AppBricks aims to provide a stable, understandable baseline so developers can
focus on domain-specific problems instead of rebuilding infrastructure.

---

## Key Principles

- Explicit over implicit behavior
- Composition over inheritance
- Dependency injection as a first-class concept
- Testability by design
- Clear boundaries between features and infrastructure
- Refactoring-friendly architecture

---

## Project Structure

```
AppBricks/
├─ Package.swift          ← root package consumed via SPM
├─ packages/
│  ├─ AppBrick/           ← core runtime (local Xcode development)
│  └─ AppBrickUI/         ← SwiftUI components (local Xcode development)
├─ DemoApps/              ← example apps, not required for using AppBricks
└─ docs/
```

The sub-packages under `packages/` mirror the root products and are kept
for standalone Xcode development. Source files are not duplicated — the root
`Package.swift` points its targets directly at `packages/*/Sources/`.

---

## Core Concepts

### AppEnvironment

`AppEnvironment` is the explicit dependency carrier passed into every feature.
It holds cross-cutting infrastructure (logging, plugin services) without global state.

```swift
let env = AppEnvironment.live(subsystem: "com.example.MyApp")
```

### Plugin System

Plugins are modules that register their services into a `PluginContainer` at app startup.
Features resolve what they need; they never know which plugin provided it.

**Define a plugin:**

```swift
struct NotePlugin: AppPlugin {
    let name = "Note"
    func register(in container: PluginContainer) {
        container.register(NoteService())                          // eager — shared instance, created now
        container.register(NoteParser.self) { NoteParser() }      // lazy factory — new instance per resolve
        container.registerSingleton(NoteCache.self) { NoteCache() } // lazy singleton — created once on first resolve
    }
}
```

**Wire it in `@main`:**

```swift
@main
struct MyApp: App {
    let env: AppEnvironment = {
        let container = PluginContainer()
        NotePlugin().register(in: container)
        return AppEnvironment.live(subsystem: "com.example.MyApp", plugins: container)
    }()

    var body: some Scene {
        WindowGroup { RootView(env: env) }
    }
}
```

**Resolve inside a feature:**

```swift
// Optional — use when a missing service is acceptable
let parser = env.plugins.resolve(NoteParser.self)

// Required — crashes with a clear message if not registered (programmer error)
let cache = env.plugins.require(NoteCache.self)
```

---

## Swift Package Manager

AppBricks is distributed as a single Swift package with two library products.

### Products

| Product | Description |
|---|---|
| `AppBrick` | Core runtime — `AppEnvironment`, `PluginContainer`, `AppPlugin` |
| `AppBrickUI` | SwiftUI components — tags, lists, shared UI primitives. Depends on `AppBrick`. |

Import only what you need. A feature that has no UI only needs `AppBrick`.

### Adding the dependency

In your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/zehrer/AppBricks", from: "1.0.0"),
],
targets: [
    .target(
        name: "MyFeature",
        dependencies: [
            .product(name: "AppBrick",   package: "AppBricks"),  // core only
        ]
    ),
    .target(
        name: "MyFeatureUI",
        dependencies: [
            .product(name: "AppBrickUI", package: "AppBricks"),  // includes AppBrick
        ]
    ),
]
```

---

## Usage

The typical workflow is:
1. Create a new iOS or macOS project using Xcode
2. Add AppBricks via Swift Package Manager (see above)
3. Define plugins for each feature module
4. Assemble plugins in the host app's `@main` entry point

No project templates are required.

---

## License

AppBricks is **dual-licensed**:

- **GPLv3** for open-source projects
- **Commercial license** required for proprietary or closed-source use

If you intend to use AppBricks in a commercial, closed-source, or proprietary
application, you must obtain a commercial license.

For commercial licensing inquiries, please contact the project maintainer.

See the `LICENSE` file for details.

---

## Contributing

Contributions are welcome.

Please note that due to the dual-licensing model, contributors may be required
to agree to a Contributor License Agreement (CLA).

More details please contact the project maintainer.

---

## Status

AppBricks is in early development.
APIs and architecture may evolve until the first stable release.

### What is done

- `AppEnvironment` — explicit dependency carrier with logger
- `PluginContainer` — thread-safe service registry (eager, lazy factory, lazy singleton)
- `AppPlugin` protocol — self-registering feature modules
- Root `Package.swift` — publishable as a Swift package with two products
- `AppBrickUI` — shared SwiftUI primitives (tags, content list, localisation)

---

## Next Steps

### Near term

- **SwiftUI environment integration** — add an `EnvironmentKey` for `AppEnvironment` in `AppBrickUI` so features can access it via `@Environment(\.appEnvironment)` instead of explicit prop-drilling
- **Real-project validation** — use AppBricks in a host app to smoke-test the plugin wiring end-to-end and surface any ergonomic gaps
- **macOS support** — extend platform targets from `.iOS(.v17)` to include `.macOS(.v14)`

### Medium term

- **First tagged release** — tag `v0.1.0` once the API feels stable after real-project usage
- **AppBrickUI depends on AppBrick** — currently the UI package is independent; wire in `AppEnvironment` access once the EnvironmentKey exists
- **Demo app update** — update `BrickNote` or `BrickList` to demonstrate full plugin wiring from `@main` through to a feature view

### Out of scope for v1.0

- Automatic dependency resolution between plugins
- Code generation or visual DSL
- TCA enforcement
