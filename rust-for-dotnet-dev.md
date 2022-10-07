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

- `Exception` to `Error` (`Display` + blanket/default implementation)
- `Result` instead of `try`/`catch`/`throw`
- Stack traces
- Panics, unwrapping, etc.
- short-circuiting and `?`

### Nullability and Optionality

- `Option` (defaulting)
- safe navigation: `?.` -> `map`
- elvis: `??` -> `unwrap_or_else`
- `if let`

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

- BenchmarkDotNet
- `cargo bench`

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
