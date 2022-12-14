# Generics

Generics in C# provide a way to create definitions for types and methods that
can be parameterized over other types. This improves code reuse, type-safety
and performance (e.g. avoid run-time casts). Consider the following example
of a generic type that adds a timestamp to any value:

```csharp
using System;

sealed record Timestamped<T>(DateTime Timestamp, T Value)
{
    public Timestamped(T value) : this(DateTime.UtcNow, value) { }
}
```

Rust also has generics as shown by the equivalent of the above:

```rust
use std::time::*;

struct Timestamped<T> { value: T, timestamp: SystemTime }

impl<T> Timestamped<T> {
    fn new(value: T) -> Self {
        Self { value, timestamp: SystemTime::now() }
    }
}
```

See also:

- [Generic data types]

[Generic data types]: https://doc.rust-lang.org/book/ch10-01-syntax.html

## Generic type constraints

In C#, [generic types can be constrained][type-constraints.cs] using the `where`
clause. The following example shows such constraints in C#:

```csharp
using System;

// Note: records automatically implement `IEquatable`. The following
// implementation shows this explicitly for a comparison to Rust.
sealed record Timestamped<T>(DateTime Timestamp, T Value) :
    IEquatable<Timestamped<T>>
    where T : IEquatable<T>
{
    public Timestamped(T value) : this(DateTime.UtcNow, value) { }

    public bool Equals(Timestamped<T>? other) =>
        other is { } someOther
        && Timestamp == someOther.Timestamp
        && Value.Equals(someOther.Value);

    public override int GetHashCode() => HashCode.Combine(Timestamp, Value);
}
```

The same can be achieved in Rust:

```rust
use std::time::*;

struct Timestamped<T> { value: T, timestamp: SystemTime }

impl<T> Timestamped<T> {
    fn new(value: T) -> Self {
        Self { value, timestamp: SystemTime::now() }
    }
}

impl<T> PartialEq for Timestamped<T>
    where T: PartialEq {
    fn eq(&self, other: &Self) -> bool {
        self.value == other.value && self.timestamp == other.timestamp
    }
}
```

Generic type constraints are called [bounds][bounds.rs] in Rust.

In C# version, `Timestamped<T>` instances can _only_ be created for `T` which
implement `IEquatable<T>` themselves, but note that the Rust version is more
flexible because it `Timestamped<T>` _conditionally implements_ `PartialEq`.
This means that `Timestamped<T>` instances can still be created for some
non-equatable `T`, but then `Timestamped<T>` will not implement equality via
`PartialEq` for such a `T`.

See also:

- [Traits as parameters]
- [Returning types that implement traits]

[type-constraints.cs]: https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/generics/constraints-on-type-parameters
[bounds.rs]: https://doc.rust-lang.org/rust-by-example/generics/bounds.html
[Traits as parameters]: https://doc.rust-lang.org/book/ch10-02-traits.html#traits-as-parameters
[Returning types that implement traits]: https://doc.rust-lang.org/book/ch10-02-traits.html#returning-types-that-implement-traits
