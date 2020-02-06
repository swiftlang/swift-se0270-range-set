// swift-tools-version:5.1
//===----------------------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "swift-se0270-range-set",
  products: [
    .library(
      name: "SE0270_RangeSet",
      targets: ["SE0270_RangeSet"]),
  ],
  targets: [
    .target(
      name: "SE0270_RangeSet",
      dependencies: []),
    .target(
      name: "TestHelpers",
      dependencies: ["SE0270_RangeSet"]),
    .testTarget(
      name: "SE0270_RangeSet_Tests",
      dependencies: ["SE0270_RangeSet", "TestHelpers"]),
  ]
)
