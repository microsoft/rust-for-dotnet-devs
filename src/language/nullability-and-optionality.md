# Nullability and Optionality

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

## Control flow with optionality

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

## Null-conditional operators

The null-conditional operators (`?.` and `?[]`) make dealing with `null` in C#
more ergonomic. In Rust, they are best replaced by using either the [`map`][optmap]
method or the [`and_then`][opt_and_then] method, depending on the nesting of the `Option`.
The following snippets show the correspondence:

```csharp
string? some = "Hello, World!";
string? none = null;
Console.WriteLine(some?.Length); // Hello, World!
Console.WriteLine(none?.Length); // (blank)

record Name(string FirstName, string LastName);
record Person(Name? Name);

Person? person1 = new Person(new Name("John", "Doe"));
Console.WriteLine(person1?.Name?.FirstName); // John
Person? person2 = new Person(null);
Console.WriteLine(person2?.Name?.FirstName); // (blank)
Person? person3 = null;
Console.WriteLine(person3?.Name?.FirstName); // (blank)
```

```rust
let some: Option<String> = Some(String::from("Hello, World!"));
let none: Option<String> = None;
println!("{:?}", some.map(|s| s.len())); // Some("Hello, World!")
println!("{:?}", none.map(|s| s.len())); // None

struct Name { first_name: String, last_name: String }
struct Person { name: Option<Name> }
let person1: Option<Person> = Some(Person { name: Some(Name { first_name: "John".into(), last_name: "Doe".into() }) });
println!("{:?}", person1.and_then(|p| p.name.map(|name| name.first_name))); // Some("John")
let person1: Option<Person> = Some(Person { name: None });
println!("{:?}", person1.and_then(|p| p.name.map(|name| name.first_name))); // None
let person1: Option<Person> = None;
println!("{:?}", person1.and_then(|p| p.name.map(|name| name.first_name))); // None
```

The `?` operator (mentioned in the previous chapter), can also be used to handle `Option`s.
It returns from the function with `None` if a `None` is encountered, or else continues with the
`Some` value:
```rust
fn foo(optional: Option<i32>) -> Option<String> {
    let value = optional?;
    Some(value.to_string())
}
```

## Null-coalescing operator

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

## Null-forgiving operator

The null-forgiving operator (`!`) does not correspond to an equivalent construct
in Rust, as it only affects the compiler's static flow analysis in C#. In Rust,
there is no need to use a substitute for it. [`unwrap`][opt_unwrap] is close,
though: it panics if the value is `None`. [`expect`][opt_expect] is similar but allows
you to provide a custom error message. Note that as previously said, panics should
be reserved to unrecoverable situations.

[option]: https://doc.rust-lang.org/std/option/enum.Option.html
[optmap]: https://doc.rust-lang.org/std/option/enum.Option.html#method.map
[opt_and_then]: https://doc.rust-lang.org/std/option/enum.Option.html#method.and_then
[unwrap-or]: https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap_or
[opt_unwrap]: https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap
[opt_expect]: https://doc.rust-lang.org/std/option/enum.Option.html#method.expect
