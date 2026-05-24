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
// swift-tools-version: 6.2
//
// Root package — consumed via Swift Package Manager.
// packages/AppBrick/Package.swift and packages/AppBrickUI/Package.swift
// are kept separately for local Xcode workspace development.

import PackageDescription

let package = Package(
    name: "AppBricks",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "AppBrick",   targets: ["AppBrick"]),
        .library(name: "AppBrickUI", targets: ["AppBrickUI"]),
    ],
    targets: [
        .target(
            name: "AppBrick",
            path: "packages/AppBrick/Sources"
        ),
        .target(
            name: "AppBrickUI",
            dependencies: ["AppBrick"],
            path: "packages/AppBrickUI/Sources",
            resources: [.process("Resources")]
        ),
    ]
)
