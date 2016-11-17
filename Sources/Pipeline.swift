struct PipelineAccumulator {
  let json: JSON
  let failures: [String]

  func update(json: JSON) -> PipelineAccumulator {
    return PipelineAccumulator(json: json, failures: failures)
  }

  func update(failures: [String]) -> PipelineAccumulator {
    return PipelineAccumulator(json: json, failures: self.failures + failures)
  }
}

enum PipelineResult {
  case success(JSON)
  case failure(JSON, [String])
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
    let acc = PipelineAccumulator(json: json, failures: [])
    let result = transforms.reduce(acc) { memo, transform in
      switch transform.process(json) {
      case let .success(json): return memo.update(json: json)
      case let .failure(messages): return memo.update(failures: messages)
      }
    }

    if result.failures.count > 0 {
      return .failure(result.json, result.failures)
    }
    else {
      return .success(result.json)
    }
  }
}

func +(lhs: Pipeline, rhs: Pipeline) -> Pipeline {
  return Pipeline(lhs.transforms + rhs.transforms)
}
