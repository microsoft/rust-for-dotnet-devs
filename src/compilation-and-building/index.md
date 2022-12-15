# Compilation and Building

## .NET CLI

The equivalent of the .NET CLI (`dotnet`) in Rust is [Cargo] (`cargo`). Both
tools are entry-point wrappers that simplify use of other low-level tools. For
example, although you could invoke the C# compiler directly (`csc`) or MSBuild
via `dotnet msbuild`, developers tend to use `dotnet build` to build their
solution. Similarly in Rust, while you could use the Rust compiler (`rustc`)
directly, using `cargo build` is generally far simpler.

[cargo]: https://doc.rust-lang.org/cargo/

## Building

Building an executable in .NET using [`dotnet build`][net-build-output]
restores pacakges, compiles the project sources into an [assembly]. The
assembly contain the code in Intermediate Language (IL) and can _typically_ be
run on any platform supported by .NET and provided the .NET runtime is
installed on the host. The assemblies coming from dependent packages are
generally co-located with the project's output assembly. [`cargo
build`][cargo-build] in Rust does the same, except the Rust compiler
statically links (although there exist other [linking options][linkage]) all
code into a single, platform-dependent, binary.

Developers use `dotnet publish` to prepare a .NET executable for distribution,
either as a _framework-dependent deployment_ (FDD) or _self-contained
deployment_ (SCD). In Rust, there is no equivalent to `dotnet publish` as the
build output already contains a single, platform-dependent binary for each
target.

When building a library in .NET using [`dotnet build`][net-build-output], it
will still generate an [assembly] containing the IL. In Rust, the build output
is, again, a platform-dependent, compiled library for each library target.

See also:

- [Crate]

[net-build-output]: https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-build#description
[assembly]: https://learn.microsoft.com/en-us/dotnet/standard/assembly/
[cargo-build]: https://doc.rust-lang.org/cargo/commands/cargo-build.html#cargo-build1
[linkage]: https://doc.rust-lang.org/reference/linkage.html
[crate]: https://doc.rust-lang.org/book/ch07-01-packages-and-crates.html

## Dependencies

In .NET, the contents of a project file define the build options and
dependencies. In Rust, when using Cargo, a `Cargo.toml` declares the
dependencies for a package. A typical project file will look like:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="morelinq" Version="3.3.2" />
  </ItemGroup>

</Project>
```

The equivalent `Cargo.toml` in Rust is defined as:

```toml
[package]
name = "hello_world"
version = "0.1.0"

[dependencies]
tokio = "1.0.0"
```

Cargo follows a convention that `src/main.rs` is the crate root of a binary
crate with the same name as the package. Likewise, Cargo knows that if the
package directory contains `src/lib.rs`, the package contains a library crate
with the same name as the package.

## Packages

NuGet is most commonly used to install packages, and various tools supported it.
For example, adding a NuGet package reference with the .NET CLI will add the
dependency to the project file:

  dotnet add package morelinq

In Rust this works almost the same if using Cargo to add packages.

  cargo add tokio

The most common package registry for .NET is [nuget.org] whereas Rust packages
are usually shared via [crates.io].

[nuget.org]: https://www.nuget.org/
[crates.io]: https://crates.io

## Static code analysis

Since .NET 5, the Roslyn analyzers come bundled with the .NET SDK and provide
code quality as well as code-style analysis. The equivalent linting tool in Rust
is [Clippy].

Similarly to .NET, where the build fails if warnings are present by setting
[`TreatWarningsAsErrors`][treat-warnings-as-errors] to `true`, Clippy can fail
if the compiler or Clippy emits warnings (`cargo clippy -- -D warnings`).

There are further static checks to consider adding to a Rust CI pipeline:

- Run [`cargo doc`][cargo-doc] to ensure that documentation is correct.
- Run [`cargo check --locked`][cargo-check] to enforce that the `Cargo.lock`
  file is up-to-date.

[clippy]: https://github.com/rust-lang/rust-clippy
[treat-warnings-as-errors]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/errors-warnings
[cargo-doc]: https://doc.rust-lang.org/cargo/commands/cargo-doc.html
[cargo-check]: https://doc.rust-lang.org/cargo/commands/cargo-check.html#manifest-options
