SYOperationQueue
=============

An operation queue subclass that allows LIFO style queuing and a max number of operations.

I made it to allow loading images in a large `UICollectionView` while scrolling. When set properly this will load images needed by the collection view even if the user scrolls, and loading first images needed quickly.

This queue doesn't inherit from `OperationQueue` but should expose a similar enough interface to easily switch between the two.

```swift
public class SYOperationQueue {

    // Properties
    public enum Mode {
        case fifo, lifo
    }
    public var mode: Mode = .fifo
    public var name: String?
    public var operations: [Operation]
    public var operationsCount: Int
    public var isSuspended: Bool
    public var maxConcurrentOperationCount: Int
    public var maxSurvivingOperations: Int = 0 // 0 means no limit

    // Methods
    public func add(operation: Operation)
    public func addOperation(closure: @escaping () -> Void)
    public func cancelAllOperations()
}
 ```
