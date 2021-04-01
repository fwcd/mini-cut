import Foundation

/// A map-like associative data structure that has an upper limit
/// for the number of items. Once full, every new item will cause
/// the least recently used item to get removed.
struct LRUCache<Key, Value> where Key: Hashable {
    private var values: [Key: LRUValue] = [:]
    private let limit: Int
    
    private struct LRUValue {
        var lastUse: Date
        let value: Value
    }
    
    init(limit: Int = 16) {
        self.limit = limit
    }
    
    /// Gets a value (O(1)) or sets a value (O(n), though only if full).
    subscript(key: Key) -> Value? {
        mutating get {
            if var lruValue = values[key] {
                lruValue.lastUse = Date()
                values[key] = lruValue
                return lruValue.value
            } else {
                return nil
            }
        }
        set {
            values[key] = newValue.map { LRUValue(lastUse: Date(), value: $0) }
            
            while values.count > limit {
                removeLRU()
            }
        }
    }
    
    /// Removes the least recently used item, if any. Time: O(n).
    mutating func removeLRU() {
        if let lru = values.min(by: { $0.value.lastUse < $1.value.lastUse }) {
            values[lru.key] = nil
        }
    }
}
