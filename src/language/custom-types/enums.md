# Enumeration types (`enum`)

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

```rust,does_not_compile
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

  [derive]: https://doc.rust-lang.org/stable/reference/attributes/derive.html
