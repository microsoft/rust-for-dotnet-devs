# Rust for .NET Developers

## Getting Started

GitHub starter repo with:
- dev container
- Dockerfile
- rust toolchain file

## Language

### Scalar Types

| Rust  | C#    | .NET    | Note |
|-------|-------|---------|------|
| `i32` | `int` | `Int32` |      |

<https://doc.rust-lang.org/rust-by-example/primitives.html>

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

## ?

- Thread-Safety (`Sync`, `Send`, etc.)

## Channels

- `System.Threading.Channels`

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
