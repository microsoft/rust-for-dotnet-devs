# Namespaces

Namespaces are used in .NET to organize types, as well as for controlling the
scope of types and methods in projects.

In Rust, namespace refers to a different concept. The equivalent of a namespace
in Rust is a [module][rust-module]. For both C# and Rust, visibility of items
can be restricted using access modifiers, respectively visibility modifiers. In
Rust, the default visibility is _private_ (with only few exceptions). The
equivalent of C#'s `public` is `pub` in Rust, and `internal` corresponds to
`pub(crate)`. For more fine-grained access control, refer to the [visibility
modifiers] reference.

[rust-module]: https://doc.rust-lang.org/reference/items/modules.html
[visibility modifiers]: https://doc.rust-lang.org/reference/visibility-and-privacy.html
