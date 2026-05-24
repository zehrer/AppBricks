import Testing
@testable import AppBrickCore

// MARK: - PluginContainer

@Suite("PluginContainer")
struct PluginContainerTests {

    // MARK: Eager instance

    @Test func resolveEagerInstance() {
        let container = PluginContainer()
        container.register("hello" as String)
        #expect(container.resolve(String.self) == "hello")
    }

    @Test func eagerInstanceIsAlwaysSame() {
        let container = PluginContainer()
        container.register("hello" as String)
        #expect(container.resolve(String.self) == container.resolve(String.self))
    }

    // MARK: Lazy factory

    @Test func resolveFromFactory() {
        let container = PluginContainer()
        container.register(Int.self) { 42 }
        #expect(container.resolve(Int.self) == 42)
    }

    @Test func factoryIsCalledOnEachResolve() {
        var callCount = 0
        let container = PluginContainer()
        container.register(Int.self) { callCount += 1; return callCount }
        _ = container.resolve(Int.self)
        _ = container.resolve(Int.self)
        #expect(callCount == 2)
    }

    // MARK: Lazy singleton

    @Test func singletonFactoryCalledOnlyOnce() {
        var callCount = 0
        let container = PluginContainer()
        container.registerSingleton(Int.self) { callCount += 1; return callCount }
        _ = container.resolve(Int.self)
        _ = container.resolve(Int.self)
        _ = container.resolve(Int.self)
        #expect(callCount == 1)
    }

    @Test func singletonReturnsSameValue() {
        let container = PluginContainer()
        container.registerSingleton(Int.self) { 99 }
        let a = container.resolve(Int.self)
        let b = container.resolve(Int.self)
        #expect(a == b)
    }

    // MARK: require

    @Test func requireReturnsRegisteredValue() {
        let container = PluginContainer()
        container.register(7 as Int)
        #expect(container.require(Int.self) == 7)
    }

    // MARK: General

    @Test func eagerInstanceOverridesFactory() {
        let container = PluginContainer()
        container.register(Int.self) { 1 }
        container.register(99 as Int)
        #expect(container.resolve(Int.self) == 99)
    }

    @Test func resolveMissingTypeReturnsNil() {
        let container = PluginContainer()
        #expect(container.resolve(String.self) == nil)
    }
}

// MARK: - AppPlugin

private struct GreetingPlugin: AppPlugin {
    let name = "Greeting"
    func register(in container: PluginContainer) {
        container.register("Hello from plugin" as String)
    }
}

@Suite("AppPlugin")
struct AppPluginTests {

    @Test func pluginRegistersService() {
        let container = PluginContainer()
        GreetingPlugin().register(in: container)
        #expect(container.resolve(String.self) == "Hello from plugin")
    }
}

// MARK: - AppEnvironment

@Suite("AppEnvironment")
struct AppEnvironmentTests {

    @Test func defaultContainerIsEmpty() {
        let env = AppEnvironment.live(subsystem: "test")
        #expect(env.plugins.resolve(String.self) == nil)
    }

    @Test func customContainerIsForwarded() {
        let container = PluginContainer()
        container.register(7 as Int)
        let env = AppEnvironment.live(subsystem: "test", plugins: container)
        #expect(env.plugins.resolve(Int.self) == 7)
    }
}
