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
@testable import SE0270_RangeSet
import TestHelpers

let parent = -200..<200
let source = RangeSet([1..<5, 8..<10, 20..<22, 27..<29])

func buildRandomRangeSet(iterations: Int = 100) -> RangeSet<Int> {
  var set = RangeSet<Int>()
  for _ in 0..<100 {
    var (a, b) = (Int.random(in: -100...100), Int.random(in: -100...100))
    if (a > b) { swap(&a, &b) }
    if Double.random(in: 0..<1) > 0.3 {
      set.insert(contentsOf: a..<b)
    } else {
      set.remove(contentsOf: a..<b)
    }
  }
  return set
}

final class RangeSetTests: XCTestCase {
  func testContains() {
    XCTAssertFalse(source.contains(0))
    XCTAssertTrue(source.contains(1))
    XCTAssertTrue(source.contains(4))
    XCTAssertFalse(source.contains(5))
    XCTAssertTrue(source.contains(28))
    XCTAssertFalse(source.contains(29))
    
    for _ in 0..<1000 {
      let set = buildRandomRangeSet()
      for i in parent.indices[set] {
        XCTAssertTrue(set.contains(i))
      }
      
      let inverted = set._inverted(within: parent)
      for i in parent.indices[inverted] {
        XCTAssertFalse(set.contains(i))
      }
    }
  }
  
  func testInsertions() {
    do {
      // Overlap from middle to middle
      var s = source
      s.insert(contentsOf: 3..<21)
      XCTAssertEqual(s.ranges, [1..<22, 27..<29])
    }
    
    do {
      // insert in middle
      var s = source
      s.insert(contentsOf: 13..<15)
      XCTAssertEqual(s.ranges, [1..<5, 8..<10, 13..<15, 20..<22, 27..<29])
    }
    
    do {
      // extend a range
      var s = source
      s.insert(contentsOf: 22..<25)
      XCTAssertEqual(s.ranges, [1..<5, 8..<10, 20..<25, 27..<29])
    }
    
    do {
      // extend at beginning of range
      var s = source
      s.insert(contentsOf: 17..<20)
      XCTAssertEqual(s.ranges, [1..<5, 8..<10, 17..<22, 27..<29])
    }
    
    do {
      // insert at the beginning
      var s = source
      s.insert(contentsOf: -10 ..< -5)
      XCTAssertEqual(s.ranges, [-10 ..< -5, 1..<5, 8..<10, 20..<22, 27..<29])
    }
    
    do {
      // insert at the end
      var s = source
      s.insert(contentsOf: 35 ..< 40)
      XCTAssertEqual(s.ranges, [1..<5, 8..<10, 20..<22, 27..<29, 35..<40])
    }
    
    do {
      // Overlap multiple ranges
      var s = source
      s.insert(contentsOf: 0..<21)
      XCTAssertEqual(s.ranges, [0..<22, 27..<29])
    }
    
    do {
      // Insert at end of range
      var s = source
      s.insert(22, within: parent)
      XCTAssertEqual(s.ranges, [1..<5, 8..<10, 20..<23, 27..<29])
    }
    
    do {
      // Insert between ranges
      var s = source
      s.insert(14, within: parent)
      XCTAssertEqual(s.ranges, [1..<5, 8..<10, 14..<15, 20..<22, 27..<29])
    }
  }
  
  func testRemovals() {
    do {
      var s = source
      s.remove(contentsOf: 4..<28)
      XCTAssertEqual(s.ranges, [1..<4, 28..<29])
      s.remove(3, within: parent)
      XCTAssertEqual(s.ranges, [1..<3, 28..<29])
    }
  }
  
  func testInvariant() {
    for _ in 0..<1000 {
      let set = buildRandomRangeSet()
      
      // No empty ranges allowed
      XCTAssertTrue(set.ranges.allSatisfy { !$0.isEmpty })
      
      // No overlapping / out-of-order ranges allowed
      let adjacentRanges = zip(set.ranges, set.ranges.dropFirst())
      XCTAssertTrue(adjacentRanges.allSatisfy { $0.upperBound < $1.lowerBound })
    }
  }
  
  func testGaps() {
    let firstSet = RangeSet([0.0..<0.25, 0.5..<0.75, 1.0..<2.0])        
    do {
      let secondSet = firstSet._gaps(boundedBy: 0.0..<5.0)
      XCTAssertEqual(secondSet, RangeSet([0.25..<0.5, 0.75..<1.0, 2.0..<5.0]))
      let sameAsFirstSet = secondSet._gaps(boundedBy: 0.0..<5.0)
      XCTAssertEqual(sameAsFirstSet, firstSet)
    }
    
    XCTAssert(firstSet._gaps(boundedBy: 5.0..<10.0).isEmpty)
    XCTAssert(firstSet._gaps(boundedBy: 0.0..<0.0).isEmpty)
  }
  
  func testIntersection() {
    func intersectionViaSet(_ s1: RangeSet<Int>, _ s2: RangeSet<Int>) -> RangeSet<Int> {
      let set1 = Set(parent.indices[s1])
      let set2 = Set(parent.indices[s2])
      return RangeSet(set1.intersection(set2), within: .min ..< .max)
    }
    
    do {
      // Simple test
      let set1 = RangeSet([0..<5, 9..<14])
      let set2 = RangeSet([1..<3, 4..<6, 8..<12])
      let intersection = RangeSet([1..<3, 4..<5, 9..<12])
      XCTAssertEqual(set1.intersection(set2), intersection)
      XCTAssertEqual(set2.intersection(set1), intersection)
    }
    
    do {
      // Test with upper bound / lower bound equality
      let set1 = RangeSet([10..<20, 30..<40])
      let set2 = RangeSet([15..<30, 40..<50])
      let intersection = RangeSet([15..<20])
      XCTAssertEqual(set1.intersection(set2), intersection)
      XCTAssertEqual(set2.intersection(set1), intersection)
    }
    
    for _ in 0..<100 {
      let set1 = buildRandomRangeSet()
      let set2 = buildRandomRangeSet()
      
      let rangeSetIntersection = set1.intersection(set2)
      let stdlibSetIntersection = intersectionViaSet(set1, set2)
      XCTAssertEqual(rangeSetIntersection, stdlibSetIntersection)
    }
  }
  
  func testSymmetricDifference() {
    func symmetricDifferenceViaSet(_ s1: RangeSet<Int>, _ s2: RangeSet<Int>) -> RangeSet<Int> {
      let set1 = Set(parent.indices[s1])
      let set2 = Set(parent.indices[s2])
      return RangeSet(set1.symmetricDifference(set2), within: .min ..< .max)
    }
    
    do {
      // Simple test
      let set1 = RangeSet([0..<5, 9..<14])
      let set2 = RangeSet([1..<3, 4..<6, 8..<12])
      let difference = RangeSet([0..<1, 3..<4, 5..<6, 8..<9, 12..<14])
      XCTAssertEqual(set1.symmetricDifference(set2), difference)
      XCTAssertEqual(set2.symmetricDifference(set1), difference)
    }
    
    do {
      // Test with upper bound / lower bound equality
      let set1 = RangeSet([10..<20, 30..<40])
      let set2 = RangeSet([15..<30, 40..<50])
      let difference = RangeSet([10..<15, 20..<50])
      XCTAssertEqual(set1.symmetricDifference(set2), difference)
      XCTAssertEqual(set2.symmetricDifference(set1), difference)
    }
    
    for _ in 0..<100 {
      let set1 = buildRandomRangeSet()
      let set2 = buildRandomRangeSet()
      
      let rangeSetDifference = set1.symmetricDifference(set2)
      let stdlibSetDifference = symmetricDifferenceViaSet(set1, set2)
      XCTAssertEqual(rangeSetDifference, stdlibSetDifference)
    }
  }
}
