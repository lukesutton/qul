struct PipelineAccumulator {
  let json: JSON
  let errors: [TransformError]

  func update(json: JSON) -> PipelineAccumulator {
    return PipelineAccumulator(json: json, errors: errors)
  }

  func update(error: TransformError) -> PipelineAccumulator {
    return PipelineAccumulator(json: json, errors: self.errors + [error])
  }
}

enum PipelineResult {
  case success(JSON)
  case error(JSON, [TransformError])
}

struct Pipeline<C> {
  let transforms: [Transform<C>]

  init(_ transforms: [Transform<C>]) {
    self.transforms = transforms
  }

  init(_ transforms: Transform<C>...) {
    self.transforms = transforms
  }

  func run(context: C, json: JSON) -> PipelineResult {
    let acc = PipelineAccumulator(json: json, errors: [])
    let result = transforms.reduce(acc) { memo, transform in
      switch transform.process(context, json) {
      case let .success(json): return memo.update(json: json)
      case let .error(message): return memo.update(error: message)
      }
    }

    if result.errors.count > 0 {
      return .error(result.json, result.errors)
    }
    else {
      return .success(result.json)
    }
  }
}

func + <C>(lhs: Pipeline<C>, rhs: Pipeline<C>) -> Pipeline<C> {
  return Pipeline(lhs.transforms + rhs.transforms)
}

extension Pipeline {
  typealias Config = Dictionary<String, Any>
  typealias Factory<C> = (Config) -> Transform<C>?
  typealias Registry = Dictionary<String, Factory<C>>

  private static func defaultRegistry() -> [String: Factory<C>] {
    return [
      "rename": { config in
        guard let from = config["from"] as? String,
              let to = config["to"] as? String
                  else { return nil }
        let needed = config["needed"] as? Bool ?? true

        return Transform<C>.rename(from: from, to: to, needed: needed)
      }
    ]
  }

  static func hydrate(json: [Config], withRegistry: Registry? = nil) -> Pipeline<C>? {
    let registry = withRegistry ?? defaultRegistry()
    let transforms: [Transform<C>?] = json.map { config in
      guard let name = config["name"] as? String else { return nil }
      guard let factory = registry[name] else { return nil }
      return factory(config)
    }

    let valid: [Transform<C>] = transforms.reduce([]) { memo, t in
      guard let t = t else { return memo }
      return memo + [t]
    }

    if valid.count == transforms.count {
      return Pipeline<C>(valid)
    }
    else {
      return nil
    }
  }
}
