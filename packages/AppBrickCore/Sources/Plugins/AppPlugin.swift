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
//  AppPlugin.swift
//

/// A module that can register its services into a PluginContainer.
public protocol AppPlugin {
    var name: String { get }
    func register(in container: PluginContainer)
}
