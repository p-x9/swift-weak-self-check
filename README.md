# swift-weak-self-check

A CLI tool for `[weak self]` detection by `swift-syntax`

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/)

## Usage

```
OVERVIEW: Check whether `self` is captured by weak reference in Closure.

USAGE: weak-self-check [<path>] [--report-type <report-type>] [--silent] [--config <config>]

ARGUMENTS:
  <path>                  Path

OPTIONS:
  --report-type <report-type>
                          Detected as `error` or `warning` [default: error]
  --silent                Do not output logs
  --config <config>       Config (default: .swift-weak-self-check.yml)
  -h, --help              Show help information.
```

## License

swift-weak-self-check is released under the MIT License. See [LICENSE](./LICENSE)
