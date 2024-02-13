# Scalar Types

The following table lists the primitive types in Rust and their equivalent in
C# and .NET:

| Rust    | C#        | .NET                   | Note             |
| ------- | --------- | ---------------------- | ---------------- |
| `bool`  | `bool`    | `Boolean`              |                  |
| `char`  | `char`    | `Char`                 | See note 1.      |
| `i8`    | `sbyte`   | `SByte`                |                  |
| `i16`   | `short`   | `Int16`                |                  |
| `i32`   | `int`     | `Int32`                |                  |
| `i64`   | `long`    | `Int64`                |                  |
| `i128`  |           | `Int128`               |                  |
| `isize` | `nint`    | `IntPtr`               |                  |
| `u8`    | `byte`    | `Byte`                 |                  |
| `u16`   | `ushort`  | `UInt16`               |                  |
| `u32`   | `uint`    | `UInt32`               |                  |
| `u64`   | `ulong`   | `UInt64`               |                  |
| `u128`  |           | `UInt128`              |                  |
| `usize` | `nuint`   | `UIntPtr`              |                  |
| `f32`   | `float`   | `Single`               |                  |
| `f64`   | `double`  | `Double`               |                  |
|         | `decimal` | `Decimal`              |                  |
| `()`    | `void`    | `Void` or `ValueTuple` | See notes 2 & 3. |
|         | `object`  | `Object`               | See note 3.      |

Notes:

1. [`char`][char.rs] in Rust and [`Char`][char.net] in .NET have different
   definitions. In Rust, a `char` is 4 bytes wide that is a [Unicode scalar
   value], but in .NET, a `Char` is 2 bytes wide and stores the character
   using the UTF-16 encoding. For more information, see the [Rust `char`
   documentation][char.rs].

2. While a unit `()` (an empty tuple) in Rust is an _expressible value_, the
   closest cousin in C# would be `void` to represent nothing. However, `void`
   isn't an _expressible value_ except when using pointers and unsafe code.
   .NET has [`ValueTuple`][ValueTuple] that is an empty tuple, but C# does not
   have a literal syntax like `()` to represent it. `ValueTuple` can be used
   in C#, but it's very uncommon. Unlike C#, [F# does have a unit
   type][unit.fs] like Rust.

3. While `void` and `object` are not scalar types (even though scalars like `int`
   are sub-classes of `object` in the .NET type hierarchy), they have been
   included in the above table for convenience.

See also:

- [Primitives (Rust By Example)][primitives.rs]

[char.net]: https://learn.microsoft.com/en-us/dotnet/api/system.char
[char.rs]: https://doc.rust-lang.org/std/primitive.char.html
[Unicode scalar value]: https://www.unicode.org/glossary/#unicode_scalar_value
[ValueTuple]: https://learn.microsoft.com/en-us/dotnet/api/system.valuetuple?view=net-7.0
[unit.fs]: https://learn.microsoft.com/en-us/dotnet/fsharp/language-reference/unit-type
[primitives.rs]: https://doc.rust-lang.org/rust-by-example/primitives.html
