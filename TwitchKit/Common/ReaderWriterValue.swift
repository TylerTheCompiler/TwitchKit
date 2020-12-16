//
//  ReaderWriterValue.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/16/20.
//

/// Property wrapper for a value that is guarded by a reader-writer pattern using a
/// private concurrent queue and barrier blocks.
@propertyWrapper
public final class ReaderWriterValue<T> {
    
    /// The wrapped value.
    ///
    /// Reading this value happens synchronously on the private concurrent queue.
    /// Setting this value happens asynchronously in a barrier block on the private concurrent queue.
    public var wrappedValue: T {
        get { queue.sync { _value } }
        set { queue.async(flags: .barrier) { self._value = newValue } }
    }
    
    /// Creates a new reader-writer value.
    ///
    /// - Parameters:
    ///   - wrappedValue: The wrapped value.
    ///   - containingType: The type that contains the property that this property wrapper is wrapping. Used for
    ///                     naming the private queue that the wrapped value is guarded by.
    ///   - propertyName: The name of the property that this property wrapper is wrapping. Used for naming the private
    ///                   queue that the wrapped value is guarded by.
    public init(wrappedValue: T, _ containingType: Any.Type, propertyName: String) {
        _value = wrappedValue
        queue = DispatchQueue(
            for: containingType,
            name: propertyName + ".ReaderWriterValue.queue",
            attributes: .concurrent
        )
    }
    
    /// Allows you to read and change the wrapped value in a closure that is running in a barrier block on the
    /// private concurrent queue.
    ///
    /// - Parameters:
    ///   - handler: A closure that is passed a reference to the wrapped value which you may modify safely.
    ///   - wrappedValue: An inout parameter that is a reference to the wrapped value. You may read and set this value
    ///                   in a thread-safe manner.
    public func modify(_ handler: @escaping (_ wrappedValue: inout T) -> Void) {
        queue.async(flags: .barrier) { handler(&self._value) }
    }
    
    private var _value: T
    private let queue: DispatchQueue
}
