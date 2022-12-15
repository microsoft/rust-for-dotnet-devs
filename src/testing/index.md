# Testing

## Test organization

.NET solutions use separate projects to host test code, irrespective of the
test framework being used (xUnit, NUnit, MSTest, etc.) and the type of tests
(unit or integration) being wirtten. The test code therefore lives in a
separate assembly than the application or library code being tested. In Rust,
it is a lot more conventional for _unit tests_ to be found in a separate test
sub-module (conventionally) named `tests`, but which is placed in same _source
file_ as the application or library module code that is the subject of the
tests. This has two benefits:

- The code/module and its unit tests live side-by-side.

- There is no need for a workaround like `[InternalsVisibleTo]` that exists in
  .NET because the tests have access to internals by virtual of being a
  sub-module.

The test sub-module is annotated with the `#[cfg(test)]` attribute, which has
the effect that the entire module is (conditionally) compiled and run only
when the `cargo test` command is issued.

Within the test sub-modules, test functions are annotated with the `#[test]`
attribute.

Integration tests are usually in a directory called `tests` that sits adjacent
to the `src` directory with the unit tests and source. `cargo test` compiles
each file in that directory as a separate crate and run all the methods
annotated with `#[test]` attribute. Since it is understood that integration
tests in the `tests` directory, there is no need to mark the modules in there
with the `#[cfg(test)]` attribute.

See also:

- [Test Organization][test-org]

  [test-org]: https://doc.rust-lang.org/book/ch11-03-test-organization.html

## Running tests

As simple as it can be, the equivalent of `dotnet test` in Rust is `cargo test`.

The default behavior of `cargo test` is to run all the tests in parallel, but this can be configured to run consecutively using only a single thread:

    cargo test -- --test-threads=1

For more information, see "[Running Tests in Parallel or
Consecutively][tests-exec]".

  [tests-exec]: https://doc.rust-lang.org/book/ch11-02-running-tests.html#running-tests-in-parallel-or-consecutively

## Output in Tests

For very complex integration or end-to-end test, .NET developers sometimes log
what's happening during a test. The actual way they do this varies with each
test framework. For example, in NUnit, this is as simple as using
`Console.WriteLine`, but in XUnit, one uses `ITestOutputHelper`. In Rust, it's
similar to NUnit; that is, one simply writes to the standard output using
`println!`. The output captured during the running of the tests is not shown
by default unless `cargo test` is run the with `--show-output` option:

    cargo test --show-output

For more information, see "[Showing Function Output][test-output]".

  [test-output]: https://doc.rust-lang.org/book/ch11-02-running-tests.html#showing-function-output

## Assertions

.NET users have multiple ways to assert, depending on the framework being
used. For example, an assertion xUnit.net might look like:

```csharp
[Fact]
public void Something_Is_The_Right_Length()
{
    var value = "something";
    Assert.Equal(9, value.Length);
}
```

Rust does not require a separate framework or crate. The standard library
comes with built-in _macros_ that are good enough for most assertions in
tests:

- [`assert!`][assert]
- [`assert_eq!`][assert_eq]
- [`assert_ne!`][assert_ne]

Below is an example of `assert_eq` in action:

```rust
#[test]
fn something_is_the_right_length() {
    let value = "something";
    assert_eq!(9, value.len());
}
```

The standard library does not offer anything in the direction of data-driven
tests, such as `[Theory]` in xUnit.net.

  [assert]: https://doc.rust-lang.org/std/macro.assert.html
  [assert_eq]: https://doc.rust-lang.org/std/macro.assert_eq.html
  [assert_ne]: https://doc.rust-lang.org/std/macro.assert_ne.html

## Mocking

When writing tests for a .NET application or library, there exist several
frameworks, like Moq and NSubstitute, to mock out the dependencies of types.
There are similar crates for Rust too, like [`mockall`][mockall], that can
help with mocking. However, it is also possible to use [conditional
compilation] by making use of the [`cfg` attribute][cfg-attribute] as a simple
means to mocking without needing to rely on external crates or frameworks. The
`cfg` attribute conditionally includes the code it annotates based on a
configuration symbol, such as `test` for testing. This is not very different
to using `DEBUG` to conditionally compile code specifically for debug builds.
One downside of this approach is that you can only have one implementation for
all tests of the module.

When specified, the `#[cfg(test)]` attribute tells Rust to compile and run the
code only when executing the `cargo test` command, which behind-the-scenes
executes the compiler with `rustc --test`. The opposite is true for the
`#[cfg(not(test))]` attribute; it includes the annotated only when testing
with `cargo test`.

The example below shows mocking of a stand-alone function `var_os` from the
standard that reads and returns the value of an environment variable. It
conditionally imports a mocked version of the `var_os` function used by
`get_env`. When built with `cargo build` or run with `cargo run`, the compiled
binary will make use of `std::env::var_os`, but `cargo test` will instead
import `tests::var_os_mock` as `var_os`, thus causing `get_env` to use the
mocked version during testing:

```rust
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

/// Utility function to read an environmentvariable and return its value If
/// defined. It fails/panics if the valus is not valid Unicode.
pub fn get_env(key: &str) -> Option<String> {
    #[cfg(not(test))]                 // for regular builds...
    use std::env::var_os;             // ...import from the standard library
    #[cfg(test)]                      // for test builds...
    use tests::var_os_mock as var_os; // ...import mock from test sub-module

    let val = var_os(key);
    val.map(|s| s.to_str()     // get string slice
                 .unwrap()     // panic if not valid Unicode
                 .to_owned())  // convert to "String"
}

#[cfg(test)]
mod tests {
    use std::ffi::*;
    use super::*;

    pub(crate) fn var_os_mock(key: &str) -> Option<OsString> {
        match key {
            "FOO" => Some("BAR".into()),
            _ => None
        }
    }

    #[test]
    fn get_env_when_var_undefined_returns_none() {
        assert_eq!(None, get_env("???"));
    }

    #[test]
    fn get_env_when_var_defined_returns_some_value() {
        assert_eq!(Some("BAR".to_owned()), get_env("FOO"));
    }
}
```

  [mockall]: https://docs.rs/mockall/latest/mockall/
  [conditional compilation]: ../conditional-compilation/index.md
  [cfg-attribute]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-attribute

## Code coverage

There is sophisticated tooling for .NET when it comes to analyzing test code
coverage. In Visual Studio, the tooling is built-in and integrated. In Visual
Studio Code, plug-ins exist. .NET developers might be familiar with [coverlet]
as well.

Rust is providing [built-in code coverage implementations][built-in-cov] for
collecting test code coverage.

There are also plug-ins available for Rust to help with code coverage analysis.
It's not seamlessly integrated, but with some manual steps, developers can
analyze their code in a visual way.

The combination of [Coverage Gutters][coverage.gutters] plug-in for Visual
Studio Code and [Tarpaulin] allows visual analysis of the code coverage in
Visual Studio Code. Coverage Gutters requires an LCOV file. Other tools besides
[Tarpaulin] can be used to generate that file.

Once setup, run the following command:

```bash
cargo tarpaulin --ignore-tests --out Lcov
```

This generates an LCOV Code Coverage file. Once `Coverage Gutters: Watch` is
enabled, it will be picked up by the Coverage Gutters plug-in, which will show
in-line visual indicators about the line coverage in the source code editor.

> Note: The location of the LCOV file is essential. If a workspace (see [Project
> Structure]) with multiple packages is present and a LCOV file is generated in
> the root using `--workspace`, that is the file that is being used - even if
> there is a file present directly in the root of the package. It is quicker to
> isolate to the particular package under test rather than generating the LCOV
> file in the root.

[coverage.gutters]: https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters
[tarpaulin]: https://github.com/xd009642/tarpaulin
[coverlet]: https://github.com/coverlet-coverage/coverlet
[built-in-cov]: https://doc.rust-lang.org/stable/rustc/instrument-coverage.html#test-coverage
[project structure]: ../project-structure/index.md
