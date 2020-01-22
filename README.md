# Compiler Explorer

A native client for Matt Godbolt's [Compiler Explorer](https://github.com/mattgodbolt/compiler-explorer)
project.

## System Requirements

Xcode 11.3, macOS 10.15+.

## Building

We use [Xcodegen](https://github.com/yonaskolb/XcodeGen) for generating an Xcode project from the `project.yml` file.
This makes it easier to maintain the project configuration, and it's also more Git-friendly.

So, for building the project, first make sure you have installed the latest Xcodegen.
It can be installed via [Homebrew](https://brew.sh):

```
brew install xcodegen
```

Then, run:

```
xcodegen
open Compiler-Explorer.xcodeproj
```

Now you can use the generated Xcode project and build the app.

## License

Compiler Explorer is released under the MIT License, a copy of which is available in this
repository.

## Contributing

We welcome contributions from programmers of all backgrounds and experience
levels. We've strived to create an environment that encourages learning through
contribution, and we pledge to always treat contributors with the respect they
deserve. We have adopted the Contributor Covenant as our code of conduct,
which can be read in this repository.

For more info, and steps for a successful contribution, see the
[Contribution Guide](.github/CONTRIBUTING.md).

## Author(s)

Robert Widmann ([@CodaFi](https://github.com/codafi))
