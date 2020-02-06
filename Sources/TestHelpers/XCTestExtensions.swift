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

import XCTest

public func XCTAssertEqual<C1, C2>(_ collection1: C1, _ collection2: C2, file: StaticString = #file, line: UInt = #line)
  where C1: Collection, C2: Collection, C1.Element == C2.Element, C1.Element: Equatable
{
  for (i, (e1, e2)) in zip(0..., zip(collection1, collection2)) {
    XCTAssertEqual(e1, e2, "Elements differ at position \(i): '\(e1)' is not equal to '\(e2)'", file: file, line: line)
  }
  XCTAssert(collection1.count == collection2.count, "Collections have different lengths", file: file, line: line)
}
