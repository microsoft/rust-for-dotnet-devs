# Equality

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
