# Rust for .NET Developers

## Getting Started

GitHub starter repo with:
- dev container
- Dockerfile
- rust toolchain file

## Language

### Scalar Types

The following table lists the primitive types in Rust and their equivalent in
C# and .NET:

| Rust    | C#        | .NET                   | Note             |
| ------- | --------- | ---------------------- | ---------------- |
| `bool`  | `bool`    | `Boolean`              |                  |
| `char`  | `char`    | `Char`                 | See note 1.      |
| `i8`    | `sbyte`   | `SByte`                |                  |
| `i16`   | `short`   | `Int16`                |                  |
| `i32`   | `int`     | `Int32`                |                  |
| `i64`   | `long`    | `Int32`                |                  |
| `i128`  |           | `Int128`               |                  |
| `isize` | `nint`    | `IntPtr`               |                  |
| `u8`    | `byte`    | `Byte`                 |                  |
| `u16`   | `ushort`  | `UInt16`               |                  |
| `u32`   | `uint`    | `UInt32`               |                  |
| `u64`   | `ulong`   | `UInt64`               |                  |
| `u128`  |           | `UInt128`              |                  |
| `usize` | `nuint`   | `UIntPtr`              |                  |
| `f32`   | `float`   | `Single`               |                  |
| `f64`   | `double`  | `Double`               |                  |
|         | `decimal` | `Decimal`              |                  |
| `()`    | `void`    | `Void` or `ValueTuple` | See notes 2 & 3. |
|         | `object`  | `Object`               | See note 3.      |

Notes:

1. [`char`][char.rs] in Rust and [`Char`][char.net] in .NET have different
   definitions. In Rust, `char` is 4 bytes wide that is a [Unicode scalar
   value], but in .NET, a `Char` is 2 bytes wides uses the UTF-16 encoding.
   For more information, see the [Rust `char` documentation][char.rs].

2. While a unit `()` (an empty tuple) in Rust is a _expressible value_, the
   closest cousin in C# would be `void` to represent nothing. However, `void`
   isn't an _expressible value_ except when using pointers and unsafe code. .NET
   has [`ValueTuple`][ValueTuple] that is an empty tuple, but C# does not have
   a literal syntax like `()` to represent. `ValueTuple` can be used in C#,
   but it's very uncommon. Unlike C#, [F# does have a unit type][unit.fs] like
   Rust.

3. While `void` and `object` are not scalar types (although scalars like `int`
   are sub-classes of `object` in the .NET type hierarchy), they've been
   included in the above table for convenience.

See also:

- [Primitives (Rust By Example)][primitives.rs]

[char.net]: https://learn.microsoft.com/en-us/dotnet/api/system.char
[char.rs]: https://doc.rust-lang.org/std/primitive.char.html
[Unicode scalar value]: https://www.unicode.org/glossary/#unicode_scalar_value
[ValueTuple]: https://learn.microsoft.com/en-us/dotnet/api/system.valuetuple?view=net-7.0
[unit.fs]: https://learn.microsoft.com/en-us/dotnet/fsharp/language-reference/unit-type
[primitives.rs]: https://doc.rust-lang.org/rust-by-example/primitives.html

### Strings

- &str = span, Box<str> = String, String = StringBuilder
- String formatting (`println!`, `format!`, etc.)

### Structured Types

- [Array][std-array]
- Span
- List
- Tuple
- Dictionary

### Custom Types

- Class = struct
- Struct = struct
- Record = struct
- Interface (default methods) = trait (default)
- Enums (discrimnated unions)
- Members:
  - Constructors (associated functions)
  - Methods (static & instance-based)
  - Constants (structs)
  - Events (channels)
  - No properties, only methods
  - Visibility/Access modifiers
- Mutability
- Local functions
- Lambda/Closures
- Overloading
- Extension methods (extension traits)
- Builder pattern
- `System.Object` members:
  - `Equals`
  - `ToString` (`Display`, `Debug`)
  - `GetHashCode`
  - `GetType` (pattern-matching and enums)
- Newtype (primitive obsession)

### Variables

- Mutability
- Shadowing
- Type inference
- Moving and ownership

### Namespaces

- Imports
- Modules
- Visibility/Accessibility modifiers (x-ref?)

### Equality

- reference vs value
- string equality

### Generics

### Polymorphism

- `impl IntoIter`
- Trait objects

### Inheritance

mix-ins via macros

[std-array]: https://doc.rust-lang.org/std/primitive.array.html

### Exception Handling

In .NET, an exception is a type that inherits from the
[`System.Exception`][net-system-exception] class. Exceptions are thrown if a
problem occurs in a code section. A thrown exception is passed up the stack
until the application handles it or the program terminates.

Rust does not have exceptions, but distinguishes between _recoverable_ and
_unrecoverable_ errors instead. A recoverable error represents a problem that
should be reported, but for which the program continues. Results of operations
that can fail with recoverable errors are of type [`Result<T, E>`][rust-result],
where `E` is the type of the error variant. The [`panic!`][panic] macro stops
execution when the program encounters an unrecoverable error. An unrecoverable
error is always a symptom of a bug.

#### Custom error types

In .NET, custom exceptions derive from the `Exception` class. The documentation
on [how to create user-defined exceptions][net-user-defined-exceptions] mentions
the following example:

```csharp
public class EmployeeListNotFoundException : Exception
{
    public EmployeeListNotFoundException()
    {
    }

    public EmployeeListNotFoundException(string message)
        : base(message)
    {
    }

    public EmployeeListNotFoundException(string message, Exception inner)
        : base(message, inner)
    {
    }
}
```

In Rust, one can implement the basic expectations for error values by
implementing the [`Error`][rust-std-error] trait. The minimal user-defined error
implementation in Rust is:

```rust
#[derive(Debug)]
pub struct EmployeeListNotFound;

impl std::fmt::Display for EmployeeListNotFound {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("Could not find employee list.")
    }
}

impl std::error::Error for EmployeeListNotFound {}
```

The equivalent to the .NET `Exception.InnerException` property is the
`Error::source()` method in Rust. However, it is not required to provide an
implementation for `Error::source()`, the blanket implementation returns a
`None`.

#### Raising exceptions

To raise an exception in C#, throw an instance of the exception:

```csharp
void ThrowIfNegative(int value)
{
    if (value < 0)
    {
        throw new ArgumentOutOfRangeException(nameof(value));
    }
}
```

For recoverable errors in Rust, return an `Ok` or `Err` variant from a method:

```rust
fn error_if_negative(value: i32) -> Result<(), &'static str> {
    if value < 0 {
        Err("Specified argument was out of the range of valid values. (Parameter 'value')")
    } else {
        Ok(())
    }
}
```

The [`panic!`][panic] macro creates unrecoverable errors:

```rust
fn panic_if_negative(value: i32) {
    if value < 0 {
        panic!("Specified argument was out of the range of valid values. (Parameter 'value')")
    }
}
```

#### Error propagation

In .NET, exceptions are passed up the stack until they are handled or the
program terminates. In Rust, unrecoverable errors behave similarly, but handling
them is uncommon.

Recoverable errors, however, need to be propagated and handled explicitly. Their
presence is always indicated by the Rust function or method signature. Catching
an exception allows you to take action based on the presence or absence of an
error in C#:

```csharp
void Write()
{
    try
    {
        File.WriteAllText("file.txt", "content");
    }
    catch (IOException)
    {
        Console.WriteLine("Writing to file failed.");
    }
}
```

In Rust, this is roughly equivalent to:

```rust
fn write() {
    match std::fs::File::create("temp.txt")
        .and_then(|mut file| std::io::Write::write_all(&mut file, b"content"))
    {
        Ok(_) => {}
        Err(_) => println!("Writing to file failed."),
    };
}
```


Frequently, recoverable errors need only be propagated instead of being handled.
For this, the method signature needs to be compatible with the types of the
propagated error. The [`?` operator][question-mark-operator] propagates errors
ergonomically:

```rust
fn write() -> Result<(), std::io::Error> {
    let mut file = std::fs::File::create("file.txt")?;
    std::io::Write::write_all(&mut file, b"content")?;
    Ok(())
}
```

**Note**: to propagate an error with the question mark operator the error
implementations need to be _compatible_, as described in [_a shortcut for
propagating errors_][propagating-errors-rust-book]. The most general
"compatible" error type is the error [trait object] `Box<dyn Error>`.

#### Stack traces

Throwing an unhandled exception in .NET will cause the runtime to print a stack
trace that allows debugging the problem with additional context.

For unrecoverable errors in Rust, [`panic!` Backtraces][panic-backtrace] offer a
similar behavior.

Recoverable errors in stable Rust do not yet support Backtraces, but it is
currently supported in experimental Rust when using the [provide method].

[net-system-exception]: https://learn.microsoft.com/en-us/dotnet/api/system.exception?view=net-6.0
[rust-result]: https://doc.rust-lang.org/std/result/enum.Result.html
[panic-backtrace]: https://doc.rust-lang.org/book/ch09-01-unrecoverable-errors-with-panic.html#using-a-panic-backtrace
[net-user-defined-exceptions]: https://learn.microsoft.com/en-us/dotnet/standard/exceptions/how-to-create-user-defined-exceptions
[rust-std-error]: https://doc.rust-lang.org/std/error/trait.Error.html
[provide method]: https://doc.rust-lang.org/std/error/trait.Error.html#method.provide
[question-mark-operator]: https://doc.rust-lang.org/std/result/index.html#the-question-mark-operator-
[panic]: https://doc.rust-lang.org/std/macro.panic.html
[propagating-errors-rust-book]: https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html#a-shortcut-for-propagating-errors-the--operator
[trait object]: https://doc.rust-lang.org/reference/types/trait-object.html

### Nullability and Optionality

In C#, `null` is often used to represent a value that is missing, absent or
logically uninitialized. For example:

```csharp
int? some = 1;
int? none = null;
```

Rust has no `null` and consequently no nullable context to enable. Optional or
missing values are instead represented by [`Option<T>`][option]. The
equivalent of the C# code above in Rust would be:

```rust
let some: Option<i32> = Some(1);
let none: Option<i32> = None;
```

`Option<T>` in Rust is practically identical to [`'T option`][opt.fs] from F#.

[opt.fs]: https://fsharp.github.io/fsharp-core-docs/reference/fsharp-core-option-1.html

#### Control flow with optionality

In C#, you may have been using `if`/`else` statements for controlling the flow
when using nullable values.

```csharp
uint? max = 10;
if (max is { } someMax)
{
    Console.WriteLine($"The maximum is {someMax}."); // The maximum is 10.
}
```

You can use pattern matching to achieve the same behavior in Rust:

It would even be more concise to use `if let`:

```rust
let max = Some(10u32);
if let Some(max) = max {
    println!("The maximum is {}.", max); // The maximum is 10.
}
```

#### Null-conditional operators

The null-conditional operators (`?.` and `?[]`) make dealing with `null` in C#
more ergonomic. In Rust, they are best replaced by using the [`map`][optmap]
method. The following snippets show the correspondence:

```csharp
string? some = "Hello, World!";
string? none = null;
Console.WriteLine(some?.Length); // 13
Console.WriteLine(none?.Length); // (blank)
```

```rust
let some: Option<String> = Some(String::from("Hello, World!"));
let none: Option<String> = None;
println!("{:?}", some.map(|s| s.len())); // Some(13)
println!("{:?}", none.map(|s| s.len())); // None
```

#### Null-coalescing operator

The null-coalescing operator (`??`) is typically used to default to another
value when a nullable is `null`:

```csharp
int? some = 1;
int? none = null;
Console.WriteLine(some ?? 0); // 1
Console.WriteLine(none ?? 0); // 0
```

In Rust, you can use [`unwrap_or`][unwrap-or] to get the same behavior:

```rust
let some: Option<i32> = Some(1);
let none: Option<i32> = None;
println!("{:?}", some.unwrap_or(0)); // 1
println!("{:?}", none.unwrap_or(0)); // 0
```

**Note**: If the default value is expensive to compute, you can use
`unwrap_or_else` instead. It takes a closure as an argument, which allows you to
lazily initialize the default value.

#### Null-forgiving operator

The null-forgiving operator (`!`) does not correspond to an equivalent construct
in Rust, as it only affects the compiler's static flow analysis in C#. In Rust,
there is no need to use a substitute for it.

[option]: https://doc.rust-lang.org/std/option/enum.Option.html
[optmap]: https://doc.rust-lang.org/std/option/enum.Option.html#method.map
[unwrap-or]: https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or

### Discards

### Conversion & Casting

- `From`
- `Into`
- `as`
- Especially parsing

## Memory Management

- Heap and stack
- Boxing
- Moving
- Smart pointers
- Lifetime (`'static`)
- Ownerships
- Dropping
- Arenas
- GC
- Pinning (`pin!` macro)

## Resource Management

- `Drop` trait = `IDisposable`

## Threading

- Thread-Safety (`Sync`, `Send`, etc.)
- `System.Threading.Channels`
- Synchronization primitives:
  - `lock` = `std::sync::Mutex`
  - read/write lock
  - etc

## Testing

- Mocking framework (macros) and conditional compilation
- Code coverage

## Benchmarking

Running benchmarks in Rust is done via [`cargo bench`][cargo-bench], a specific
command for `cargo` which is executing all the methods annotated with the
`#[bench]` attribute. This attribute is currently [unstable][bench-unstable] and
available only for the nightly channel.

.NET users can make use of `BenchmarkDotNet` library to benchmark methods and
track their performance. The equivalent of `BenchmarkDotNet` is a crate named
`Criterion`.

As per its [documentation][criterion-docs], `Criterion` collects and stores
statistical information from run to run and can automatically detect performance
regressions as well as measuring optimizations.

Using `Criterion` is possible to use the `#[bench]` attribute without moving to
the nightly channel.

As in `BenchmarkDotNet`, it is also possible to integrate benchmark results with
the [GitHub Action for Continuous Benchmarking][gh-action-bench]. `Criterion`,
in fact, supports multiple output formats, amongst which there is also the
`bencher` format, mimicking the nightly `libtest` benchmarks and compatible with
the above mentioned action.

[cargo-bench]: https://doc.rust-lang.org/cargo/commands/cargo-bench.html
[bench-unstable]: https://doc.rust-lang.org/rustc/tests/index.html#test-attributes
[criterion-docs]: https://bheisler.github.io/criterion.rs/book/index.html
[gh-action-bench]: https://github.com/benchmark-action/github-action-benchmark

## Logging and Tracing

## Conditional Compilation

- Features

## Environment and Configuration

- `env!` (cargo config)
- `env`

## LINQ

- Query syntax
- Method chaining
- Iterators (no `yield` yet?)
- Methods:
  - `Select` = `map`
  - `Aggregate` = `reduce`
  - etc

## Meta Programming

- macros (source generators)
- reflection?

## Asynchronous Programming

- Cancellation tokens and dropping
- Tasks, tokio (runtime), async/await (e.g. tasks are cold in Rust)
  - `Task.WhenAny` = `select!`
  - `Task.WhenAll` = ?
  - Timeouts
- `IAsyncEnumerable` and async streams in Rust

## Project Structure

- workspaces vs solutions
- Unit tests live in the same file as the main code
- Modules

## Compilation and Building

- Packages
  - Cargo
  - Dependency management
  - Compilation (assembly vs single binary)
  - Generics monomorphization
- Static code analysis
- CI
