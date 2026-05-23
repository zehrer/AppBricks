# AppBricks Architecture

## Layers

```
┌─────────────────────────────┐
│        Target App (iOS)     │  @main — composition root
│  wires plugins, owns env    │
└────────────┬────────────────┘
             │ passes AppEnvironment
┌────────────▼────────────────┐
│      Feature Packages       │  domain logic, SwiftUI views
│  resolve services from env  │
└────────────┬────────────────┘
             │ depends on
┌────────────▼────────────────┐
│       Core Packages         │  AppEnvironment, PluginContainer,
│  (AppBrickCore, AppBrickUI) │  shared models, base UI
└─────────────────────────────┘
```

## Dependency Rules

- Features depend on Core
- Core never depends on Features
- The host app is the single composition root — it wires everything together

## Plugin System

Plugins are the seam between the host app and feature packages.
Each feature package may ship one or more `AppPlugin` conformances that register
the services the feature provides. The host app decides which plugins to load.

```
Host App
  └─ creates PluginContainer
  └─ calls plugin.register(in: container) for each plugin
  └─ passes AppEnvironment(plugins: container) to the root view

Feature
  └─ receives AppEnvironment
  └─ calls env.plugins.resolve(MyService.self) when needed
```

## Key Types (AppBrickCore)

| Type | Role |
|---|---|
| `AppEnvironment` | Explicit dependency carrier (logger + plugins) |
| `PluginContainer` | Service registry; supports eager instances and lazy factories |
| `AppPlugin` | Protocol a feature module conforms to for self-registration |
