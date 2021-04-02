extension String {
    /// Ensures that the string has at most the given length by taking its prefix.
    func truncated(to length: Int, appending suffix: String = "...") -> String {
        if count <= length {
            return self
        } else {
            let trunkLength = length - suffix.count
            return prefix(trunkLength) + suffix
        }
    }
}
