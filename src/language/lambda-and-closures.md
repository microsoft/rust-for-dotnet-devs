# Lambda and Closures

C# and Rust allow functions to be used as first-class values that enable
writing _higher-order functions_. Higher-order functions are essentially
functions that accept other functions as arguments to allow for the caller to
participate in the code of the called function. In C#, _type-safe function
pointers_ are represented by delegates with the most common ones being `Func`
and `Action`. The C# language allows ad-hoc instances of these delegates to be
created through _lambda expressions_.

Rust has function pointers too with the `fn` type being the simplest:

```rust
fn do_twice(f: fn(i32) -> i32, arg: i32) -> i32 {
    f(arg) + f(arg)
}

fn main() {
    let answer = do_twice(|x| x + 1, 5);
    println!("The answer is: {}", answer); // Prints: The answer is: 12
}
```

However, Rust makes a distinction between _function pointers_ (where `fn`
defines a type) and _closures_: a closure can reference variables from its
surrounding lexical scope, but not a function pointer. While C# also has
[function pointers][*delegate] (`*delegate`), the managed and type-safe
equivalent would be a static lambda expression.

  [*delegate]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/proposals/csharp-9.0/function-pointers

Functions and methods that accept closures are written with generic types that
are bound to one of the traits representing functions: `Fn`, `FnMut` and
`FnOnce`. When it's time to provide a value for a function pointer or a
closure, a Rust developer uses a _closure expression_ (like `|x| x + 1` in the
example above), which translates to the same as a lambda expression in C#.
Whether the closure expression creates a function pointer or a closure depends
on whether the closure expression references its context or not.

When a closure captures variables from its environment then ownership rules
come into play because the ownership ends up with the closure. For more
information, see the “[Moving Captured Values Out of Closures and the Fn
Traits][closure-move]” section of The Rust Programming Language.

  [closure-move]: https://doc.rust-lang.org/book/ch13-01-closures.html#moving-captured-values-out-of-closures-and-the-fn-traits
