# Operator overloading

A custom type can overload an _overloadable operator_ in C#. Consider the
following example in C#:

```csharp
Console.WriteLine(new Fraction(5, 4) + new Fraction(1, 2));  // 14/8

public readonly record struct Fraction(int Numerator, int Denominator)
{
    public static Fraction operator +(Fraction a, Fraction b) =>
        new(a.Numerator * b.Denominator + b.Numerator * a.Denominator, a.Denominator * b.Denominator);

    public override string ToString() => $"{Numerator}/{Denominator}";
}
```

In Rust, many operators [can be overloaded via traits][ops.rs]. This is possible
because operators are syntactic sugar for method calls. For example, the `+`
operator in `a + b` calls the `add` method (see [operator overloading]):

```rust
use std::{fmt::{Display, Formatter, Result}, ops::Add};

struct Fraction {
    numerator: i32,
    denominator: i32,
}

impl Display for Fraction {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        f.write_fmt(format_args!("{}/{}", self.numerator, self.denominator))
    }
}

impl Add<Fraction> for Fraction {
    type Output = Fraction;

    fn add(self, rhs: Fraction) -> Fraction {
        Fraction {
            numerator: self.numerator * rhs.denominator + rhs.numerator * self.denominator,
            denominator: self.denominator * rhs.denominator,
        }
    }
}

fn main() {
    println!(
        "{}",
        Fraction { numerator: 5, denominator: 4 } + Fraction { numerator: 1, denominator: 2 }
    ); // 14/8
}

```

[ops.rs]: https://doc.rust-lang.org/core/ops/
[operator overloading]: https://doc.rust-lang.org/rust-by-example/trait/ops.html
