# Members

## Constructors

Rust does not have any notion of constructors. Instead, you just write factory
functions that return an instance of the type. The factory functions can be
stand-alone or _associated functions_ of the type. In C# terms, associated
functions are like having static methods on a type. Conventionally, if there
is just one factory function for a `struct`, it's named `new`:

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

Since Rust functions (associated or otherwise) do not support overloading; the
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

  [enums]: enums.md
  [rs-api-C-CTOR]: https://rust-lang.github.io/api-guidelines/predictability.html?highlight=new#constructors-are-static-inherent-methods-c-ctor

## Methods (static & instance-based)

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

## Constants

Like in C#, a type in Rust can have constants. However, the most interesting
aspect to note is that Rust allows a type instance to be defined as a constant
too:

```rust
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    const ZERO: Point = Point { x: 0, y: 0 };
}
```

In C#, the same would require a static read-only field:

```c#
readonly record struct Point(int X, int Y)
{
    public static readonly Point Zero = new(0, 0);
}
```

## Events

Rust has no built-in support for type members to adverstise and fire events,
like C# has with the `event` keyword.

## Properties

In C#, fields of a type are generally private. They are then
protected/encapsulated by property members with accessor methods (`get` and
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

## Extension Methods

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
(2), the extension trait must be imported (1). Also note, the extension trait
identifier `StrWrapExt` can itself be discarded via `_` at the time of import
without affecting the availability of `wrap` for `String`.

## Visibility/Access modifiers

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

2. Since there are no class-based type hierarchies in Rust, there is no
   equivalent of `protected`.

## Mutability

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
