import Testing
@testable import AppBrickCore

// MARK: - PluginContainer

@Suite("PluginContainer")
struct PluginContainerTests {

    @Test func resolveEagerInstance() {
        let container = PluginContainer()
        container.register("hello" as String)
        #expect(container.resolve(String.self) == "hello")
    }

    @Test func resolveFromFactory() {
        let container = PluginContainer()
        container.register(Int.self) { 42 }
        #expect(container.resolve(Int.self) == 42)
    }

    @Test func factoryIsCalledOnEachResolve() {
        var callCount = 0
        let container = PluginContainer()
        container.resolve(Int.self)                      // nothing registered yet
        container.register(Int.self) { callCount += 1; return callCount }
        _ = container.resolve(Int.self)
        _ = container.resolve(Int.self)
        #expect(callCount == 2)
    }

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
