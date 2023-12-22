# Strings

There are two string types in Rust: `String` and `&str`. The former is
allocated on the heap and the latter is a slice of a `String` or a `&str`.

The mapping of those to .NET is shown in the following table:

| Rust               | .NET                 | Note        |
| ------------------ | -------------------- | ----------- |
| `&mut str`         | `Span<char>`         |             |
| `&str`             | `ReadOnlySpan<char>` |             |
| `Box<str>`         | `String`             | see Note 1. |
| `String`           | `String`             |             |
| `String` (mutable) | `StringBuilder`      | see Note 1. |

There are differences in working with strings in Rust and .NET, but the
equivalents above should be a good starting point. One of the differences is
that Rust strings are UTF-8 encoded, but .NET strings are UTF-16 encoded.
Further .NET strings are immutable, but Rust strings can be mutable when declared
as such, for example `let s = &mut String::from("hello");`.

There are also differences in using strings due to the concept of ownership. To
read more about ownership with the String Type, see the [Rust Book][ownership-string-type-example].

[ownership-string-type-example]: https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html#the-string-type

Notes:

1. The `Box<str>` type in Rust is equivalent to the `String` type in .NET. The
   difference between the `Box<str>` and `String` types in Rust is that the
   former stores pointer and size while the latter stores pointer, size, and
   capacity, allowing `String` to grow in size. This is similar to the
   `StringBuilder` type in .NET once the Rust `String` is declared mutable.

C#:

```csharp
ReadOnlySpan<char> span = "Hello, World!";
string str = "Hello, World!";
StringBuilder sb = new StringBuilder("Hello, World!");
```

Rust:

```rust
let span: &str = "Hello, World!";
let str = Box::new("Hello World!");
let mut sb = String::from("Hello World!");
```

## String Literals

String literals in .NET are immutable `String` types and allocated on the heap.
In Rust, they are `&'static str`, which is immutable and has a global lifetime
and does not get allocated on the heap; they're embedded in the compiled binary.

C#

```csharp
string str = "Hello, World!";
```

Rust

```rust
let str: &'static str = "Hello, World!";
```

C# verbatim string literals are equivalent to Rust raw string literals.

C#

```csharp
string str = @"Hello, \World/!";
```

Rust

```rust
let str = r#"Hello, \World/!"#;
```

C# UTF-8 string literals are equivalent to Rust byte string literals.

C#

```csharp
ReadOnlySpan<byte> str = "hello"u8;
```

Rust

```rust
let str = b"hello";
```

## String Interpolation

C# has a built-in string interpolation feature that allows you to embed
expressions inside a string literal. The following example shows how to use
string interpolation in C#:

```csharp
string name = "John";
int age = 42;
string str = $"Person {{ Name: {name}, Age: {age} }}";
```

Rust does not have a built-in string interpolation feature. Instead, the
`format!` macro is used to format a string. The following example shows how to
use string interpolation in Rust:

```rust
let name = "John";
let age = 42;
let str = format!("Person {{ name: {name}, age: {age} }}");
```

Custom classes and structs can also be interpolated in C# due to the fact that
the `ToString()` method is available for each type as it inherits from `object`.

```csharp
class Person
{
    public string Name { get; set; }
    public int Age { get; set; }

    public override string ToString() =>
        $"Person {{ Name: {Name}, Age: {Age} }}";
}

var person = new Person { Name = "John", Age = 42 };
Console.Writeline(person);
```

In Rust, there is no default formatting implemented/inherited for each type.
Instead, the `std::fmt::Display` trait must be implemented for each type that
needs to be converted to a string.

```rust
use std::fmt::*;

struct Person {
    name: String,
    age: i32,
}

impl Display for Person {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "Person {{ name: {}, age: {} }}", self.name, self.age)
    }
}

let person = Person {
    name: "John".to_owned(),
    age: 42,
};

println!("{person}");
```

Another option is to use the `std::fmt::Debug` trait. The `Debug` trait is
implemented for all standard types and can be used to print the internal
representation of a type. The following example shows how to use the `derive`
attribute to print the internal representation of a custom struct using the
`Debug` macro. This declaration is used to automatically implement the `Debug`
trait for the `Person` struct:

```rust
#[derive(Debug)]
struct Person {
    name: String,
    age: i32,
}

let person = Person {
    name: "John".to_owned(),
    age: 42,
};

println!("{person:?}");
```

> Note: Using the :? format specifier will use the `Debug` trait to print the
> struct, where leaving it out will use the `Display` trait.

See also:

- [Rust by Example - Debug](https://doc.rust-lang.org/stable/rust-by-example/hello/print/print_debug.html?highlight=derive#debug)
