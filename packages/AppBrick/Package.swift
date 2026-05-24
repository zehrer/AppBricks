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
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppBrick",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "AppBrick",
            targets: ["AppBrick"]
        ),
    ],
    targets: [
        .target(
            name: "AppBrick"
        ),
        .testTarget(
            name: "AppBrickTests",
            dependencies: ["AppBrick"]
        ),
    ]
)
