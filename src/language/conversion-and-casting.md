# Conversion and Casting

Both C# and Rust are statically-typed at compile time. Hence, after a variable
is declared, assigning a value of a value of a different type (unless it's
implicitly convertible to the target type) to the variable is prohibited. There
are several ways to convert types in C# that have an equivalent in Rust.

## Implicit conversions

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

## Explicit conversions

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

## Custom conversion

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
