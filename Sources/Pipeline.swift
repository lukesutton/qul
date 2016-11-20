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

struct Pipeline {
  let transforms: [Transform]

  init(_ transforms: [Transform]) {
    self.transforms = transforms
  }

  init(_ transforms: Transform...) {
    self.transforms = transforms
  }

  func run(json: JSON) -> PipelineResult {
    let acc = PipelineAccumulator(json: json, errors: [])
    let result = transforms.reduce(acc) { memo, transform in
      switch transform.process(json) {
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

func +(lhs: Pipeline, rhs: Pipeline) -> Pipeline {
  return Pipeline(lhs.transforms + rhs.transforms)
}
