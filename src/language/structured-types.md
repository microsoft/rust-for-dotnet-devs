# Structured Types

Commonly used object and collection types in .NET and their mapping to Rust

| C#           | Rust      |
| ------------ | --------- |
| `Array`      | `Array`   |
| `List`       | `Vec`     |
| `Tuple`      | `Tuple`   |
| `Dictionary` | `HashMap` |

## Array

Fixed arrays are supported the same way in Rust as in .NET

C#:

```csharp
int[] someArray = new int[2] { 1, 2 };
```

Rust:

```rust
let someArray: [i32; 2] = [1,2];
```

## List

In Rust the equivalent of a `List<T>` is a `Vec<T>`. Arrays can be converted
to Vecs and vice versa.

C#:

```csharp
var something = new List<string>
{
    "a",
    "b"
};

something.Add("c");
```

Rust:

```rust
let mut something = vec![
    "a".to_owned(),
    "b".to_owned()
];

something.push("c".to_owned());
```

## Tuples

C#:

```csharp
var something = (1, 2)
Console.WriteLine($"a = {something.Item1} b = {something.Item2}");
```

Rust:

```rust
let something = (1, 2);
println!("a = {} b = {}", something.0, something.1);

// deconstruction supported
let (a, b) = something;
println!("a = {} b = {}", a, b);
```

> **NOTE**: Rust tuple elements cannot be named like in C#. The only way to
> access a tuple element is by using the index of the element or deconstructing
> the tuple.

## Dictionary

In Rust the equivalent of a `Dictionary<TKey, TValue>` is a `Hashmap<K, V>`.

C#:

```csharp
var something = new Dictionary<string, string>
{
    { "Foo", "Bar" },
    { "Baz", "Qux" }
};

something.Add("hi", "there");
```

Rust:

```rust
let mut something = HashMap::from([
    ("Foo".to_owned(), "Bar".to_owned()),
    ("Baz".to_owned(), "Qux".to_owned())
]);

something.insert("hi".to_owned(), "there".to_owned());
```

See also:

- [Rust's standard library - Collections](https://doc.rust-lang.org/std/collections/index.html)
