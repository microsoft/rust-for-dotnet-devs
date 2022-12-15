# Memory Management

Like C# and .NET, Rust has _memory-safety_ to avoid a whole class of bugs
related to memory access, and which end up being the source of many security
vulnerabilities in software. However, Rust can guarantee memory-safety at
compile-time; there is no run-time (like the CLR) making checks. The one
exception here is array bound checks that are done by the compiled code at
run-time, be that the Rust compiler or the JIT compiler in .NET. Like C#, it
is also [possible to write unsafe code in Rust][unsafe-rust], and in fact,
both languages even share the same keyword, _literally_ `unsafe`, to mark
functions and blocks of code where memory-safety is no longer guaranteed.

  [unsafe-rust]: https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html

Rust has no garbage collector (GC). All memory management is entirely the
responsibility of the developer. That said, _safe Rust_ has rules around
ownership that ensure memory is freed _as soon as_ it's no longer in use (e.g.
when leaving the scope of a block or a function). The compiler does a
tremendous job, through (compile-time) static analysis, of helping manage that
memory through [ownership] rules. If violated, the compiler rejects the code
with a compilation error.

  [ownership]: https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html

In .NET, there is no concept of ownership of memory beyond the GC roots
(static fields, local variables on a thread's stack, CPU registers, handles,
etc.). It is the GC that walks from the roots during a collection to detemine
all memory in use by following references and purging the rest. When designing
types and writing code, a .NET developer can remain oblivious to ownership,
memory management and even how the garbage collector works for the most part,
except when performance-sensitive code requires paying attention to the amount
and rate at which objects are being allocated on the heap. In contrast, Rust's
ownership rules require the developer to explicitly think and express
ownership at all times and it impacts everything from the design of functions,
types, data structures to how the code is written. On top of that, Rust has
strict rules about how data is used such that it can identify at compile-time,
data [race conditions] as well as corruption issues (requiring thread-safety)
that could potentially occur at run-time. This section will only focus on
memory management and ownership.

  [race conditions]: https://doc.rust-lang.org/nomicon/races.html

There can only be one owner of some memory, be that on the stack or heap,
backing a structure at any given time in Rust. The compiler assigns
[lifetimes][lifetimes.rs] and tracks ownership. It is possible to pass or
yield ownership, which is called _moving_ in Rust. These ideas are briefly
illustrated in the example Rust code below:

  [lifetimes.rs]: https://doc.rust-lang.org/rust-by-example/scope/lifetime.html

```rust
#![allow(dead_code, unused_variables)]

struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let a = Point { x: 12, y: 34 }; // point owned by a
    let b = a;                      // b owns the point now
    println!("{}, {}", a.x, a.y);   // compiler error!
}
```

The first statement in `main` will allocate `Point` and that memory will be
owned by `a`. In the second statement, the ownership is moved from `a` to `b`
and `a` can no longer be used because it no longer owns anything or represents
valid memory. The last statement that tries to print the fields of the point
via `a` will fail compilation. Suppose `main` is fixed to read as follows:

```rust
fn main() {
    let a = Point { x: 12, y: 34 }; // point owned by a
    let b = a;                      // b owns the point now
    println!("{}, {}", b.x, b.y);   // ok, uses b
}   // point behind b is dropped
```

Note that when `main` exits, `a` and `b` will go out of scope. The memory
behind `b` will be released by virtue of the stack returning to its state
prior to `main` being called. In Rust, one says that the point behind `b` was
_dropped_. However, note that since `a` yielded its ownership of the point to
`b`, there is nothing to drop when `a` goes out of scope.

A `struct` in Rust can define code to execute when an instance is dropped by
implementing the [`Drop`][drop.rs] trait.

  [drop.rs]: https://doc.rust-lang.org/std/ops/trait.Drop.html

The rough equivalent of _dropping_ in C# would be a class [finalizer], but
while a finalizer is called _automatically_ by the GC at some future point,
dropping in Rust is always instantaneous and deterministic; that is, it
happens at the point the compiler has determined that an instance has no owner
based on scopes and lifetimes. In .NET, the equivalent of `Drop` would be
[`IDisposable`][IDisposable] and is implemented by types to release any
unmanaged resources or memory they hold. _Deterministic disposal_ is not
enforced or guaranteed, but the `using` statement in C# is typically used to
scope an instance of a disposable type such that it gets disposed
determinstically, at the end of the `using` statement's block.

  [finalizer]: https://learn.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/finalizers
  [IDisposable]: https://learn.microsoft.com/en-us/dotnet/api/system.idisposable

Rust has the notion of a global lifetime denoted by `'static`, which is a
reserved lifetime specifier. A very rough approximation in C# would be static
_read-only_ fields of types.

In C# and .NET, references are shared freely without much thought so the idea
of a single owner and yielding/moving ownership may seem very limiting in
Rust, but it is possible to have _shared ownership_ in Rust using the smart
pointer type [`Rc`][rc.rs]; it adds reference-counting. Each time [the smart
pointer is cloned][Rc::clone], the reference count is incremented. When the
clone drops, the reference count is decremented. The actual instance behind
the smart pointer is dropped when the reference count reaches zero. These
points are illustrated by the following examples that build on the previous:

  [rc.rs]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html
  [Rc::clone]: https://doc.rust-lang.org/stable/std/rc/struct.Rc.html#method.clone

```rust
#![allow(dead_code, unused_variables)]

use std::rc::Rc;

struct Point {
    x: i32,
    y: i32,
}

impl Drop for Point {
    fn drop(&mut self) {
        println!("Point dropped!");
    }
}

fn main() {
    let a = Rc::new(Point { x: 12, y: 34 });
    let b = Rc::clone(&a); // share with b
    println!("a = {}, {}", a.x, a.y); // okay to use a
    println!("b = {}, {}", b.x, b.y);
}

// prints:
// a = 12, 34
// b = 12, 34
// Point dropped!
```

Note that:

- `Point` implements the `drop` method of the `Drop` trait and prints a
  message when an instance of a `Point` is dropped.

- The point created in `main` is wrapped behind the smart pointer `Rc` and so
  the smart pointer _owns_ the point and not `a`.

- `b` gets a clone of the smart pointer that effectively increments the
  reference count to 2. Unlike the earlier example, where `a` transferred its
  ownership of point to `b`, both `a` and `b` own their own distinct clones of
  the smart pointer, so it is okay to continue to use `a` and `b`.

- The compiler will have determined that `a` and `b` go out of scope at the
  end of `main` and therefore injected calls to drop each. The `Drop`
  implementation of `Rc` will decrement the reference count and also drop what
  it owns if the reference count has reached zero. When that happens, the
  `Drop` implementation of `Point` will print the message, &ldquo;Point
  dropped!&rdquo; The fact that the message is printed once demonstrates that
  only one point was created, shared and dropped.

`Rc` is not thread-safe. For shared ownership in a multi-threaded program, the
Rust standard library offers [`Arc`][arc.rs] instead. The Rust language will
prevent the use of `Rc` across threads.

  [arc.rs]: https://doc.rust-lang.org/std/sync/struct.Arc.html

In .NET, value types (like `enum` and `struct` in C#) live on the stack and
reference types (`interface`, `record class` and `class` in C#) are
heap-allocated. In Rust, the kind of type (basically `enum` or `struct` _in
Rust_), does not determine where the backing memory will eventually live. By
default, it is always on the stack, but just the way .NET and C# have a notion
of boxing value types, which copies them to the heap, the way to allocate a
type on the heap is to box it using [`Box`][box.rs]:

  [box.rs]: https://doc.rust-lang.org/std/boxed/struct.Box.html

```rust
let stack_point = Point { x: 12, y: 34 };
let heap_point = Box::new(Point { x: 12, y: 34 });
```

Like `Rc` and `Arc`, `Box` is a smart pointer, but unlike `Rc` and `Arc`, it
exclusively owns the instance behind it. All of these smart pointers allocate
an instance of their type argument `T` on the heap.

The `new` keyword in C# creates an instance of a type, and while members such
as `Box::new` and `Rc::new` that you see in the examples may seem to have a
similar purpose, `new` has no special designation in Rust. It's merely a
_coventional name_ that is meant to denote a factory. In fact they are called
_associated functions_ of the type, which is Rust's way of saying static
methods.
