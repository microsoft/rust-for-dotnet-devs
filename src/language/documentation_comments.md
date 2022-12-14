# Documentation Comments

C# provides a mechanism to document the API for types using a comment syntax
that contains XML text. The C# compiler produces an XML file that contains
structured data representing the comments and the API signatures. Other tools
can process that output to provide human-readable documentation in a different
form. A simple example in C#:

```csharp
/// <summary>
/// This is a document comment for <c>MyClass</c>.
/// </summary>
public class MyClass {}
```

In Rust [doc comments] provide the equivalent to C# documentation comments.
Documentation comments in Rust use Markdown syntax. [`rustdoc`][rustdoc] is the
documentation compiler for Rust code and is usually invoked through [`cargo
doc`][cargo doc], which compiles the comments into documentation. For example:

```rust
/// This is a doc comment for `MyStruct`.
struct MyStruct;
```

In the .NET SDK there is no equivalent to `cargo doc`, such as `dotnet doc`.

See also:

- [How to write documentation]
- [Documentation tests]

[doc comments]: https://doc.rust-lang.org/rust-by-example/meta/doc.html
[rustdoc]: https://doc.rust-lang.org/rustdoc/index.html
[cargo doc]: https://doc.rust-lang.org/cargo/commands/cargo-doc.html
[How to write documentation]: https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html
[documentation tests]: https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html
