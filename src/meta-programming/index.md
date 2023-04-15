# Meta Programming

Metaprogramming can be seen as a way of writing code that writes/generates other
code.

Roslyn is providing a feature for metaprogramming in C#, available since .NET 5,
and called [`Source Generators`][source-gen]. Source generators can create new
C# source files at build-time that are added to the user's compilation. Before
`Source Generators` were introduced, Visual Studio has been providing a code
generation tool via [`T4 Text Templates`][T4]. An example on how T4 works is the
following [template] or its [concretization].

Rust is also providing a feature for metaprogramming: [macros]. There are
`declarative macros` and `procedural macros`.

Declarative macros allow you to write control structures that take an
expression, compare the resulting value of the expression to patterns, and then
run the code associated with the matching pattern.

The following example is the definition of the `println!` macro that it is
possible to call for printing some text `println!("Some text")`

```rust
macro_rules! println {
    () => {
        $crate::print!("\n")
    };
    ($($arg:tt)*) => {{
        $crate::io::_print($crate::format_args_nl!($($arg)*));
    }};
}
```

To learn more about writing declarative macros, refer to the Rust reference
chapter [macros by example] or [The Little Book of Rust Macros].

[Procedural macros] are different than declarative macros. Those accept some code
as an input, operate on that code, and produce some code as an output.

Another technique used in C# for metaprogramming is reflection. Rust does not
support reflection.

[source-gen]: https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/source-generators-overview

## Function-like macros

Function-like macros are in the following form: `function!(...)`

The following code snippet defines a function-like macro named
`print_something`, which is generating a `print_it` method for printing the
"Something" string.

In the lib.rs:

```rust
extern crate proc_macro;
use proc_macro::TokenStream;

#[proc_macro]
pub fn print_something(_item: TokenStream) -> TokenStream {
    "fn print_it() { println!(\"Something\") }".parse().unwrap()
}
```

In the main.rs:

```rust
use replace_crate_name_here::print_something;
print_something!();

fn main() {
    print_it();
}
```

## Derive macros

Derive macros can create new items given the token stream of a struct, enum, or
union. An example of a derive macro is the `#[derive(Clone)]` one, which is
generating the needed code for making the input struct/enum/union implement the
`Clone` trait.

In order to understand how to define a custom derive macro, it is possible to
read the rust reference for [derive macros]

[derive macros]: https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros

## Attribute macros

Attribute macros define new attributes which can be attached to rust items.
While working with asynchronous code, if making use of Tokio, the first step
will be to decorate the new asynchronous main with an attribute macro like the
following example:

```rust
#[tokio::main]
async fn main() {
    println!("Hello world");
}
```

In order to understand how to define a custom derive macro, it is possible to
read the rust reference for [attribute macros]

[attribute macros]: https://doc.rust-lang.org/reference/procedural-macros.html#attribute-macros

[T4]: https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2015/modeling/code-generation-and-t4-text-templates?view=vs-2015&redirectedfrom=MSDN
[template]: https://github.com/atifaziz/Jacob/blob/master/src/JsonReader.g.tt
[concretization]: https://github.com/atifaziz/Jacob/blob/master/src/JsonReader.g.cs
[macros]: https://doc.rust-lang.org/book/ch19-06-macros.html
[macros by example]: https://doc.rust-lang.org/reference/macros-by-example.html
[procedural macros]: https://doc.rust-lang.org/reference/procedural-macros.html
[The Little Book of Rust Macros]: https://veykril.github.io/tlborm/
