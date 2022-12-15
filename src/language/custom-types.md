# Custom Types

## Classes

Rust doesn't have classes. It only has structures or `struct`.

## Records

Rust doesn't have any construct for authoring records, neither like `record
struct` nor `record class` in C#.

## Structures (`struct`)

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
polymorphism via virtual dispatch using [trait objects].

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

## Interfaces

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

## Enumeration types (`enum`)

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

## Members

### Constructors

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

### Methods (static & instance-based)

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

### Constants

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

### Events

Rust has no built-in support for type members to adverstise and fire events,
like C# has with the `event` keyword.

### Properties

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

### Extension Methods

Extension methods in C# enable the developer to attach new statically-bound
methods to existing types, without needing to modify the original definition
of the type. In the following C# example, a new `Wrap` method is added to the
`StringBuilder` class _by extension_:

```csharp
using System;
using System.Text;
using Extensions; // (1)

var sb = new StringBuilder("Hello, World!");
sb.Wrap(">>> ", " <<<"); // (2)
Console.WriteLine(sb.ToString()); // Prints: >>> Hello, World! <<<

namespace Extensions
{
    static class StringBuilderExtensions
    {
        public static void Wrap(this StringBuilder sb,
                                string left, string right) =>
            sb.Insert(0, left).Append(right);
    }
}
```

Note that for an extension method to become available (2), the namespace with
the type containing the extension method must be imported (1). Rust offers a
very similar facility via traits, called _extension traits_. The following
example in Rust is the equivalent of the C# example above; it extends `String`
with the method `wrap`:

```rust
#![allow(dead_code)]

mod exts {
    pub trait StrWrapExt {
        fn wrap(&mut self, left: &str, right: &str);
    }

    impl StrWrapExt for String {
        fn wrap(&mut self, left: &str, right: &str) {
            self.insert_str(0, left);
            self.push_str(right);
        }
    }
}

fn main() {
    use exts::StrWrapExt as _; // (1)

    let mut s = String::from("Hello, World!");
    s.wrap(">>> ", " <<<"); // (2)
    println!("{s}"); // Prints: >>> Hello, World! <<<
}
```

Just like in C#, for the method in the extension trait to become available
(2), the extension trait muse be imported (1). Also note, the extension trait
identifier `StrWrapExt` can itself be discarded via `_` at the time of import
without affecting the availability of `wrap` for `String`.

### Visibility/Access modifiers

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

### Mutability

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
