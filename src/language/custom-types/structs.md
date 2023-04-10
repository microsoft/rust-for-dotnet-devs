# Structures (`struct`)

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
In Rust, it's the same. A type has to be consciously developed to be
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
