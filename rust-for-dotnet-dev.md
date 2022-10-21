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

There are two string types in Rust: `String` and `&str`. The former is
allocated on the heap and the latter is a slice of a `String` or a `&str`.

The mapping of those to .NET is shown in the following table:

| Rust               | .NET                 | Note        |
| ------------------ | -------------------- | ----------- |
| `&mut str`         | `Span<char>`         |             |
| `&str`             | `ReadOnlySpan<char>` |             |
| `Box<str>`         | `String`             | see Note 1. |
| `String`           | `String`             |             |
| `String` (mutable) | `StringBuilder`      | see Note 1. |

There are differences in working with strings in Rust and .NET, but the
equivalents above should be a good starting point. One of the differences is
that Rust strings are UTF-8 encoded, but .NET strings are UTF-16 encoded.
Further .NET strings are immutable, but Rust strings can be mutable when declared
as such, for example `let s = &mut String::from("hello");`.

There are also differences in using strings due to the concept of ownership. To
read more about ownership with the String Type, see the [Rust Book][ownership-string-type-example].

[ownership-string-type-example]: https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html#the-string-type

Notes:

1. The `Box<str>` type in Rust is equivalent to the `String` type in .NET. The
   difference between the `Box<str>` and `String` types in Rust is that the
   former stores pointer and size while the latter stores pointer, size, and
   capacity, allowing `String` to grow in size. This is similar to the
   `StringBuilder` type in .NET once the Rust `String` is declared mutable.

C#:

```csharp
ReadOnlySpan<char> span = "Hello, World!";
string str = "Hello, World!";
StringBuilder sb = new StringBuilder("Hello, World!");
```

Rust:

```rust
let span: &str = "Hello, World!";
let str = Box::new("Hello World!");
let mut sb = String::from("Hello World!");
```

#### String Literals

String literals in .NET are immutable `String` types and allocated on the heap.
In Rust, they are `&'static str`, which is immutable and has a global lifetime
and does not get allocated on the heap; they're embedded in the compiled binary.

C#

```csharp
string str = "Hello, World!";
```

Rust

```rust
let str: &'static str = "Hello, World!";
```

C# verbatim string literals are equivalent to Rust raw string literals.

C#

```csharp
string str = @"Hello, \World/!";
```

Rust

```rust
let str = r#"Hello, \World/!"#;
```

C# UTF-8 string literals are equivalent to Rust byte string literals.

C#

```csharp
string str = "hello"u8;
```

Rust

```rust
let str = b"hello";
```

#### String Interpolation

C# has a built-in string interpolation feature that allows you to embed
expressions inside a string literal. The following example shows how to use
string interpolation in C#:

```csharp
string name = "John";
int age = 42;
string str = $"Person {{ Name: {name}, Age: {age} }}";
```

Rust does not have a built-in string interpolation feature. Instead, the
`format!` macro is used to format a string. The following example shows how to
use string interpolation in Rust:

```rust
let name = "John";
let age = 42;
let str = format!("Person {{ name: {}, age: {} }}", name, age);
```

Custom classes and structs can also be interpolated in C# due to the fact that
the `ToString()` method is available for each type as it inherits from `object`.

```csharp
class Person
{
    public string Name { get; set; }
    public int Age { get; set; }

    public override string ToString() =>
        $"Person {{ Name: {Name}, Age: {Age} }}";
}

var person = new Person { Name = "John", Age = 42 };
Console.Writeline(person);
```

In Rust, there is no default formatting implemented/inherited for each type.
Instead, the `std::fmt::Display` trait must be implemented for each type that
needs to be converted to a string.

```rust
use std::fmt::*;

struct Person {
    name: String,
    age: i32,
}

impl Display for Person {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "Person {{ name: {}, age: {} }}", self.name, self.age)
    }
}

let person = Person {
    name: "John".to_owned(),
    age: 42,
};

println!("{person}");
```

Another option is to use the `std::fmt::Debug` trait. The `Debug` trait is
implemented for all standard types and can be used to print the internal
representation of a type. The following example shows how to use the `derive`
attribute to print the internal representation of a custom struct using the
`Debug` macro. This declaration is used to automatically implement the `Debug`
trait for the `Person` struct:

```rust
#[derive(Debug)]
struct Person {
    name: String,
    age: i32,
}

let person = Person {
    name: "John".to_owned(),
    age: 42,
};

println!("{person:?}");
```

> Note: Using the :? format specifier will use the `Debug` trait to print the
> struct, where leaving it out will use the `Display` trait.

See also:

- [Rust by Example - Debug](https://doc.rust-lang.org/stable/rust-by-example/hello/print/print_debug.html?highlight=derive#debug)

### Structured Types

Commonly used object and collection types in .NET and their mapping to Rust
  
| C#           | Rust      |
| ------------ | --------- |
| `Array`      | `Array`   |
| `List`       | `Vec`     |
| `Tuple`      | `Tuple`   |
| `Dictionary` | `HashMap` |

#### Array

Fixed arrays are supported the same way in Rust as in .NET

C#:

```csharp
int[] someArray = new int[2] { 1, 2 };
```

Rust:

```rust
let someArray: [i32; 2] = [1,2];
```

#### List

In Rust the equivalent of a `List<T>` is a `Vec<T>`. Arrays can be converted
to Vecs and vice versa.

C#:

```csharp
var something = new List<string>
{
    "a",
    "b"
};

something.Add("c");
```

Rust:

```rust
let mut something = vec![
    "a".to_owned(),
    "b".to_owned()
];

something.push("c".to_owned());
```

#### Tuples

C#:

```csharp
var something = (1, 2)
Console.WriteLine($"a = {something.Item1} b = {something.Item2}");
```

Rust:

```rust
let something = (1, 2);
println!("a = {} b = {}", something.0, something.1);

// deconstruction supported
let (a, b) = something;
println!("a = {} b = {}", a, b);
```

> **NOTE**: Rust tuple elements cannot be named like in C#. The only way to
> access a tuple element is by using the index of the element or deconstructing
> the tuple.

#### Dictionary

In Rust the equivalent of a `Dictionary<TKey, TValue>` is a `Hashmap<K, V>`.

C#:

```csharp
var something = new Dictionary<string, string>
{
    { "Foo", "Bar" },
    { "Baz", "Qux" }
};

something.Add("hi", "there");
```

Rust:

```rust
let mut something = HashMap::from([
    ("Foo".to_owned(), "Bar".to_owned()),
    ("Baz".to_owned(), "Qux".to_owned())
]);

something.insert("hi".to_owned(), "there".to_owned());
```

See also:

- [Rust's standard library - Collections](https://doc.rust-lang.org/std/collections/index.html)

### Custom Types

#### Classes

Rust doesn't have classes. It only has structures or `struct`.

#### Records

Rust doesn't have any construct for authoring records, neither like `record
struct` nor `record class` in C#.

### Structures (`struct`)

Structures in Rust and C# share a few similarities:

- They are defined with the `struct` keyword, but in Rust, `struct` simply
  defines the data/fields. The behavioural aspects in terms of functions and
  methods, are defined separately in an _implementation block_ (`impl`).

- They can implement multiple traits in Rust just as they can implement
  multiple interfaces in C#.

- They cannot be sub-classed.

- They are allocated on stack by default, unless:
  - In .NET, boxed or cast to an interface.
  - In Rust, wrapped in a smart pointer like `Box`, `Rc`/`Arc`.

In C#, a `struct` is a way to model a _value type_ in .NET, which is typically
some domain-specific primitive or compound with value equality semantics. In
Rust, a `struct` is the primary construct for modeling any data structure (the
other being an `enum`).

A `struct` (or `record struct`) in C# has copy-by-value and value equality
semantics by default, but in Rust, this requires just one more step using [the
`#derive` attribute][derive] and listing the traits to be implemented:

  [derive]: https://doc.rust-lang.org/stable/reference/attributes/derive.html

```rust
#[derive(Clone, Copy, PartialEq, Eq, Hash)]
struct Point {
    x: i32,
    y: i32,
}
```

Value types in C#/.NET are usually designed by a developer to be immutable.
It's considered best practice speaking semantically, but the language does not
prevent designing a `struct` that makes destructive or in-place modifications.
In the Rust, it's the same. A type has to be consciously developed to be
immutable.

Since Rust doesn't have classes and consequently type hierarchies based on
sub-classing, shared behaviour is achieved via traits and generics and
polymorphism via virtual dispatch using [traits objects].

  [trait objects]: https://doc.rust-lang.org/book/ch17-02-trait-objects.html#using-trait-objects-that-allow-for-values-of-different-types

Consider following `struct` representing a rectangle in C#:

```c#
struct Rectangle
{
    public Rectangle(int x1, int y1, int x2, int y2) =>
        (X1, Y1, X2, Y2) = (x1, y1, x2, y2);

    public int X1 { get; }
    public int Y1 { get; }
    public int X2 { get; }
    public int Y2 { get; }

    public int Length => Y2 - Y1;
    public int Width => X2 - X1;

    public (int, int) TopLeft => (X1, Y1);
    public (int, int) BottomRight => (X2, Y2);

    public int Area => Length * Width;
    public bool IsSquare => Width == Length;

    public override string ToString() => $"({X1}, {Y1}), ({X2}, {Y2})";
}
```

The equivalent in Rust would be:

```rust
#![allow(dead_code)]

struct Rectangle {
    x1: i32, y1: i32,
    x2: i32, y2: i32,
}

impl Rectangle {
    pub fn new(x1: i32, y1: i32, x2: i32, y2: i32) -> Self {
        Self { x1, y1, x2, y2 }
    }

    pub fn x1(&self) -> i32 { self.x1 }
    pub fn y1(&self) -> i32 { self.y1 }
    pub fn x2(&self) -> i32 { self.x2 }
    pub fn y2(&self) -> i32 { self.y2 }

    pub fn length(&self) -> i32 {
        self.y2 - self.y1
    }

    pub fn width(&self)  -> i32 {
        self.x2 - self.x1
    }

    pub fn top_left(&self) -> (i32, i32) {
        (self.x1, self.y1)
    }

    pub fn bottom_right(&self) -> (i32, i32) {
        (self.x2, self.y2)
    }

    pub fn area(&self)  -> i32 {
        self.length() * self.width()
    }

    pub fn is_square(&self)  -> bool {
        self.width() == self.length()
    }
}

use std::fmt::*;

impl Display for Rectangle {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "({}, {}), ({}, {})", self.x1, self.y2, self.x2, self.y2)
    }
}
```

Note that a `struct` in C# inherits the `ToString` method from `object` and
therefore it _overrides_ the base implementation to provide a custom string
representation. Since there is no inheritance in Rust, the way a type
advertises support for some _formatted_ representation is by implementing the
`Display` trait. This then enables for an instance of the structure to
participate in formatting, such as shown in the call to `println!` below:

```rust
fn main() {
    let rect = Rectangle::new(12, 34, 56, 78);
    println!("Rectangle = {rect}");
}
```

### Interfaces

Rust doesn't have interfaces like those found in C#/.NET. It has _traits_,
instead. Similar to an interface, a trait represents an abstraction and its
members form a contract that must be fulfilled when implemented on a type.

Just the way interfaces can have default methods in C#/.NET (where a default
implementation body is provided as part of the interface definition), so can
traits in Rust. The type implementing the interface/trait can subsequently
provide a more suitable and/or optimized implementation.

C#/.NET interfaces can have all types of members, from properties, indexers,
events to methods, both static- and instance-based. Likewise, traits in Rust
can have (instance-based) method, associated functions (think static methods
in C#/.NET) and constants.

Apart from class hierarchies, interfaces are a core means of achieving
polymorphism via dynamic dispatch for cross-cutting abstractions. They enable
general-purpose code to be written against the abstractions represented by the
interfaces without much regard to the concrete types implementing them. The
same can be achieved with Rust's _trait objects_ in a limited fashion. A trait
object is essentially a _v-table_ (virtual table) identified with the `dyn`
keyword followed by the trait name, as in `dyn Shape` (where `Shape` is the
trait name). Trait objects always live behind a pointer, either a reference
(e.g. `&dyn Shape`) or the heap-allocated `Box` (e.g. `Box<dyn Shape>`). This
is somewhat like in .NET, where an interface is a reference type such that a
value type cast to an interface is automatically boxed onto the managed heap.
The passing limitation of trait objects mentioned earler, is that the original
implementing type cannot be recovered. In other words, whereas it's quite
common to downcast or test an interface to be an instance of some other
interface or sub- or concrete type, the same is not possible in Rust (without
additional effort and support).

### Enumeration types (`enum`)

In C#, an `enum` is a value type that maps symbolic names to integral values:

```c#
enum DayOfWeek
{
    Sunday = 0,
    Monday = 1,
    Tuesday = 2,
    Wednesday = 3,
    Thursday = 4,
    Friday = 5,
    Saturday = 6,
}
```

Rust has practically _identical_ syntax for doing the same:

```rust
enum DayOfWeek
{
    Sunday = 0,
    Monday = 1,
    Tuesday = 2,
    Wednesday = 3,
    Thursday = 4,
    Friday = 5,
    Saturday = 6,
}
```

Unlike in .NET, an instance of an `enum` type in Rust does not have any
pre-defined behaviour that's inherited. It cannot even participate in equality
checks as simple as `dow == DayOfWeek::Friday`. To bring it somewhat on par in
function with an `enum` in C#, use [the `#derive` attribute][derive] to
automatically have macros implement the commonly needed functionality:

```rust
#[derive(Debug,     // enables formatting in "{:?}"
         Clone,     // required by Copy
         Copy,      // enables copy-by-value semantics
         Hash,      // enables hash-ability for use in map types
         PartialEq  // enables value equality (==)
)]
enum DayOfWeek
{
    Sunday = 0,
    Monday = 1,
    Tuesday = 2,
    Wednesday = 3,
    Thursday = 4,
    Friday = 5,
    Saturday = 6,
}

fn main() {
    let dow = DayOfWeek::Wednesday;
    println!("Day of week = {dow:?}");

    if dow == DayOfWeek::Friday {
        println!("Yay! It's the weekend!");
    }

    // coerce to integer
    let dow = dow as i32;
    println!("Day of week = {dow:?}");

    let dow = dow as DayOfWeek;
    println!("Day of week = {dow:?}");
}
```

As the example above shows, an `enum` can be coerced to its assigned integral
value, but the opposite is not possible as in C# (although that sometimes has
the downside in C#/.NET that an `enum` instance can hold an unrepresented
value). Instead, it's up to the developer to provide such a helper function:

```rust
impl DayOfWeek {
    fn from_i32(n: i32) -> Result<DayOfWeek, i32> {
        use DayOfWeek::*;
        match n {
            0 => Ok(Sunday),
            1 => Ok(Monday),
            2 => Ok(Tuesday),
            3 => Ok(Wednesday),
            4 => Ok(Thursday),
            5 => Ok(Friday),
            6 => Ok(Saturday),
            _ => Err(n)
        }
    }
}
```

The `from_i32` function returns a `DayOfWeek` in a `Result` indicating success
(`Ok`) if `n` is valid. Otherwise it returns `n` as-is in a `Result`
indicating failure (`Err`):

```rust
let dow = DayOfWeek::from_i32(5);
println!("{dow:?}"); // prints: Ok(Friday)

let dow = DayOfWeek::from_i32(50);
println!("{dow:?}"); // prints: Err(50)
```

There exist crates in Rust that can help with implementing such mapping from
integral types instead of having to code them manually.

An `enum` type in Rust can also serve as a way to design (discriminated) union
types, which allow different _variants_ to hold data specific to each variant.
For example:

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);
let loopback = IpAddr::V6(String::from("::1"));
```

This form of `enum` declaration does not exist in C#, but it can be emulated
with (class) records:

```c#
var home = new IpAddr.V4(127, 0, 0, 1);
var loopback = new IpAddr.V6("::1");

abstract record IpAddr
{
    public sealed record V4(byte A, byte B, byte C, byte D): IpAddr;
    public sealed record V6(string Address): IpAddr;
}
```

The difference between the two is that the Rust definition produces a _closed
type_ over the variants. In other words, the compiler knows that there will be
no other variants of `IpAddr` except `IpAddr::V4` and `IpAddr::V6`, and it can
use that knowledge to make stricter checks. For example, in a `match`
expression that's akin to C#'s `switch` expression, the Rust compiler will
fail code unless all variants are covered. In contrast, the emulation with C#
actually creates a class hierarchy (albeit very succinctly expressed) and
since `IpAddr` is an _abstract base class_, the set of all types it can
represent is unknown to the compiler.

### Members

#### Constructors

Rust does not have any notion of constructors. Instead, you just write factory
functions that return an instance of the type. The factory functions can be
stand-alone or _associated functions_ of the type. In C# terms, associated
functions are like have static methods on a type. Conventionally, if there is
just one factory function for a `struct`, it's named `new`:

```rust
struct Rectangle {
    x1: i32, y1: i32,
    x2: i32, y2: i32,
}

impl Rectangle {
    pub fn new(x1: i32, y1: i32, x2: i32, y2: i32) -> Self {
        Self { x1, y1, x2, y2 }
    }
}
```

Since Rust functions (associated or otherwise) do not support overloading, the
factory functions have to be named uniquely. For example, below are some
examples of so-called constructors or factory functions available on `String`:

- `String::new`: creates an empty string.
- `String::with_capacity`: creates a string with an initial buffer capacity.
- `String::from_utf8`: creates a string from bytes of UTF-8 encoded text.
- `String::from_utf16`: creates a string from bytes of UTF-16 encoded text.

In the case of an `enum` type in Rust, the variants act as the constructors.
See [the section on enumeration types][enums] for more.

See also:

- [Constructors are static, inherent methods (C-CTOR)][rs-api-C-CTOR]

  [enums]: #enumeration-types-enum
  [rs-api-C-CTOR]: https://rust-lang.github.io/api-guidelines/predictability.html?highlight=new#constructors-are-static-inherent-methods-c-ctor

#### Methods (static & instance-based)

Like C#, Rust types (both `enum` and `struct`), can have static and
instance-based methods. In Rust-speak, a _method_ is always instance-based and
is identified by the fact that its first parameter is named `self`. The `self`
parameter has no type annotation since it's always the type to which the
method belongs. A static method is called an _associated function_. In the
example below, `new` is an associated function and the rest (`length`, `width`
and `area`) are methods of the type:

```rust
struct Rectangle {
    x1: i32, y1: i32,
    x2: i32, y2: i32,
}

impl Rectangle {
    pub fn new(x1: i32, y1: i32, x2: i32, y2: i32) -> Self {
        Self { x1, y1, x2, y2 }
    }

    pub fn length(&self) -> i32 {
        self.y2 - self.y1
    }

    pub fn width(&self)  -> i32 {
        self.x2 - self.x1
    }

    pub fn area(&self)  -> i32 {
        self.length() * self.width()
    }
}
```

#### Constants

Like in C#, a type in Rust can have constants. However, the most interesting
aspect to note is that Rust allows a type instance to be defined as a constant
too:

```rust
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    const EMPTY: ZERO = Point { x: 0, y: 0 };
}
```

In C#, the same would require a static read-only field:

```c#
readonly record struct Point(int X, int Y)
{
    public static readonly Point Zero = new(0, 0);
}
```

#### Events

Rust has no built-in support for type members to adverstise and fire events,
like C# has with the `event` keyword.

#### Properties

In C#, fields of a type are generally private. They are then
protected/encapsulated by property members with accessor methods (`get`, and
`set`) to read or write to those field. The accessor methods can contain extra
logic, for example, to either validate the value when being set or compute a
value when being read. Rust only has methods [where a getter is named after the
field (in Rust method names can share the same identifier as a field) and the
setter uses a `set_` prefix][get-set-name.rs].

  [get-set-name.rs]: https://github.com/rust-lang/rfcs/blob/master/text/0344-conventions-galore.md#gettersetter-apis

Below is an example showing how property-like accessor methods typically look
for a type in Rust:

```rust
struct Rectangle {
    x1: i32, y1: i32,
    x2: i32, y2: i32,
}

impl Rectangle {
    pub fn new(x1: i32, y1: i32, x2: i32, y2: i32) -> Self {
        Self { x1, y1, x2, y2 }
    }

    // like property getters (each shares the same name as the field)

    pub fn x1(&self) -> i32 { self.x1 }
    pub fn y1(&self) -> i32 { self.y1 }
    pub fn x2(&self) -> i32 { self.x2 }
    pub fn y2(&self) -> i32 { self.y2 }

    // like property setters

    pub fn set_x1(&mut self, val: i32) { self.x1 = val }
    pub fn set_y1(&mut self, val: i32) { self.y1 = val }
    pub fn set_x2(&mut self, val: i32) { self.x2 = val }
    pub fn set_y2(&mut self, val: i32) { self.y2 = val }

    // like computed properties

    pub fn length(&self) -> i32 {
        self.y2 - self.y1
    }

    pub fn width(&self)  -> i32 {
        self.x2 - self.x1
    }

    pub fn area(&self)  -> i32 {
        self.length() * self.width()
    }
}
```

#### Visibility/Access modifiers

C# has a number of accessibility or visibility modifiers:

- `private`
- `protected`
- `internal`
- `protected internal` (family)
- `public`

In Rust, a compilation is built-up of a tree of modules where modules contain
and define [_items_][items] like types, traits, enums, constants and
functions. Almost everything is private by default. One exception is, for
example, _associated items_ in a public trait, which are public by default.
This is similar to how members of a C# interface declared without any public
modifiers in the source code are public by default. Rust only has the `pub`
modifier to change the visibility with respect to the module tree. There
are variations of `pub` that change the scope of the public visibility:

- `pub(self)`
- `pub(super)`
- `pub(crate)`
- `pub(in PATH)`

For more details, see the [Visibility and Privacy][privis] section of The Rust
Reference.

  [privis]: https://doc.rust-lang.org/reference/visibility-and-privacy.html
  [items]: https://doc.rust-lang.org/reference/items.html

The table below is an approximation of the mapping of C# and Rust modifiers:

| C#                            | Rust         | Note        |
| ----------------------------- | ------------ | ----------- |
| `private`                     | (default)    | See note 1. |
| `protected`                   | N/A          | See note 2. |
| `internal`                    | `pub(crate)` |             |
| `protected internal` (family) | N/A          | See note 2. |
| `public`                      | `pub`        |             |

1. There is no keyword to denote private visibility; it's the default in Rust.

2. Since there are class-based type hierarchies in Rust, there is no
   equivalent of `protected`.

#### Mutability

When designing a type in C#, it is the responsiblity of the developer to
decide whether the a type is mutable or immutable; whether it supports
destructive or non-destructive mutations. C# does support an immutable design
for types with a _positional record declaration_ (`record class` or `readonly
record struct`). In Rust, mutability is expressed on methods through the type
of the `self` parameter as shown in the example below:

```rust
struct Point { x: i32, y: i32 }

impl Point {
    pub fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    // self is not mutable

    pub fn x(&self) -> i32 { self.x }
    pub fn y(&self) -> i32 { self.y }

    // self is mutable

    pub fn set_x(&mut self, val: i32) { self.x = val }
    pub fn set_y(&mut self, val: i32) { self.y = val }
}
```

In C#, you can do non-destructive mutations using `with`:

```c#
var pt = new Point(123, 456);
pt = pt with { X = 789 };
Console.WriteLine(pt.ToString()); // prints: Point { X = 789, Y = 456 }

readonly record struct Point(int X, int Y);
```

There is no `with` in Rust, but to emulate something similar in Rust, it has
to be baked into the type's design:

```rust
struct Point { x: i32, y: i32 }

impl Point {
    pub fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    pub fn x(&self) -> i32 { self.x }
    pub fn y(&self) -> i32 { self.y }

    // following methods consume self and return a new instance

    pub fn set_x(self, val: i32) -> Self { Self::new(val, self.y) }
    pub fn set_y(self, val: i32) -> Self { Self::new(self.x, val) }
}
```

- Overloading
- Extension methods (extension traits)
- Builder pattern
- `System.Object` members:
  - `Equals`
  - `ToString` (`Display`, `Debug`)
  - `GetHashCode`
  - `GetType` (pattern-matching and enums)
- Newtype (primitive obsession)

### Local Functions

C# and Rust offer local functions, but local functions in Rust are limited to
the equivalent of static local functions in C#. In other words, local
functions in Rust cannot use variables from their surrounding lexical scope;
but _closures_ can.

### Lambda and Closures

C# and Rust allow functions to be used as first-class values that enable
writing _higher-order functions_. Higher-order functions are essentially
functions that accept other functions as arguments to allow for the caller to
participate in the code of the called function. In C#, _type-safe function
pointers_ are represented by delegates with the most common ones being `Func`
and `Action`. The C# language allows ad-hoc instances of these delegates to be
created through _lambda expressions_.

Rust has function pointers too with the `fn` type being the simplest:

```rust
fn do_twice(f: fn(i32) -> i32, arg: i32) -> i32 {
    f(arg) + f(arg)
}

fn main() {
    let answer = do_twice(|x| x + 1, 5);
    println!("The answer is: {}", answer); // Prints: The answer is: 12
}
```

However, Rust makes a distinction between _function pointers_ (where `fn`
defines a type) and _closures_: a closure can reference variables from its
surrounding lexical scope, but not a function pointer. While C# also has
[function pointers][*delegate] (`*delegate`), the managed and type-safe
equivalent would be a static lambda expression.

  [*delegate]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/proposals/csharp-9.0/function-pointers

Functions and methods that accept closures are written with generic types that
are bound to one of the traits representing functions: `Fn`, `FnMut` and
`FnOnce`. When it's time to provide a value for a function pointer or a
closure, a Rust developer uses a _closure expression_ (like `|x| x + 1` in the
example above), which translates to the same as a lambda expression in C#.
Whether the closure expression creates a function pointer or a closure depends
on whether the closure expression references its context or not.

When a closure captures variables from its environment then ownership rules
come into play because the ownership ends up with the closure. For more
information, see the “[Moving Captured Values Out of Closures and the Fn
Traits][closure-move]” section of The Rust Programming Language.

  [closure-move]: https://doc.rust-lang.org/book/ch13-01-closures.html#moving-captured-values-out-of-closures-and-the-fn-traits

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

When comparing for equality in C#, this refers to testing for _equivalence_ in
some cases (also known as _value equality_), and in other cases it refers to
testing for _reference equality_, which tests whether two variables refer to the
same underlying object in memory. Every custom type can be compared for equality
because it inherits from `System.Object` (or `System.ValueType` for value types,
which inherits from `System.Object`), using either one of the abovementioned
semantics.

For example, when comparing for equivalence and reference equality in C#:

```csharp
var a = new Point(1, 2);
var b = new Point(1, 2);
var c = a;
Console.WriteLine(a == b); // (1) True
Console.WriteLine(a.Equals(b)); // (1) True
Console.WriteLine(a.Equals(new Point(2, 2))); // (1) True
Console.WriteLine(ReferenceEquals(a, b)); // (2) False
Console.WriteLine(ReferenceEquals(a, c)); // (2) True

record Point(int X, int Y);
```

1. The equality operator `==` and the `Equals` method on the `record Point`
   compare for value equality, since records support value-type equality by
   default.

2. Comparing for reference equality tests whether the variables refer to the
   same underlying object in memory.

Equivalently in Rust:

```rust
#[derive(Copy, Clone)]
struct Point(i32, i32);

fn main() {
    let a = Point(1, 2);
    let b = Point(1, 2);
    let c = a;
    println!("{}", a == b); // Error: "an implementation of `PartialEq<_>` might be missing for `Point`"
    println!("{}", a.eq(&b));
    println!("{}", a.eq(&Point(2, 2)));
}
```

The compiler error above illustrates that in Rust equality comparisons are
_always_ related to a trait implementation. To support a comparison using `==`,
a type must implement [`PartialEq`][partialeq.rs].

Fixing the example above means deriving `PartialEq` for `Point`. Per default,
deriving `PartialEq` will compare all fields for equality, which therefore have
to implement `PartialEq` themselves. This is comparable to the equality for
records in C#.

```rust
#[derive(Copy, Clone, PartialEq)]
struct Point(i32, i32);

fn main() {
    let a = Point(1, 2);
    let b = Point(1, 2);
    let c = a;
    println!("{}", a == b); // true
    println!("{}", a.eq(&b)); // true
    println!("{}", a.eq(&Point(2, 2))); // false
    println!("{}", a.eq(&c)); // true
}
```

See also:

- [`Eq`][eq.rs] for a stricter version of `PartialEq`.

[partialeq.rs]: https://doc.rust-lang.org/std/cmp/trait.PartialEq.html
[eq.rs]: https://doc.rust-lang.org/std/cmp/trait.Eq.html

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

Previous section on [memory management] explains the differences between .NET
and Rust when it comes to GC, ownership and finalizers. It is highly recommended
to read it.

This section is limited to providing an example of a fictional
_database connection_ involving a SQL connection to be properly
closed/disposed/dropped

```csharp
{
    using var db1 = new DatabaseConnection("Server=A;Database=DB1");
    using var db2 = new DatabaseConnection("Server=A;Database=DB2");

    // ...code using "db1" and "db2"...
}   // "Dispose" of "db1" and "db2" called here; when their scope ends

public class DatabaseConnection : IDisposable
{
    readonly string connectionString;
    SqlConnection connection; //this implements IDisposable

    public DatabaseConnection(string connectionString) =>
        this.connectionString = connectionString;

    public void Dispose()
    {
        //Making sure to dispose the SqlConnection
        this.connection.Dispose();
        Console.WriteLine("Closing connection: {this.connectionString}");
    }
}
```

```rust
struct DatabaseConnection(&'static str);

impl DatabaseConnection {
    // ...functions for using the database connection...
}

impl Drop for DatabaseConnection {
    fn drop(&mut self) {
        // ...closing connection...
        self.close_connection();
        // ...printing a message...
        println!("Closing connection: {}", self.0)
    }
}

fn main() {
    let _db1 = DatabaseConnection("Server=A;Database=DB1");
    let _db2 = DatabaseConnection("Server=A;Database=DB2");
    // ...code for making use of the database connection...
} // "Dispose" of "db1" and "db2" called here; when their scope ends
```

[memory management]: #memory-management

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

### Accessing environment variables

.NET provides access to environment variables via the
`System.Environment.GetEnvironmentVariable` method. This method retrieves the
value of an environment variable at runtime.

```csharp
using System;

public class Example
{
    const string VARIABLE_NAME = "ExampleVariable";

    public static void Main()
    {
        var exampleVariable = Environment.GetEnvironmentVariable(VARIABLE_NAME);
        if (string.IsNullOrEmpty(exampleVariable))
        {
            Console.WriteLine($"Variable '{VARIABLE_NAME}' not set.");
        }
        else
        {
            Console.WriteLine($"Variable '{VARIABLE_NAME}' set to '{exampleVariable}'.");
        }
    }
}
```

Rust is providing the same functionality of accessing an environment variable at
runtime via the `var` and `var_os` functions from the `std::env` module.

`var` function is returning a `Result<String, VarError>`, either returning the
variable if set or returning an error if the variable is not set or it is not
valid Unicode

`var_os` has a different signature giving back an `Option<OsString>`, either
returning some value if the variable is set, or returning None if the variable
is not set or it is containing not valid UTF-8

```rust
use std::env;


fn main() {
    let key = "ExampleVariable";
    match env::var(key) {
        Ok(val) => println!("{key}: {val:?}"),
        Err(e) => println!("couldn't interpret {key}: {e}"),
    }
}
```

```rust
use std::env;

fn main() {
    let key = "ExampleVariable";
    match env::var_os(key) {
        Some(val) => println!("{key}: {val:?}"),
        None => println!("{key} not defined in the enviroment"),
    }
}
```

Rust is also providing the functionality of accessing an environment variable at
compile time. The `env!` macro from `std::env` expands the value of the variable
at compile time, returning a `&'static str`. If the variable is not set, an
error is emitted.

```rust
use std::env;

fn main() {
    let example = env!("ExampleVariable");
    println!("{example}");
}
```

In .NET a compile time access to environment variables can be achieved, in a
less straightforward way, via [source generators][source-gen].

[source-gen]: https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/source-generators-overview

### Configuration

Configuration in .NET is possible with configuration providers. The framework is
providing several provider implementations via
`Microsoft.Extensions.Configuration` namespace and NuGet packages.

Configuration providers read configuration data from key-value pairs using
different sources and provide a unified view of the configuration via the
`IConfiguration` type.

```csharp
using Microsoft.Extensions.Configuration;

class Example {
    static void Main()
    {
        IConfiguration configuration = new ConfigurationBuilder()
            .AddEnvironmentVariables()
            .Build();
        
        var example = configuration.GetValue<string>("ExampleVar");

        Console.WriteLine(example);
    }
}
```

Other providers examples can be found in the official documentation
[Configurations provider in .NET][conf-net].

A similar configuration experience in Rust is available via use of third-party
crates such as [figment] or [config].

See the following example making use of [config] crate:

```rust
use config::{Config, Environment};

fn main() {
    let builder = Config::builder().add_source(Environment::default());

    match builder.build() {
        Ok(config) => {
            match config.get_string("examplevar") { 
                Ok(v) => println!("{v}"),
                Err(e) => println!("{e}")
            }
        },
        Err(_) => {
            // something went wrong
        }
    }
}

```

[conf-net]: https://learn.microsoft.com/en-us/dotnet/core/extensions/configuration-providers
[figment]: https://crates.io/crates/figment
[config]: https://crates.io/crates/config

## LINQ

This section discusses LINQ within the context and for the purpose of querying
or transforming sequences (`IEnumerable`/`IEnumerable<T>`) and typically
collections like lists, sets and dictionaries.

### `IEnumerable<T>`

The equivalent of `IEnumerable<T>` in Rust is [`IntoIterator`][into-iter.rs].
Just as an implementation of `IEnumerable<T>.GetEnumerator()` returns a
`IEnumerator<T>` in .NET, an implementation of `IntoIterator::into_iter`
returns an [`Iterator`][iter.rs]. However, when it's time to iterate over the
items of a container advertising iteration support through the said types,
both languages offer syntactic sugar in the form of looping constructs for
iteratables. In C#, there is `foreach`:

```csharp
using System;
using System.Text;

var values = new[] { 1, 2, 3, 4, 5 };
var output = new StringBuilder();

foreach (var value in values)
{
    if (output.Length > 0)
        output.Append(", ");
    output.Append(value);
}

Console.Write(output); // Prints: 1, 2, 3, 4, 5
```

In Rust, the equivalent is simply `for`:

```rust
use std::fmt::Write;

fn main() {
    let values = [1, 2, 3, 4, 5];
    let mut output = String::new();

    for value in values {
        if output.len() > 0 {
            output.push_str(", ");
        }
        // ! discard/ignore any write error
        _ = write!(output, "{value}");
    }

    println!("{output}");  // Prints: 1, 2, 3, 4, 5
}
```

The `for` loop over an iterable essentially gets desuraged to the following:

```rust
use std::fmt::Write;

fn main() {
    let values = [1, 2, 3, 4, 5];
    let mut output = String::new();

    let iter = &mut values.into_iter();         // get iterator
    loop {                                      // loop indefinitely
        match iter.next() {                     //   get next item
            Some(value) => {                    //   when there's an item, do...
                if output.len() > 0 {
                    output.push_str(", ");
                }
                _ = write!(output, "{value}");
            },
            None => {                           //   when no more items, ...
                break;                          //     break out of loop
            }
        }
    }

println!("{output}");
}
```

Rust's ownership and data race condition rules apply to all instances and
data, and iteration is no exception. So while looping over an array might look
straightforward and very similar to C#, one has to be mindful about ownership
when needing to iterate the same collection/iterable more than once. The
following example iteraters the list of integers twice, once to print their sum
and another time to determine and print the maximum integer:

```rust
fn main() {
    let values = vec![1, 2, 3, 4, 5];

    // sum all values

    let mut sum = 0;
    for value in values {
        sum += value;
    }
    println!("sum = {sum}");

    // determine maximum value

    let mut max = None;
    for value in values {
        if let Some(some_max) = max { // if max is defined
            if value > some_max {     // and value is greater
                max = Some(value)     // then note that new max
            }
        } else {                      // max is undefined when iteration starts
            max = Some(value)         // so set it to the first value
        }
    }
    println!("max = {max:?}");
}
```

However, the code above is rejected by the compiler due to a subtle
difference: `values` has been changed from an array to a [`Vec<int>`][vec.rs],
a _vector_, which is Rust's type for growable arrays (like `List<T>` in .NET).
The first iteration of `values` ends up _consuming_ each value as the integers
are summed up. In other words, the ownership of _each item_ in the vector
passes to the iteration variable of the loop: `value`. Since `value` goes out
of scope at the end of each iteration of the loop, the instance it owns is
dropped. Had `values` been a vector of heap-allocated data, the heap memory
backing each item would get freed as the loop moved to the next item. To fix
the problem, one has to request iteration over _shared_ references via
`&values` in the `for` loop. As a result, `value` ends up being a shared
reference to an item as opposed to taking its ownership.

  [vec.rs]: https://doc.rust-lang.org/stable/std/vec/struct.Vec.html

Below is the updated version of the previous example that compiles. The fix is
to simply replace `values` with `&values` in each of the `for` loops.

```rust
fn main() {
    let values = vec![1, 2, 3, 4, 5];

    // sum all values

    let mut sum = 0;
    for value in &values {
        sum += value;
    }
    println!("sum = {sum}");

    // determine maximum value

    let mut max = None;
    for value in &values {
        if let Some(some_max) = max { // if max is defined
            if value > some_max {     // and value is greater
                max = Some(value)     // then note that new max
            }
        } else {                      // max is undefined when iteration starts
            max = Some(value)         // so set it to the first value
        }
    }
    println!("max = {max:?}");
}
```

The ownership and dropping can be seen in action even with `values` being an
array instead of a vector. Consider just the summing loop from the above
example over an array of a structure that wraps an integer:

```rust
struct Int(i32);

impl Drop for Int {
    fn drop(&mut self) {
        println!("{} dropped", self.0)
    }
}

fn main() {
    let values = [Int(1), Int(2), Int(3), Int(4), Int(5)];
    let mut sum = 0;

    for value in values {
        sum += value.0;
    }

    println!("sum = {sum}");
}
```

`Int` implements `Drop` so that a message is printed when an instance get
dropped. Running the above code will print:

    value = Int(1)
    Int(1) dropped
    value = Int(2)
    Int(2) dropped
    value = Int(3)
    Int(3) dropped
    value = Int(4)
    Int(4) dropped
    value = Int(5)
    Int(5) dropped
    sum = 15

It's clear that each value is acquired and dropped while the loop is running.
Once the loop is complete, the sum is printed. If `values` in the `for` loop
is changed to `&values` instead, like this:

```rust
for value in &values {
    // ...
}
```

then the output of the program will change radically:

    value = Int(1)
    value = Int(2)
    value = Int(3)
    value = Int(4)
    value = Int(5)
    sum = 15
    Int(1) dropped
    Int(2) dropped
    Int(3) dropped
    Int(4) dropped
    Int(5) dropped

This time, values are acquired but not dropped while looping because each item
doesn't get owned by the interation loop's variable. The sum is printed ocne
the loop is done. Finally, when the `values` array that still owns all the the
`Int` instances goes out of scope at the end of `main`, its dropping in turn
drops all the `Int` instances.

These examples demonstrate that while iterating collection types may seem to
have a lot of parallels between Rust and C#, from the looping constructs to
the iteration abstractions, there are still subtle differences with respect to
ownership that not kept in mind at all times otherwise the compiler will end
up rejecting the code.

See also:

- [Iterator][iter-mod]
- [Iterating by reference]

[into-iter.rs]: https://doc.rust-lang.org/std/iter/trait.IntoIterator.html
[iter.rs]: https://doc.rust-lang.org/core/iter/trait.Iterator.html
[iter-mod]: https://doc.rust-lang.org/std/iter/index.html
[iterating by reference]: https://doc.rust-lang.org/std/iter/index.html#iterating-by-reference

### Operators

_Operators_ in LINQ are implemented in the form of C# extension methods that
can be chained together to form a set of operations, with the most common
forming a query over some sort of data source. C# also offers a SQL-inspired
_query syntax_ with clauses like `from`, `where`, `select`, `join` and others
that can serve as an alternative or a companion to method chaining. Many
imperative loops can be re-written as much more expressive and composable
queries in LINQ.

Rust does not offer anything like C#'s query syntax. It has methods, called
_[adapters]_ in Rust terms, over iteratable types and therefore directly
comparable to chaining of methods in C#. However, whlie rewriting an
imperative loop as LINQ code in C# is often beneficial in expressivity,
robustness and composability, there is a trade-off with performance.
Compute-bound imperative loops _usually_ run faster because they can be
optimised by the JIT compiler and there are fewer virtual dispatches or
indirect function invocations incurred. The surprising part in Rust is that
there is no performance trade-off between choosing to use method chains on an
abstraction like an iterator over writing an imperative loop by hand. It's
therefore far more common to see the former in code.

The following table lists the most common LINQ methods and their approximate
counterparts in Rust.

| .NET              | Rust         | Note        |
| ----------------- | ------------ | ----------- |
| `Aggregate`       | `reduce`     | See note 1. |
| `Aggregate`       | `fold`       | See note 1. |
| `All`             | `all`        |             |
| `Any`             | `any`        |             |
| `Concat`          | `chain`      |             |
| `Count`           | `count`      |             |
| `ElementAt`       | `nth`        |             |
| `GroupBy`         | -            |             |
| `Last`            | `last`       |             |
| `Max`             | `max`        |             |
| `Max`             | `max_by`     |             |
| `MaxBy`           | `max_by_key` |             |
| `Min`             | `min`        |             |
| `Min`             | `min_by`     |             |
| `MinBy`           | `min_by_key` |             |
| `Reverse`         | `rev`        |             |
| `Select`          | `map`        |             |
| `Select`          | `enumerate`  |             |
| `SelectMany`      | `flat_map`   |             |
| `SelectMany`      | `flatten`    |             |
| `SequenceEqual`   | `eq`         |             |
| `Single`          | `find`       |             |
| `SingleOrDefault` | `try_find`   |             |
| `Skip`            | `skip`       |             |
| `SkipWhile`       | `skip_while` |             |
| `Sum`             | `sum`        |             |
| `Take`            | `take`       |             |
| `TakeWhile`       | `take_while` |             |
| `ToArray`         | `collect`    | See note 2. |
| `ToDictionary`    | `collect`    | See note 2. |
| `ToList`          | `collect`    | See note 2. |
| `Where`           | `filter`     |             |
| `Zip`             | `zip`        |             |

1. The `Aggregate` overload not accepting a seed value is equivalent to
   `reduce`, while the `Aggregate` overload accepting a seed value corresponds
   to `fold`.

2. [`collect`][collect.rs] in Rust generally works for any collectible type,
   which is defined as [a type that can initialize itself from an iterator
   (see `FromIterator`)][FromIter.rs]. `collect` needs a target type, which
   the compiler sometimes has trouble inferring so the _turbofish_ (`::<>`) is
   often used in conjunction with it, as in `collect::<Vec<_>>()`. This is why
   `collect` appears next to a number of LINQ extension methods that convert
   an enumerable/iterable source to some collection type instance.

  [FromIter.rs]: https://doc.rust-lang.org/stable/std/iter/trait.FromIterator.html

The following example shows how similar transforming sequences in C# is to
doing the same in Rust. First in C#:

```csharp
var result =
    Enumerable.Range(0, 10)
              .Where(x => x % 2 == 0)
              .SelectMany(x => Enumerable.Range(0, x))
              .Aggregate(0, (acc, x) => acc + x);

Console.WriteLine(result); // 50
```

And in Rust:

```rust
let result = (0..10)
    .filter(|x| x % 2 == 0)
    .flat_map(|x| (0..x))
    .fold(0, |acc, x| acc + x);

println!("{result}"); // 50
```

[section-meta-programming]: #meta-programming
[adapters]: https://doc.rust-lang.org/std/iter/index.html#adapters
[collect.rs]: https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.collect

### Deferred execution (laziness)

Many operators in LINQ are designed to be lazy such that they only do work
when absolutely required. This enables composition or chaining of several
operations/methods without causing any side-effects. For example, a LINQ
operator can return an `IEnumerable<T>` that is initialized, but does not
produce, compute or materialize any items of `T` until iterated. The operator
is said to have _deferred execution_ semantics. If each `T` is computed as
iteration reaches it (as opposed to when iteration begins) then the operator
is said to _stream_ the results.

Rust iterators have the same concept of [_laziness_][iter-laziness] and
streaming.

  [iter-laziness]: https://doc.rust-lang.org/std/iter/index.html#laziness

In both cases, this allows _infinite sequences_ to be represented, where the
underlying sequence is infinite, but the developer decides how the sequence
should be terminated . The following example shows this in C#:

```csharp
foreach (var x in InfiniteRange().Take(5))
    Console.Write($"{x} "); // Prints "0 1 2 3 4"

IEnumerable<int> InfiniteRange()
{
    for (var i = 0; ; ++i)
        yield return i;
}
```

Rust supports the same concept through infinite ranges:

```rust
// Generators and yield in Rust are unstable at the moment, so
// instead, this sample uses Range:
// https://doc.rust-lang.org/std/ops/struct.Range.html

for value in (0..).take(5) {
    print!("{value} "); // Prints "0 1 2 3 4"
}
```

### Iterator Methods (`yield`)

C# has the `yield` keword that enables the developer to quickly write an
_iterator method_. The return type of an iterator method can be an
`IEnumerable<T>` or an `IEnumerator<T>`. The compiler then converts the body
of the method into a concrete implementation of the return type, instead of
the developer having to write a full-blown class each time.
_[Generators][generators.rs]_, as they're called in Rust, are still considered
an unstable feature at the time of this writing.

  [generators.rs]: https://doc.rust-lang.org/beta/unstable-book/language-features/generators.html

## Meta Programming

Metaprogramming can be seen as a way of writing code that writes/generates other
code.

Roslyn is providing a feature for metaprogramming in C#, available since .NET 5,
and called [`Source Generators`][source-gen]. Source generators can create new
C# source files at build-time that are added to the user's compilation. Before
`Source Generators` were introduced, Visual Studio has been providing a code
generation tool via [`T4 Text Templates`][T4]. An example on how T4 works is the
following [template] or its [concretization].

Rust is also providing a feature for metaprogramming: [macros]. There are
`declarative macros` and `procedural macros`.

Declarative macros allow you to write control structures that take an
expression, compare the resulting value of the expression to patterns, and then
run the code associated with the matching pattern.

The following example is the definition of the `println!` macro that it is
possible to call for printing some text `println!("Some text")`

```rust
macro_rules! println {
    () => {
        $crate::print!("\n")
    };
    ($($arg:tt)*) => {{
        $crate::io::_print($crate::format_args_nl!($($arg)*));
    }};
}
```

To understand more about how to write declarative macros, it is possible to read
the rust reference chapter [macros by example].

[Procedural macros] are different than declarative macros. Those accept some code
as an input, operate on that code, and produce some code as an output.

Another technique used in C# for metaprogramming is reflection. Rust is not
supporting reflection.

### Function-like macros

Function-like macros are in the following form: `function!(...)`

The following code snippet defines a function-like macro named
`print_something`, which is generating a `print_it` method for printing the
"Something" string.

In the lib.rs:

```rust
extern crate proc_macro;
use proc_macro::TokenStream;

#[proc_macro]
pub fn print_something(_item: TokenStream) -> TokenStream {
    "fn print_it() { println!(\"Something\") }".parse().unwrap()
}
```

In the main.rs:

```rust
use replace_crate_name_here::print_something;
print_something!();

fn main() {
    print_it();
}
```

### Derive macros

Derive macros can create new items given the token stream of a struct, enum, or
union. An example of a derive macro is the `#[derive(Clone)]` one, which is
generating the needed code for making the input struct/enum/union implement the
`Clone` trait.

In order to understand how to define a custom derive macro, it is possible to
read the rust reference for [derive macros]

[derive macros]: https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros

### Attribute macros

Attribute macros define new attributes which can be attached to rust items.
While working with asynchronous code, if making use of Tokio, the first step
will be to decorate the new asynchronous main with an attribute macro like the
following example:

```rust
#[tokio::main]
async fn main() {
    println!("Hello world");
}
```

In order to understand how to define a custom derive macro, it is possible to
read the rust reference for [attribute macros]

[attribute macros]: https://doc.rust-lang.org/reference/procedural-macros.html#attribute-macros

[source-gen]: https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/source-generators-overview
[T4]: https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2015/modeling/code-generation-and-t4-text-templates?view=vs-2015&redirectedfrom=MSDN
[template]: https://github.com/Azure/iotedge-lorawan-starterkit/blob/dev/LoRaEngine/modules/LoRaWanNetworkSrvModule/LoraTools/JsonReader.g.tt
[concretization]: https://github.com/Azure/iotedge-lorawan-starterkit/blob/dev/LoRaEngine/modules/LoRaWanNetworkSrvModule/LoraTools/JsonReader.g.cs
[macros]: https://doc.rust-lang.org/book/ch19-06-macros.html
[macros by example]: https://doc.rust-lang.org/reference/macros-by-example.html
[procedural macros]: https://doc.rust-lang.org/reference/procedural-macros.html

## Asynchronous Programming

Both .NET and Rust support asynchronous programming models, which look similar
to each other with respect to their usage. The following example shows, on a
very high level, how async code looks like in C#:

```csharp
async Task<string> PrintDelayed(string message, CancellationToken cancellationToken)
{
    await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken);
    return $"Message: {message}";
}
```

Rust code is structured similarly. The following sample relies on [async-std]
for the implementation of `sleep`:

```rust
use std::time::Duration;
use async_std::task::sleep;

async fn format_delayed(message: &str) -> String {
    sleep(Duration::from_secs(1)).await;
    format!("Message: {}", message)
}
```

1. The Rust [`async`][async.rs] keyword transforms a block of code into a state
   machine that implements a trait called [`Future`][future.rs], similarly to
   how the C# compiler transforms `async` code into a state machine. In both
   languages, this allows for writing asynchronous code sequentially.

2. Note that for both Rust and C#, asynchronous methods/functions are prefixed
   with the async keyword, but the return types are different. Asynchronous
   methods in C# indicate the full and actual return type because it can vary.
   For example, it is common to see some methods return a `Task<T>` while others
   return a `ValueTask<T>`. In Rust, it is enough to specify the _inner type_
   `String` because it's _always some future_; that is, a type that implements
   the `Future` trait.

3. The `await` keywords are in different positions in C# and Rust. In C#, a
   `Task` is awaited by prefixing the expression with `await`. In Rust,
   suffixing the expression with the `.await` keyword allows for _method
   chaining_, even though `await` is not a method.

See also:

- [Asynchronous programming in Rust]

[async-std]: https://docs.rs/async-std/latest/async_std/
[async.rs]: https://doc.rust-lang.org/std/keyword.async.html
[future.rs]: https://doc.rust-lang.org/std/future/trait.Future.html
[Asynchronous programming in Rust]: https://rust-lang.github.io/async-book/

### Executing tasks

From the following example the `PrintDelayed` method executes, even though it is
not awaited:

```csharp
var cancellationToken = CancellationToken.None;
PrintDelayed("message", cancellationToken); // Prints "message" after a second.
await Task.Delay(TimeSpan.FromSeconds(2), cancellationToken);

async Task PrintDelayed(string message, CancellationToken cancellationToken)
{
    await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken);
    Console.WriteLine(message);
}
```

In Rust, the same function invocation does not print anything.

```rust
use async_std::task::sleep;
use std::time::Duration;

#[tokio::main] // used to support an asynchronous main method
async fn main() {
    print_delayed("message"); // Prints nothing.
    sleep(Duration::from_secs(2)).await;
}

async fn print_delayed(message: &str) {
    sleep(Duration::from_secs(1)).await;
    println!("{}", message);
}
```

This is because futures are lazy: they do nothing until they are run. The most
common way to run a `Future` is to `.await` it. When `.await` is called on a
`Future`, it will attempt to run it to completion. If the `Future` is blocked,
it will yield control of the current thread. When more progress can be made, the
`Future` will be picked up by the executor and will resume running, allowing the
`.await` to resolve (see [`async/.await`][async-await.rs]).

While awaiting a function works from within other `async` functions, `main` [is
not allowed to be `async`][error-E0752]. This is a consequence of the fact that
Rust itself does not provide a runtime for executing asynchronous code. Hence,
there are libraries for executing asynchronous code, called [async runtimes].
[Tokio][tokio.rs] is such an async runtime, and it is frequently used.
[`tokio::main`][tokio-main.rs] from the above example marks the `async main`
function as entry point to be executed by a runtime, which is set up
automatically when using the macro.

[tokio.rs]: https://crates.io/crates/tokio
[tokio-main.rs]: https://docs.rs/tokio/latest/tokio/attr.main.html
[async-await.rs]: https://rust-lang.github.io/async-book/03_async_await/01_chapter.html#asyncawait
[error-E0752]: https://doc.rust-lang.org/error-index.html#E0752
[async runtimes]: https://rust-lang.github.io/async-book/08_ecosystem/00_chapter.html#async-runtimes
[executor.rs]: https://rust-lang.github.io/async-book/02_execution/04_executor.html

### Task cancellation

The previous C# examples included passing a `CancellationToken` to asynchronous
methods, as is considered best practice in .NET. `CancellationToken`s can be
used to abort an asynchronous operation.

Because futures are inert in Rust (they make progress only when polled),
cancellation works differently in Rust. When dropping a `Future`, the `Future`
will make no further progress. It will also drop all instantiated values up to
the point where the future is suspended due to some outstanding asynchronous
operation. This is why most asynchronous functions in Rust don't take an
argument to signal cancellation, and is why dropping a future is sometimes being
referred to as _cancellation_.

[`tokio_util::sync::CancellationToken`][cancellation-token.rs] offers an
equivalent to the .NET `CancellationToken` to signal and react to cancellation,
for cases where implementing the `Drop` trait on a `Future` is unfeasible.

[cancellation-token.rs]: https://docs.rs/tokio-util/latest/tokio_util/sync/struct.CancellationToken.html
[join-handle.rs]: https://docs.rs/tokio/latest/tokio/task/struct.JoinHandle.html#cancel-safety

### Executing multiple Tasks

In .NET, `Task.WhenAny` and `Task.WhenAll` are frequently used to handle the
execution of multiple tasks.

`Task.WhenAny` completes as soon as any task completes. Tokio, for example,
provides the [`tokio::select!`][tokio-select] macro as an alternative for
`Task.WhenAny`, which means to wait on multiple concurrent branches.

```csharp
var cancellationToken = CancellationToken.None;

var result =
    await Task.WhenAny(Delay(TimeSpan.FromSeconds(2), cancellationToken),
                       Delay(TimeSpan.FromSeconds(1), cancellationToken));

Console.WriteLine(result.Result); // Waited 1 second(s).

async Task<string> Delay(TimeSpan delay, CancellationToken cancellationToken)
{
    await Task.Delay(delay, cancellationToken);
    return $"Waited {delay.TotalSeconds} second(s).";
}
```

The same example for Rust:

```rust
use std::time::Duration;
use tokio::{select, time::sleep};

#[tokio::main]
async fn main() {
    let result = select! {
        result = delay(Duration::from_secs(2)) => result,
        result = delay(Duration::from_secs(1)) => result,
    };

    println!("{}", result); // Waited 1 second(s).
}

async fn delay(delay: Duration) -> String {
    sleep(delay).await;
    format!("Waited {} second(s).", delay.as_secs())
}
```

Again, there are crucial differences in semantics between the two examples. Most
importantly, `tokio::select!` will cancel all remaining branches, while
`Task.WhenAny` leaves it up to the user to cancel any in-flight tasks.

Similarly, `Task.WhenAll` can be replaced with [`tokio::join!`][tokio-join].

[tokio-select]: https://docs.rs/tokio/latest/tokio/macro.select.html
[tokio-join]: https://docs.rs/tokio/latest/tokio/macro.join.html

### Multiple consumers

In .NET a `Task` can be used across multiple consumers. All of them can await
the task and get notified when the task is completed or failed. In Rust, the
`Future` can not be cloned or copied, and `await`ing will move the ownership.
The `futures::FutureExt::shared` extension creates a cloneable handle to a
`Future`, which then can be distributed across multiple consumers.

```rust
use futures::FutureExt;
use std::time::Duration;
use tokio::{select, time::sleep, signal};
use tokio_util::sync::CancellationToken;

#[tokio::main]
async fn main() {
    let token = CancellationToken::new();
    let child_token = token.child_token();

    let bg_operation = background_operation(child_token);

    let bg_operation_done = bg_operation.shared();
    let bg_operation_final = bg_operation_done.clone();

    select! {
        _ = bg_operation_done => {},
        _ = signal::ctrl_c() => {
            token.cancel();
        },
    }

    bg_operation_final.await;
}

async fn background_operation(cancellation_token: CancellationToken) {
    select! {
        _ = sleep(Duration::from_secs(2)) => println!("Background operation completed."),
        _ = cancellation_token.cancelled() => println!("Background operation cancelled."),
    }
}
```

#### Asynchronous iteration

While in .NET there are [`IAsyncEnumerable<T>`][async-enumerable.net] and
[`IAsyncEnumerator<T>`][net-async-enumerator], Rust does not yet have an API for
asynchronous iteration in the standard library. To support asynchronous
iteration, the [`Stream`][stream.rs] trait from [`futures`][futures-stream.rs]
offers a comparable set of functionality.

In C#, writing async iterators has comparable syntax to when writing synchronous
iterators:

```csharp
await foreach (int item in RangeAsync(10, 3).WithCancellation(CancellationToken.None))
    Console.Write(item + " "); // Prints "10 11 12".

async IAsyncEnumerable<int> RangeAsync(int start, int count)
{
    for (int i = 0; i < count; i++)
    {
        await Task.Delay(TimeSpan.FromSeconds(i));
        yield return start + i;
    }
}
```

In Rust, there are several types that implement the `Stream` trait, and hence
can be used for creating streams, e.g. `futures::channel::mpsc`. For a syntax
closer to C#, [`async-stream`][tokio-async-stream] offers a set of macros that
can be used to generate streams succinctly.

```rust
use async_stream::stream;
use futures_core::stream::Stream;
use futures_util::{pin_mut, stream::StreamExt};
use std::{
    io::{stdout, Write},
    time::Duration,
};
use tokio::time::sleep;

#[tokio::main]
async fn main() {
    let stream = range(10, 3);
    pin_mut!(stream); // needed for iteration
    while let Some(result) = stream.next().await {
        print!("{} ", result); // Prints "10 11 12".
        stdout().flush().unwrap();
    }
}

fn range(start: i32, count: i32) -> impl Stream<Item = i32> {
    stream! {
        for i in 0..count {
            sleep(Duration::from_secs(i as _)).await;
            yield start + i;
        }
    }
}
```

[async-enumerable.net]: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.iasyncenumerable-1
[async-enumerator.net]: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.iasyncenumerator-1
[stream.rs]: https://rust-lang.github.io/async-book/05_streams/01_chapter.html
[futures-stream.rs]: https://docs.rs/futures/latest/futures/stream/trait.Stream.html
[tokio-async-stream]: https://github.com/tokio-rs/async-stream

## Project Structure

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

Cargo uses the following conventions for the [package
layout][cargo-package-layout] to make it easy to dive into a new Cargo
[package][rust-package]:

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
[section-testing]: #Testing
[section-benchmarking]: #Benchmarking

### Namespaces

Namespaces are used in .NET to organize types, as well as for controlling the
scope of types and methods in projects.

In Rust, namespace refers to a different concept. The equivalent of a namespace
in Rust is a [module][rust-module]. For both C# and Rust, visibility of items
can be restricted using access modifiers, respectively visibility modifiers. In
Rust, the default visibility is _private_ (with only few exceptions). The
equivalent of C#'s `public` is `pub` in Rust, and `internal` corresponds to
`pub(crate)`. For more fine-grained access control, refer to the [visibility
modifiers] reference.

[rust-module]: https://doc.rust-lang.org/reference/items/modules.html
[visibility modifiers]: https://doc.rust-lang.org/reference/visibility-and-privacy.html

### Managing large projects

For very large projects in Rust, Cargo offers [workspaces][cargo-workspaces] to
organize the project. A workspace can help manage multiple related packages that
are developed in tandem. Some projects use [_virtual
manifests_][cargo-virtual-manifest], especially when there is no primary
package.

[cargo-workspaces]: https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html
[cargo-virtual-manifest]: https://doc.rust-lang.org/cargo/reference/workspaces.html#virtual-workspace

### Managing dependency versions

When managing larger projects in .NET, it may be appropriate to manage the
versions of dependencies centrally, using strategies such as [Central Package
Management]. Cargo introduced [workspace inheritance] to manage dependencies
centrally.

[Central Package Management]: https://learn.microsoft.com/en-us/nuget/consume-packages/Central-Package-Management
[workspace inheritance]: https://doc.rust-lang.org/cargo/reference/workspaces.html#the-package-table

## Compilation and Building

### .NET CLI

The equivalent of the .NET CLI (`dotnet`) in Rust is [Cargo] (`cargo`). Both
tools are entry-point wrappers that simplify use of other low-level tools. For
example, although you could invoke the C# compiler directly (`csc`) or MSBuild
via `dotnet msbuild`, developers tend to use `dotnet build` to build their
solution. Similarly in Rust, while you could use the Rust compiler (`rustc`)
directly, using `cargo build` is generally far simpler.

[cargo]: https://doc.rust-lang.org/cargo/

### Building

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

### Dependencies

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

### Packages

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

### Static code analysis

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
