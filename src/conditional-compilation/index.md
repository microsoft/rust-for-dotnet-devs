# Conditional Compilation

Both .NET and Rust are providing the possibility for compiling specific code
based on external conditions.

In .NET it is possible to use the some [preprocessor directives][preproc-dir] in
order to control conditional compilation

```csharp
#if debug
    Console.WriteLine("Debug");
#else
    Console.WriteLine("Not debug");
#endif
```

In addition to predefined symbols, it is also possible to use the compiler
option _[DefineConstants]_ to define symbols that can be used with `#if`,
`#else`, `#elif` and `#endif` to compile source files conditionally.

In Rust it is possible to use the [`cfg attribute`][cfg],
the [`cfg_attr attribute`][cfg-attr] or the
[`cfg macro`][cfg-macro] to control conditional compilation

As per .NET, in addition to predefined symbols, it is also possible to use the
[compiler flag `--cfg`][cfg-flag] to arbitrarily set configuration options

The [`cfg attribute`][cfg] is requiring and evaluating a
`ConfigurationPredicate`

```rust
use std::fmt::{Display, Formatter};

struct MyStruct;

// This implementation of Display is only included when the OS is unix but foo is not equal to bar
// You can compile an executable for this version, on linux, with 'rustc main.rs --cfg foo=\"baz\"'
#[cfg(all(unix, not(foo = "bar")))]
impl Display for MyStruct {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str("Running without foo=bar configuration")
    }
}

// This function is only included when both unix and foo=bar are defined
// You can compile an executable for this version, on linux, with 'rustc main.rs --cfg foo=\"bar\"'
#[cfg(all(unix, foo = "bar"))]
impl Display for MyStruct {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str("Running with foo=bar configuration")
    }
}

// This function is panicking when not compiled for unix
// You can compile an executable for this version, on windows, with 'rustc main.rs'
#[cfg(not(unix))]
impl Display for MyStruct {
    fn fmt(&self, _f: &mut Formatter<'_>) -> std::fmt::Result {
        panic!()
    }
}

fn main() {
    println!("{}", MyStruct);
}
```

The [`cfg_attr attribute`][cfg-attr] conditionally includes attributes based on
a configuration predicate.

```rust
#[cfg_attr(feature = "serialization_support", derive(Serialize, Deserialize))]
pub struct MaybeSerializableStruct;

// When the `serialization_support` feature flag is enabled, the above will expand to:
// #[derive(Serialize, Deserialize)]
// pub struct MaybeSerializableStruct;
```

The built-in [`cfg macro`][cfg-macro] takes in a single configuration predicate
and evaluates to the true literal when the predicate is true and the false
literal when it is false.

```rust
if cfg!(unix) {
  println!("I'm running on a unix machine!");
}
```

See also:

- [Conditional compilation][conditional-compilation]

## Features

Conditional compilation is also helpful when there is a need for providing
optional dependencies. With cargo "features", a package defines a set of named
features in the `[features]` table of Cargo.toml, and each feature can either be
enabled or disabled. Features for the package being built can be enabled on the
command-line with flags such as `--features`. Features for dependencies can be
enabled in the dependency declaration in Cargo.toml.

See also:

- [Features][features]

[features]: https://doc.rust-lang.org/cargo/reference/features.html
[conditional-compilation]: https://doc.rust-lang.org/reference/conditional-compilation.html#conditional-compilation
[cfg]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-attribute
[cfg-flag]: https://doc.rust-lang.org/rustc/command-line-arguments.html#--cfg-configure-the-compilation-environment
[cfg-attr]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg_attr-attribute
[cfg-macro]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-macro
[preproc-dir]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/preprocessor-directives#conditional-compilation
[DefineConstants]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/language#defineconstants
