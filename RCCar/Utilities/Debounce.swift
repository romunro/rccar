import Foundation

/**
 debounces functions.
 usage:
 let debouncedFunction = Debouncer(delay: 0.5)
 debouncedFunction.call({print"debounced"})
**/
public class Debouncer: NSObject {
    
    // MARK: Properties
    
    private var workItem: DispatchWorkItem?
    private let delay: DispatchTimeInterval
    private let queue = DispatchQueue(label: "Debouncer.queue", qos: .userInitiated)
    private let jobQueue = DispatchQueue(label: "Debouncer.jobQueue", qos: .userInitiated)
    
    /// Boolean indiciating that the debounce has been called.
    var wasCalled: Bool {
        return jobQueue.sync {
            return !(self.workItem?.isCancelled ?? true)
        }
    }
    
    // MARK: Lifecycle
    
    public init(delay: DispatchTimeInterval) {
        self.delay = delay
    }
    
    // MARK: Public Methods

    public func call(_ callback: @escaping (() -> Void)) {
        jobQueue.sync(flags: .barrier) {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: { [weak self] in
                callback()
                self?.cancel()
            })
            guard let workItem = workItem else {
                return
            }
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
    
    public func cancel() {
        jobQueue.sync(flags: .barrier) {
            workItem?.cancel()
            workItem = nil
        }
    }
}
