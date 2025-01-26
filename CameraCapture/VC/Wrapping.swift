//
//  Wrapping.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//




@propertyWrapper
struct Wrapping<Value: Comparable & AdditiveArithmetic> {
    var value: Value
    let range: Range<Value>
    
    init(wrappedValue value: Value, _ range: Range<Value>) {
//        precondition(range.contains(value))
        self.value = Self.wrap(value, in: range)
        self.range = range
    }
    
    var wrappedValue: Value {
        get { value }
        set {
            value = Self.wrap(newValue, in: range)
        }
    }
    
    static func wrap<T: Comparable & AdditiveArithmetic>(_ value: T, in range: Range<T>) -> T {
        var value = value
        while value < range.lowerBound {
            value += range.upperBound - range.lowerBound
        }
        while value > range.upperBound {
            value -= range.upperBound - range.lowerBound
        }
        return value
    }
}
