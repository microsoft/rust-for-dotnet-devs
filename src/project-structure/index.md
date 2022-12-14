# Project Structure

While there are conventions around structuring a project  in .NET, they are
less strict compared to the Rust project structure conventions. When creating
a two-project solution using Visual Studio 2022 (a class library and an xUnit
test project), it will create the following structure:

    .
    |   SampleClassLibrary.sln
    +---SampleClassLibrary
    |       Class1.cs
    |       SampleClassLibrary.csproj
    +---SampleTestProject
            SampleTestProject.csproj
            UnitTest1.cs
            Usings.cs

- Each project resides in a separate directory, with its own `.csproj` file.
- At the root of the repository is a `.sln` file.

Cargo uses the following conventions for the [package layout] to make it easy to
dive into a new Cargo [package][rust-package]:

    .
    +-- Cargo.lock
    +-- Cargo.toml
    +-- src/
    |   +-- lib.rs
    |   +-- main.rs
    +-- benches/
    |   +-- some-bench.rs
    +-- examples/
    |   +-- some-example.rs
    +-- tests/
        +-- some-integration-test.rs

- `Cargo.toml` and `Cargo.lock` are stored in the root of the package.
- `src/lib.rs` is the default library file, and `src/main.rs` is the default
  executable file (see [target auto-discovery]).
- Benchmarks go in the `benches` directory, integration tests go in the `tests`
  directory (see [testing][section-testing],
  [benchmarking][section-benchmarking]).
- Examples go in the `examples` directory.
- There is no separate crate for unit tests, unit tests live in the same file as
  the code (see [testing][section-testing]).

[package layout]: https://doc.rust-lang.org/cargo/guide/project-layout.html
[rust-package]: https://doc.rust-lang.org/cargo/appendix/glossary.html#package
[target auto-discovery]: https://doc.rust-lang.org/cargo/reference/cargo-targets.html#target-auto-discovery
[section-testing]: ../testing/index.md
[section-benchmarking]: ../benchmarking/index.md

## Managing large projects

For very large projects in Rust, Cargo offers [workspaces][cargo-workspaces] to
organize the project. A workspace can help manage multiple related packages that
are developed in tandem. Some projects use [_virtual
manifests_][cargo-virtual-manifest], especially when there is no primary
package.

[cargo-workspaces]: https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html
[cargo-virtual-manifest]: https://doc.rust-lang.org/cargo/reference/workspaces.html#virtual-workspace

## Managing dependency versions

When managing larger projects in .NET, it may be appropriate to manage the
versions of dependencies centrally, using strategies such as [Central Package
Management]. Cargo introduced [workspace inheritance] to manage dependencies
centrally.

[Central Package Management]: https://learn.microsoft.com/en-us/nuget/consume-packages/Central-Package-Management
[workspace inheritance]: https://doc.rust-lang.org/cargo/reference/workspaces.html#the-package-table
