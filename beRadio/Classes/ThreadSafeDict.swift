import Foundation

class ThreadSafeDict<Key: Hashable, Value>: Sequence {
    private var internalDict: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.ThreadSafeDict.queue", attributes: .concurrent)

    func makeIterator() -> Dictionary<Key, Value>.Iterator {
        var dict: [Key: Value] = [:]
        queue.sync {
            dict = internalDict
        }
        return dict.makeIterator()
    }

    var keys: [Key] {
        var keysArray: [Key] = []
        queue.sync {
            keysArray = Array(internalDict.keys)
        }
        return keysArray
    }

    var values: [Value] {
        return queue.sync {
            return Array(internalDict.values)
        }
    }

    var count: Int {
        var countValue: Int = 0
        queue.sync {
            countValue = internalDict.count
        }
        return countValue
    }

    func set(_ value: Value, for key: Key) {
        queue.async(flags: .barrier) {
            self.internalDict[key] = value
        }
    }

    func get(_ key: Key) -> Value? {
        var value: Value?
        queue.sync {
            value = internalDict[key]
        }
        return value
    }

    func removeValue(forKey key: Key) {
        queue.async(flags: .barrier) {
            self.internalDict.removeValue(forKey: key)
        }
    }

    func removeAll() {
        queue.async(flags: .barrier) {
            self.internalDict = [:]
        }
    }

    subscript(key: Key) -> Value? {
        get {
            return get(key)
        }
        set(newValue) {
            if let value = newValue {
                set(value, for: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
}
