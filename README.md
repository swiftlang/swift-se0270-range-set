# SE0270_RangeSet

**SE0270_RangeSet** is a standalone library that implements the Swift Evolution proposal
[SE-0270: Add Collection Operations on Noncontiguous Elements][proposal]. 
You can use this package independently, 
or as part of the [standard library preview package][stdlib-preview].

## Functionality

**SE0270_RangeSet** provides operations on noncontiguous subranges of collections, 
such as `subranges(where:)` and `moveSubranges(_:to:)`, 
as well as the supporting `RangeSet` type.

```swift
import SE0270_RangeSet

var numbers = [10, 12, -5, 14, -3, -9, 15]
let negatives = numbers.subranges(where: { $0 < 0 })
// numbers[negatives].count == 3

numbers.moveSubranges(negatives, to: 0)
// numbers == [-5, -3, -9, 10, 12, 14, 15]
```

## Usage

You can add this library as a dependency to any Swift package. 
Add this line to the `dependencies` parameter in your `Package.swift` file:

```swift
.package(
    url: "https://github.com/apple/swift-se0270-range-set",
    from: "1.0.0"),
```

Next, add the module as a dependency for your targets that will use the library:

```swift
.product(name: "SE0270_RangeSet", package: "swift-se0270-range-set"),
```

You can now use `import SE0270_RangeSet` to make the library available in any Swift file.

## Contributing

Contributions to this package and the standard library preview package are welcomed and encouraged!

- For help using this package or the standard library preview package, please [visit the Swift forums][user-forums]. 
- For issues related to these packages, [file a bug at bugs.swift.org][bugs].
- Changes or additions to the APIs are made through 
  the [Swift Evolution process][evolution-process].
  Please see the [guide for Contributing to Swift][contributing] for information.


[proposal]: https://github.com/apple/swift-evolution/blob/master/proposals/0270-rangeset-and-collection-operations.md
[stdlib-preview]: https://github.com/apple/swift-standard-library-preview 
[user-forums]: https://forums.swift.org/c/swift-users/
[bugs]: https://bugs.swift.org
[evolution-process]: https://github.com/apple/swift-evolution/blob/master/process.md
[contributing]: https://swift.org/contributing
