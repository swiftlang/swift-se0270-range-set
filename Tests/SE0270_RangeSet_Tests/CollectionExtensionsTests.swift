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
import SE0270_RangeSet
import TestHelpers

let letterString = "ABCdefGHIjklMNOpqrStUvWxyz"
let lowercaseLetters = letterString.filter { $0.isLowercase }
let uppercaseLetters = letterString.filter { $0.isUppercase }

extension Collection {
  func every(_ n: Int) -> [Element] {
    sequence(first: startIndex) { i in
      let next = self.index(i, offsetBy: n, limitedBy: self.endIndex)
      return next == self.endIndex ? nil : next
    }.map { self[$0] }
  }
}

final class CollectionExtensionsTests: XCTestCase {
  func testIndicesWhere() {
    let a = [1, 2, 3, 4, 3, 3, 4, 5, 3, 4, 3, 3, 3]
    let indices = a.subranges(of: 3)
    XCTAssertEqual(indices, RangeSet([2..<3, 4..<6, 8..<9, 10..<13]))
    
    let allTheThrees = a[indices]
    XCTAssertEqual(allTheThrees.count, 7)
    XCTAssertTrue(allTheThrees.allSatisfy { $0 == 3 })
    XCTAssertEqual(allTheThrees, repeatElement(3, count: 7))
    
    let lowerIndices = letterString.subranges(where: { $0.isLowercase })
    let lowerOnly = letterString[lowerIndices]
    XCTAssertEqual(lowerOnly, lowercaseLetters)
    XCTAssertEqual(lowerOnly.reversed(), lowercaseLetters.reversed())
    
    let upperOnly = letterString.removingSubranges(lowerIndices)
    XCTAssertEqual(upperOnly, uppercaseLetters)
    XCTAssertEqual(upperOnly.reversed(), uppercaseLetters.reversed())
  }
  
  func testRemoveAllRangeSet() {
    var a = [1, 2, 3, 4, 3, 3, 4, 5, 3, 4, 3, 3, 3]
    let indices = a.subranges(of: 3)
    a.removeSubranges(indices)
    XCTAssertEqual(a, [1, 2, 4, 4, 5, 4])
    
    var numbers = Array(1...20)
    numbers.removeSubranges(RangeSet([2..<5, 10..<15, 18..<20]))
    XCTAssertEqual(numbers, [1, 2, 6, 7, 8, 9, 10, 16, 17, 18])
    
    numbers = Array(1...20)
    numbers.removeSubranges(.init())
    XCTAssertEqual(Array(1...20), numbers)
    
    let sameNumbers = numbers.removingSubranges(.init())
    XCTAssertEqual(numbers, sameNumbers)
    
    var str = letterString
    let lowerIndices = str.subranges(where: { $0.isLowercase })
    
    let upperOnly = str.removingSubranges(lowerIndices)
    XCTAssertEqual(upperOnly, uppercaseLetters)
    
    str.removeSubranges(lowerIndices)
    XCTAssertEqual(str, uppercaseLetters)
  }
  
  func testGatherRangeSet() {
    // Move before
    var numbers = Array(1...20)
    let range1 = numbers.moveSubranges(RangeSet([10..<15, 18..<20]), to: 4)
    XCTAssertEqual(range1, 4..<11)
    XCTAssertEqual(numbers, [
      1, 2, 3, 4,
      11, 12, 13, 14, 15,
      19, 20,
      5, 6, 7, 8, 9, 10, 16, 17, 18])
    
    // Move to start
    numbers = Array(1...20)
    let range2 = numbers.moveSubranges(RangeSet([10..<15, 18..<20]), to: 0)
    XCTAssertEqual(range2, 0..<7)
    XCTAssertEqual(numbers, [
      11, 12, 13, 14, 15,
      19, 20,
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 16, 17, 18])
    
    // Move to end
    numbers = Array(1...20)
    let range3 = numbers.moveSubranges(RangeSet([10..<15, 18..<20]), to: 20)
    XCTAssertEqual(range3, 13..<20)
    XCTAssertEqual(numbers, [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 16, 17, 18,
      11, 12, 13, 14, 15,
      19, 20,
    ])
    
    // Move to middle of selected elements
    numbers = Array(1...20)
    let range4 = numbers.moveSubranges(RangeSet([10..<15, 18..<20]), to: 14)
    XCTAssertEqual(range4, 10..<17)
    XCTAssertEqual(numbers, [
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
      11, 12, 13, 14, 15,
      19, 20,
      16, 17, 18])
    
    // Move none
    numbers = Array(1...20)
    let range5 = numbers.moveSubranges(RangeSet(), to: 10)
    XCTAssertEqual(range5, 10..<10)
    XCTAssertEqual(numbers, Array(1...20))
  }
  
  func testDiscontiguousSliceSlicing() {
    let initial = 1...100
    
    // Build an array of ranges that include alternating groups of 5 elements
    // e.g. 1...5, 11...15, etc
    let rangeStarts = initial.indices.every(10)
    let rangeEnds = rangeStarts.compactMap {
      initial.index($0, offsetBy: 5, limitedBy: initial.endIndex)
    }
    let ranges = zip(rangeStarts, rangeEnds).map(Range.init)
    
    // Create a collection of the elements represented by `ranges` without
    // using `RangeSet`
    let chosenElements = ranges.map { initial[$0] }.joined()
    
    let set = RangeSet(ranges)
    let discontiguousSlice = initial[set]
    XCTAssertEqual(discontiguousSlice, chosenElements)
    
    for (chosenIdx, disIdx) in zip(chosenElements.indices, discontiguousSlice.indices) {
      XCTAssertEqual(chosenElements[chosenIdx...], discontiguousSlice[disIdx...])
      XCTAssertEqual(chosenElements[..<chosenIdx], discontiguousSlice[..<disIdx])
      for (chosenUpper, disUpper) in
        zip(chosenElements.indices[chosenIdx...], discontiguousSlice.indices[disIdx...])
      {
        XCTAssertEqual(
          chosenElements[chosenIdx..<chosenUpper],
          discontiguousSlice[disIdx..<disUpper])
        XCTAssert(chosenElements[chosenIdx..<chosenUpper]
          .elementsEqual(discontiguousSlice[disIdx..<disUpper]))
      }
    }
  }
  
  func testDiscontiguousMutableSlicing() {
    let initial = Array(1...30)
    let changed = initial.map { 10*$0 }

    let rangeStarts = initial.indices.every(10)
    let rangeEnds = rangeStarts.compactMap {
      initial.index($0, offsetBy: 5, limitedBy: initial.endIndex)
    }
    let ranges = zip(rangeStarts, rangeEnds).map(Range.init)

    var mutated = initial
    let set = RangeSet(ranges)
    let subset = set.intersection(RangeSet(0..<(initial.count/2)))
    mutated[subset] = changed[set]

    XCTAssert(mutated[subset].elementsEqual(changed[subset]))
    let antiset = RangeSet(initial.indices).subtracting(subset)
    XCTAssert(mutated[antiset].elementsEqual(initial[antiset]))
  }

  func testDiscontiguousSliceMutableSlicing() {
    let initial = Array(1...30)
    let changed = initial.map { 10*$0 }

    let rangeStarts = initial.indices.every(10)
    let rangeEnds = rangeStarts.compactMap {
      initial.index($0, offsetBy: 5, limitedBy: initial.endIndex)
    }
    let ranges = zip(rangeStarts, rangeEnds).map(Range.init)

    let set = RangeSet(ranges)
    let subset = set.intersection(RangeSet(0..<(initial.count/2)))
    var mutated = initial[subset]
    let mutations = subset.ranges.map({ initial[$0] }).joined().map({ 10*$0 })
    mutated[...] = changed[set]
    XCTAssertLessThan(mutated.count, changed[set].count)

    XCTAssert(mutated.base[subset].elementsEqual(mutations))
  }

  func testNoCopyOnWrite() {
    var numbers = COWLoggingArray(1...20)
    let copyCount = COWLoggingArray_CopyCount
    
    _ = numbers.moveSubranges(RangeSet([10..<15, 18..<20]), to: 4)
    XCTAssertEqual(copyCount, COWLoggingArray_CopyCount)
    
    numbers.removeSubranges(RangeSet([2..<5, 10..<15, 18..<20]))
    XCTAssertEqual(copyCount, COWLoggingArray_CopyCount)
  }
}
