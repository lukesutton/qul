struct Transform<C> {
  let process: (C, JSON) -> TransformResult
}

extension Transform {
  static func rename<C>(from: String, to: String, needed: Bool = true) -> Transform<C> {
    return Transform<C> { _, _ in
        return .error(.fieldMissing(field: from, message: nil))
    }
  }
}

enum TransformResult {
  case success(JSON)
  case error(TransformError)
}

enum TransformError {
  case fieldMissing(field: String, message: String?)
  case unexpectedType(field: String, expected: String, found: String, message: String?)
  case other(field: String, message: String?, error: Error?)
}
