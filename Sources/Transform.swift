struct Transform {
  let process: (JSON) -> TransformResult
}

extension Transform {
  static func rename(from: String, to: String) -> Transform {
    return Transform { _ in
        return .failure(["Oops"])
    }
  }
}

enum TransformResult {
  case success(JSON)
  case failure([String])
}
