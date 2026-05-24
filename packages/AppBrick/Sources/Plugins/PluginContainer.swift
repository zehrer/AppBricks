//
//  Copyright (c) 2026 zehrer.xyz
//  Author: Stephan Zehrer
//
//  This file is part of AppBricks.
//
//  AppBricks is dual-licensed:
//  - GPLv3 for open-source use
//  - Commercial license required for proprietary use
//
// SPDX-License-Identifier: GPL-3.0-only
//
//  See the LICENSE file for details.
//
//  PluginContainer.swift
//

import Foundation

/// Lightweight service registry supporting eager instances, lazy factories, and lazy singletons.
/// Thread-safe: safe to resolve from any thread after startup registration is complete.
public final class PluginContainer: @unchecked Sendable {

    private enum Entry {
        case instance(Any)
        case factory(() -> Any)
        case singleton(() -> Any, Any?)   // factory + cached value once created
    }

    private var entries: [ObjectIdentifier: Entry] = [:]
    private let lock = NSLock()

    public init() {}

    // MARK: - Registration

    /// Registers a pre-built instance. The same instance is returned on every resolve.
    public func register<T>(_ instance: T) {
        lock.withLock {
            entries[ObjectIdentifier(T.self)] = .instance(instance)
        }
    }

    /// Registers a factory closure. A new instance is created on every resolve.
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        lock.withLock {
            entries[ObjectIdentifier(type)] = .factory(factory)
        }
    }

    /// Registers a lazy singleton: the factory runs once on first resolve; the same instance is returned after.
    public func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        lock.withLock {
            entries[ObjectIdentifier(type)] = .singleton(factory, nil)
        }
    }

    // MARK: - Resolution

    /// Returns the registered value, or nil if the type was never registered.
    public func resolve<T>(_ type: T.Type) -> T? {
        lock.withLock {
            let key = ObjectIdentifier(type)
            switch entries[key] {
            case .instance(let value):
                return value as? T
            case .factory(let make):
                return make() as? T
            case .singleton(let make, let cached):
                if let cached { return cached as? T }
                let value = make()
                entries[key] = .singleton(make, value)
                return value as? T
            case nil:
                return nil
            }
        }
    }

    /// Returns the registered value, or crashes with a descriptive message if not registered.
    /// Use when the service is mandatory and a missing registration is a programmer error.
    public func require<T>(_ type: T.Type) -> T {
        guard let value = resolve(type) else {
            fatalError("[PluginContainer] \(type) is not registered. Did you forget to call register in your AppPlugin?")
        }
        return value
    }
}
