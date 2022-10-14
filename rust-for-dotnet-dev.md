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
implementation for `Error::source()`, the blanket (default) implementation
returns a `None`.

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

In C#, [discards][net-discards] express to the compiler and others to ignore the
results (or parts) of an expression.

There are multiple contexts where to apply this, for example as a basic example,
to ignore the result of an expression. In C# this looks like:

```csharp
_ = city.GetCityInformation(cityName);
```

In Rust, [ignoring the result of an expression][rust-ignoring-values] looks
identical:

```rust
_ = city.get_city_information(city_name);
```

Discards are also applied for deconstructing tuples in C#:

```csharp
var (_, second) = ("first", "second");
```

and, identically, in Rust:

```rust
let (_, second) = ("first", "second");
```

In addition to destructuring tuples, Rust offers
[destructuring][rust-destructuring] of structs and enums using `..`, where `..`
stands for the remaining part of a type:

```rust
struct Point {
    x: i32,
    y: i32,
    z: i32,
}

let origin = Point { x: 0, y: 0, z: 0 };

match origin {
    Point { x, .. } => println!("x is {}", x), // x is 0
}
```

When pattern matching, it is often useful to discard or ignore part of a
matching expression, e.g. in C#:

```csharp
_ = ("first", "second") switch
{
    ("first", _) => "first element matched",
    (_, _) => "first element did not match"
};
```

and again, this looks almost identical in Rust:

```rust
_ = match ("first", "second")
{
    ("first", _) => "first element matched",
    (_, _) => "first element did not match"
};
```

[net-discards]: https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/functional/discards
[rust-ignoring-values]: https://doc.rust-lang.org/stable/book/ch18-03-pattern-syntax.html#ignoring-values-in-a-pattern
[rust-destructuring]: https://doc.rust-lang.org/reference/patterns.html#destructuring

### Conversion & Casting

Both C# and Rust are statically-typed at compile time. Hence, after a variable
is declared, assigning a value of a value of a different type (unless it's
implicitly convertible to the target type) to the variable is prohibited. There
are several ways to convert types in C# that have an equivalent in Rust.

#### Implicit conversions

Implicit conversions exist in C# as well as in Rust (called [type coercions]).
Consider the following example:

```csharp
int intNumber = 1;
long longNumber = intNumber;
```

Rust is much more restrictive with respect to which type coercions are allowed:

```rust
let int_number: i32 = 1;
let long_number: i64 = int_number; // error: expected `i64`, found `i32`
```

An example for a valid implicit conversion using [subtyping][subtyping.rs] is:

```rust
fn bar<'a>() {
    let s: &'static str = "hi";
    let t: &'a str = s;
}
```

See also:

- [Deref coercion]
- [Subtyping and variance]

[type coercions]: https://doc.rust-lang.org/reference/type-coercions.html
[subtyping.rs]: https://github.com/rust-lang/rfcs/blob/master/text/0401-coercions.md#subtyping
[deref coercion]: https://doc.rust-lang.org/std/ops/trait.Deref.html#more-on-deref-coercion
[Subtyping and variance]: https://doc.rust-lang.org/reference/subtyping.html#subtyping-and-variance

#### Explicit conversions

If converting could cause a loss of information, C# requires explicit
conversions using a casting expression:

```csharp
double a = 1.2;
int b = (int)a;
```

Explicit conversions can potentially fail at run-time with exceptions like
`OverflowException` or `InvalidCastException` when _down-casting_.

Rust does not provide coercion between primitive types, but instead uses
[explicit conversion][casting.rs] using the [`as`][as.rs] keyword (casting).
Casting in Rust will not cause a panic.

```rust
let int_number: i32 = 1;
let long_number: i64 = int_number as _;
```

[casting.rs]: https://doc.rust-lang.org/rust-by-example/types/cast.html
[as.rs]: https://doc.rust-lang.org/reference/expressions/operator-expr.html#type-cast-expressions

#### Custom conversion

Commonly, .NET types provide user-defined conversion operators to convert one
type to another type. Also, `System.IConvertible` serves the purpose of
converting one type into another.

In Rust, the standard library contains an abstraction for converting a value
into a different type, in form of the [`From`][from.rs] trait and its
reciprocal, [`Into`][into.rs]. When implementing `From` for a type, a default
implementation for `Into` is automatically provided (called _blanket
implementation_ in Rust). The following example illustrates two of such type
conversions:

```rust
fn main() {
    let my_id = MyId("id".into()); // `into()` is implemented automatically due to the `From<&str>` trait implementation for `String`.
    println!("{}", String::from(my_id)); // This uses the `From<MyId>` implementation for `String`.
}

struct MyId(String);

impl From<MyId> for String {
    fn from(MyId(value): MyId) -> Self {
        value
    }
}
```

See also:

- [`TryFrom`][try-from.rs] and [`TryInto`][try-into.rs] for versions of `From`
  and `Into` which can fail.

[from.rs]: https://doc.rust-lang.org/std/convert/trait.From.html
[into.rs]: https://doc.rust-lang.org/std/convert/trait.Into.html
[try-from.rs]: https://doc.rust-lang.org/std/convert/trait.TryFrom.html
[try-into.rs]: https://doc.rust-lang.org/std/convert/trait.TryInto.html

## Memory Management

Like C# and .NET, Rust has _memory-safety_ to avoid a whole class of bugs
related to memory access, and which end up being the source of many security
vulnerabilities in software. However, Rust can guarantee memory-safety at
compile-time; there is no run-time (like the CLR) making checks. The one
exception here is array bound checks that are done by the compiled code at
run-time, be that the Rust compiler or the JIT compiler in .NET. Like C#, it
is also [possible to write unsafe code in Rust][unsafe-rust], and in fact,
both languages even share the same keyword, _literally_ `unsafe`, to mark
functions and blocks of code where memory-safety is no longer guaranteed.

  [unsafe-rust]: https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html

Rust has no garbage collector (GC). All memory management is entirely the
responsibility of the developer. That said, _safe Rust_ has rules around
ownership that ensure memory is freed _as soon as_ it's no longer in use (e.g.
when leaving the scope of a block or a function). The compiler does a
tremendous job, through (compile-time) static analysis, of helping manage that
memory through [ownership] rules. If violated, the compiler rejects the code
with a compilation error.

  [ownership]: https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html

In .NET, there is no concept of ownership of memory beyond the GC roots
(static fields, local variables on a thread's stack, CPU registers, handles,
etc.). It is the GC that walks from the roots during a collection to detemine
all memory in use by following references and purging the rest. When designing
types and writing code, a .NET developer can remain oblivious to ownership,
memory management and even how the garbage collector works for the most part,
except when performance-sensitive code requires paying attention to the amount
and rate at which objects are being allocated on the heap. In contrast, Rust's
ownership rules require the developer to explicitly think and express
ownership at all times and it impacts everything from the design of functions,
types, data structures to how the code is written. On top of that, Rust has
strict rules about how data is used such that it can identify at compile-time,
data [race conditions] as well as corruption issues (requiring thread-safety)
that could potentially occur at run-time. This section will only focus on
memory management and ownership.

  [race conditions]: https://doc.rust-lang.org/nomicon/races.html

There can only be one owner of some memory, be that on the stack or heap,
backing a structure at any given time in Rust. The compiler assigns
[lifetimes][lifetimes.rs] and tracks ownership. It is possible to pass or
yield ownership, which is called _moving_ in Rust. These ideas are briefly
illustrated in the example Rust code below:

  [lifetimes.rs]: https://doc.rust-lang.org/rust-by-example/scope/lifetime.html

```rust
#![allow(dead_code, unused_variables)]

struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let a = Point { x: 12, y: 34 }; // point owned by a
    let b = a;                      // b owns the point now
    println!("{}, {}", a.x, a.y);   // compiler error!
}
```

The first statement in `main` will allocate `Point` and that memory will be
owned by `a`. In the second statement, the ownership is moved from `a` to `b`
and `a` can no longer be used because it no longer owns anything or represents
valid memory. The last statement that tries to print the fields of the point
via `a` will fail compilation. Suppose `main` is fixed to read as follows:

```rust
fn main() {
    let a = Point { x: 12, y: 34 }; // point owned by a
    let b = a;                      // b owns the point now
    println!("{}, {}", b.x, b.y);   // ok, uses b
}   // point behind b is dropped
```

Note that when `main` exits, `a` and `b` will go out of scope. The memory
behind `b` will be released by virtue of the stack returning to its state
prior to `main` being called. In Rust, one says that the point behind `b` was
_dropped_. However, note that since `a` yielded its ownership of the point to
`b`, there is nothing to drop when `a` goes out of scope.

A `struct` in Rust can define code to execute when an instance is dropped by
implementing the [`Drop`][drop.rs] trait.

  [drop.rs]: https://doc.rust-lang.org/std/ops/trait.Drop.html

The rough equivalent of _dropping_ in C# would be a class [finalizer], but
while a finalizer is called _automatically_ by the GC at some future point,
dropping in Rust is always instantaneous and deterministic; that is, it
happens at the point the compiler has determined that an instance has no owner
based on scopes and lifetimes. In .NET, the equivalent of `Drop` would be
[`IDisposable`][IDisposable] and is implemented by types to release any
unmanaged resources or memory they hold. _Deterministic disposal_ is not
enforced or guaranteed, but the `using` statement in C# is typically used to
scope an instance of a disposable type such that it gets disposed
determinstically, at the end of the `using` statement's block.

  [finalizer]: https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/finalizers
  [IDisposable]: https://learn.microsoft.com/en-us/dotnet/api/system.idisposable

Rust has the notion of a global lifetime denoted by `'static`, which is a
reserved lifetime specifier. A very rough approximation in C# would be static
_read-only_ fields of types.

In C# and .NET, references are shared freely without much thought so the idea
of a single owner and yielding/moving ownership may seem very limiting in
Rust, but it is possible to have _shared ownership_ in Rust using the smart
pointer type [`Rc`][rc.rs]; it adds reference-counting. Each time [the smart
pointer is cloned][Rc::clone], the reference count is incremented. When the
clone drops, the reference count is decremented. The actual instance behind
the smart pointer is dropped when the reference count reaches zero. These
points are illustrated by the following examples that build on the previous:

  [rc.rs]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html
  [Rc::clone]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html#method.clone

```rust
#![allow(dead_code, unused_variables)]

use std::rc::Rc;

struct Point {
    x: i32,
    y: i32,
}

impl Drop for Point {
    fn drop(&mut self) {
        println!("Point dropped!");
    }
}

fn main() {
    let a = Rc::new(Point { x: 12, y: 34 });
    let b = Rc::clone(&a); // share with b
    println!("a = {}, {}", a.x, a.y); // okay to use a
    println!("b = {}, {}", b.x, b.y);
}

// prints:
// a = 12, 34
// b = 12, 34
// Point dropped!
```

Note that:

- `Point` implements the `drop` method of the `Drop` trait and prints a
  message when an instance of a `Point` is dropped.

- The point created in `main` is wrapped behind the smart pointer `Rc` and so
  the smart pointer _owns_ the point and not `a`.

- `b` gets a clone of the smart pointer that effectively increments the
  reference count to 2. Unlike the earlier example, where `a` transferred its
  ownership of point to `b`, both `a` and `b` own their own distinct clones of
  the smart pointer, so it is okay to continue to use `a` and `b`.

- The compiler will have determined that `a` and `b` go out of scope at the
  end of `main` and therefore injected calls to drop each. The `Drop`
  implementation of `Rc` will decrement the reference count and also drop what
  it owns if the reference count has reached zero. When that happens, the
  `Drop` implementation of `Point` will print the message, &ldquo;Point
  dropped!&rdquo; The fact that the message is printed once demonstrates that
  only one point was created, shared and dropped.

`Rc` is not thread-safe. For shared ownership in a multi-threaded program, the
Rust standard library offers [`Arc`][arc.rs] instead. The Rust language will
prevent the use of `Rc` across threads.

  [arc.rs]: https://doc.rust-lang.org/std/sync/struct.Arc.html

In .NET, value types (like `enum` and `struct` in C#) live on the stack and
reference types (`interface`, `record class` and `class` in C#) are
heap-allocated. In Rust, the kind of type (basically `enum` or `struct` _in
Rust_), does not determine where the backing memory will eventually live. By
default, it is always on the stack, but just the way .NET and C# have a notion
of boxing value types, which copies them to the heap, the way to allocate a
type on the heap is to box it using [`Box`][box.rs]:

  [box.rs]: https://doc.rust-lang.org/std/boxed/struct.Box.html

```rust
let stack_point = Point { x: 12, y: 34 };
let heap_point = Box::new(Point { x: 12, y: 34 });
```

Like `Rc` and `Arc`, `Box` is a smart pointer, but unlike `Rc` and `Arc`, it
exclusively owns the instance behind it. All of these smart pointers allocate
an instance of their type argument `T` on the heap.

The `new` keyword in C# creates an instance of a type, and while members such
as `Box::new` and `Rc::new` that you see in the examples may seem to have a
similar purpose, `new` has no special designation in Rust. It's merely a
_coventional name_ that is meant to denote a factory. In fact they are called
_associated functions_ of the type, which is Rust's way of saying static
methods.

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

### Test organization

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

### Running tests

As simple as it can be, the equivalent of `dotnet test` in Rust is `cargo test`.

The default behavior of `cargo test` is to run all the tests in parallel, but this can be configured to run consecutively using only a single thread:

    cargo test -- --test-threads=1

For more information, see "[Running Tests in Parallel or
Consecutively][tests-exec]".

  [tests-exec]: https://doc.rust-lang.org/book/ch11-02-running-tests.html#running-tests-in-parallel-or-consecutively

### Output in tests

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

### Assertions

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

### Mocking

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
  [conditional compilation]: #conditional-compilation
  [cfg-attribute]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-attribute

### Code coverage

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
> Structure](#project-structure)) with multiple packages is present and a LCOV
> file is generated in the root using `--workspace`, that is the file that is
> being used - even if there is a file present directly in the root of the
> package. It is quicker to isolate to the particular package under test
> rather than generating the LCOV file in the root.

[coverage.gutters]: https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters
[tarpaulin]: https://github.com/xd009642/tarpaulin
[coverlet]: https://github.com/coverlet-coverage/coverlet
[built-in-cov]: https://doc.rust-lang.org/stable/rustc/instrument-coverage.html#test-coverage

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

### Features

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
