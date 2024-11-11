# swift-weak-self-check

A CLI tool for `[weak self]` detection by `swift-syntax`

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/swift-weak-self-check)](https://github.com/p-x9/swift-weak-self-check/)

## Usage

### CLI

```text
OVERVIEW: Check whether `self` is captured by weak reference in Closure.

USAGE: weak-self-check [<path>] [--report-type <report-type>] [--quick] [--silent] [--config <config>] [--index-store-path <index-store-path>]

ARGUMENTS:
  <path>                  Path

OPTIONS:
  --report-type <report-type>
                          Detected as `error` or `warning` (default: error)
  --quick                 Check more quicklys. (Not accurate as indexPath is
                          not used)
  --silent                Do not output logs
  --config <config>       Config (default: .swift-weak-self-check.yml)
  --index-store-path <index-store-path>
                          Path for IndexStore
  -h, --help              Show help information.
```

### SPM Plugin

- **WeakSelfCheckBuildToolPlugin**
  BuildToolPlugin
- **WeakSelfCheckCommandPlugin**
  CommandPlugin

### Configuration

It is possible to customise the configuration by placing a file named `.swift-weak-self-check.yml`.

Example file is available here: [swift-weak-self-check.yml](./.swift-weak-self-check.yml)

## Heuristic

Detection is performed under the following conditions and a warning/error is reported.

1. All functions called within a class are subject to traversal.
   - If it is in an extension, a decision is made as to whether it is a class or not based on the index-store information.
   - In quick mode, all functions in the extension are checked, regardless of whether they are classes or not.

2. Any closure present as an argument of the function is checked.
   - If the closure type is specified with a type defined by typealias, it is missed.

3. If the function is included in a whitelist in the config, it is skipped.

4. Check that `self` is used in the closure without `[weak self]` or `[unowned self]`.

5. Check that `@escaping` attribute is attached to the closure type of the function being called.
   - Information from the index-store is used. (So, not checked in quick mode).
   - It is not checked for c and objc functions.
   - If multiple closures are present in the function argument without labels, this check is not performed.

6. If the closure type is of type `Optional`, the warning is applicable even if the `@escaping` attribute is not attached.
   - In the case of optional closure types, there are cases where circular references are produced even when `@escaping` is not attached.

7. warning/error is reported

## License

swift-weak-self-check is released under the MIT License. See [LICENSE](./LICENSE)
