//
//  SYOperationQueue.swift
//  SYOperationQueue
//
//  Created by Stan Chevallier on 13/12/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

import Foundation

public class SYOperationQueue: NSObject {
    
    // MARK: Init
    public override init() {
        super.init()
        queue.addObserver(self, forKeyPath: #keyPath(OperationQueue.operations), options: [], context: nil)
    }
    
    // MARK: Public properties
    public enum Mode {
        case fifo, lifo
    }
    public var mode: Mode = .fifo

    public var name: String? {
        get { queue.name }
        set { queue.name = newValue }
    }
    public var operations: [Operation] {
        lock.withLock { queue.operations + pendingOperations }
    }
    public var operationsCount: Int {
        lock.withLock { queue.operationCount + pendingOperations.count }
    }
    public var isSuspended: Bool {
        get { queue.isSuspended }
        set { queue.isSuspended = newValue }
    }
    public var maxConcurrentOperationCount: Int {
        get { queue.maxConcurrentOperationCount }
        set {
            queue.maxConcurrentOperationCount = newValue
            enqueueOperations()
        }
    }
    public var maxSurvivingOperations: Int = 0 {
        didSet {
            guard maxSurvivingOperations != oldValue else { return }
            guard maxSurvivingOperations == 0 || maxSurvivingOperations >= maxConcurrentOperationCount else {
                self.maxSurvivingOperations = self.maxConcurrentOperationCount
                return
            }
            purgeOldOperations()
            enqueueOperations()
        }
    }
    
    // MARK: Internal properties
    private var lock = NSLock()
    private var queue = OperationQueue()
    private var pendingOperations = [Operation]()
    
    // MARK: Public actions
    public func add(operation: Operation) {
        lock.withLock {
            pendingOperations.append(operation)
            purgeOldOperations()
            enqueueOperations()
        }
    }
    
    public func addOperation(closure: @escaping () -> Void) {
        add(operation: BlockOperation(block: closure))
    }
    
    public func cancelAllOperations() {
        lock.withLock {
            // do not clear the pending operations, allowing for them to reach completion, even as a cancelled operation
            pendingOperations.forEach { $0.cancel() }
            queue.cancelAllOperations()
        }
    }
    
    // MARK: Internal actions
    private func enqueueOperations() {
        while queue.maxConcurrentOperationCount < queue.operationCount {
            guard let operation = nextOperationToRun() else { return }
            queue.addOperation(operation)
        }
    }
    
    private func nextOperationToRun() -> Operation? {
        lock.withLock {
            guard pendingOperations.count > 0 else { return nil }
            switch mode {
            case .fifo: return pendingOperations.removeFirst()
            case .lifo: return pendingOperations.removeLast()
            }
        }
    }
    
    private func purgeOldOperations() {
        guard maxSurvivingOperations > 0 else { return } // purge is disabled
        
        lock.withLock {
            let numberOfItemsToPurge = min(max(0, operationsCount - maxSurvivingOperations), pendingOperations.count)
            let operationsToCancel: [Operation]
            switch mode {
            case .fifo: 
                let startIndex = pendingOperations.count - 1 - numberOfItemsToPurge
                operationsToCancel = Array(pendingOperations[startIndex...])
            case .lifo:
                let endIndex = pendingOperations.count - numberOfItemsToPurge
                operationsToCancel = Array(pendingOperations[0..<endIndex])
            }
            operationsToCancel.forEach { $0.cancel() }
        }
    }

    // MARK: Observation
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? OperationQueue) == queue, keyPath == #keyPath(OperationQueue.operations) {
            enqueueOperations()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
}
