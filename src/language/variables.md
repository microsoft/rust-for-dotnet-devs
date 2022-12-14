# Variables

Consider the following example around variable assignment in C#:

```csharp
int x = 5;
```

And the same in Rust:

```rust
let x: i32 = 5;
```

So far, the only visible difference between the two languages is that the
position of the type declaration is different. Also, both C# and Rust are
type-safe: the compiler guarantees that the value stored in a variable is always
of the designated type. The example can be simplified by using the compiler's
ability to automatically infer the types of the variable. In C#:

```csharp
var x = 5;
```

In Rust:

```rust
let x = 5;
```

When expanding the first example to update the value of the variable
(reassignment), the behavior of C# and Rust differ:

```csharp
var x = 5;
x = 6;
Console.WriteLine(x); // 6
```

In Rust, the identical statement will not compile:

```rust
let x = 5;
x = 6; // Error: cannot assign twice to immutable variable 'x'.
println!("{}", x);
```

In Rust, variables are _immutable_ by default. Once a value is bound to a name,
the variable's value cannot be changed. Variables can be made _mutable_ by
adding [`mut`][mut.rs] in front of the variable name:

```rust
let mut x = 5;
x = 6;
println!("{}", x); // 6
```

Rust offers an alternative to fix the example above that does not require
mutability through variable _shadowing_:

```rust
let x = 5;
let x = 6;
println!("{}", x); // 6
```

C# also supports shadowing, e.g. locals can shadow fields and type members can
shadow members from the base type. In Rust, the above example demonstrates
that shadowing also allows to change the type of a variable without changing
the name, which is useful if one wants to transform the data into different
types and shapes without having to come up with a distinct name each time.

See also:

- [Data races and race conditions] for more information around the implications
  of mutability
- [Scope and shadowing]
- [Memory management][memory-management-section] for explanations around
  _moving_ and _ownership_

[mut.rs]: https://doc.rust-lang.org/std/keyword.mut.html
[memory-management-section]: ../memory-management/index.md
[data races and race conditions]: https://doc.rust-lang.org/nomicon/races.html
[scope and shadowing]: https://doc.rust-lang.org/stable/rust-by-example/variable_bindings/scope.html#scope-and-shadowing
