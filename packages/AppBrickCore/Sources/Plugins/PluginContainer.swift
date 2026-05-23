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

/// Lightweight service registry supporting both eager instances and lazy factories.
///
/// Register at app startup (single-threaded); resolve freely afterwards.
public final class PluginContainer: @unchecked Sendable {

    private enum Entry {
        case instance(Any)
        case factory(() -> Any)
    }

    private var entries: [ObjectIdentifier: Entry] = [:]

    public init() {}

    // MARK: - Registration

    /// Registers a pre-built instance. The same instance is returned on every resolve.
    public func register<T>(_ instance: T) {
        entries[ObjectIdentifier(T.self)] = .instance(instance)
    }

    /// Registers a factory closure. A new instance is created on every resolve.
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        entries[ObjectIdentifier(type)] = .factory(factory)
    }

    // MARK: - Resolution

    /// Returns the registered instance or the result of the factory, or nil if not found.
    public func resolve<T>(_ type: T.Type) -> T? {
        switch entries[ObjectIdentifier(type)] {
        case .instance(let value):
            return value as? T
        case .factory(let make):
            return make() as? T
        case nil:
            return nil
        }
    }
}
