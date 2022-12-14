## Getting Started

GitHub starter repo with:
- dev container
- Dockerfile
- rust toolchain file

## Memory Management

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

## Resource Management

Previous section on [memory management] explains the differences between .NET
and Rust when it comes to GC, ownership and finalizers. It is highly recommended
to read it.

This section is limited to providing an example of a fictional
_database connection_ involving a SQL connection to be properly
closed/disposed/dropped

```csharp
{
    using var db1 = new DatabaseConnection("Server=A;Database=DB1");
    using var db2 = new DatabaseConnection("Server=A;Database=DB2");

    // ...code using "db1" and "db2"...
}   // "Dispose" of "db1" and "db2" called here; when their scope ends

public class DatabaseConnection : IDisposable
{
    readonly string connectionString;
    SqlConnection connection; //this implements IDisposable

    public DatabaseConnection(string connectionString) =>
        this.connectionString = connectionString;

    public void Dispose()
    {
        //Making sure to dispose the SqlConnection
        this.connection.Dispose();
        Console.WriteLine("Closing connection: {this.connectionString}");
    }
}
```

```rust
struct DatabaseConnection(&'static str);

impl DatabaseConnection {
    // ...functions for using the database connection...
}

impl Drop for DatabaseConnection {
    fn drop(&mut self) {
        // ...closing connection...
        self.close_connection();
        // ...printing a message...
        println!("Closing connection: {}", self.0)
    }
}

fn main() {
    let _db1 = DatabaseConnection("Server=A;Database=DB1");
    let _db2 = DatabaseConnection("Server=A;Database=DB2");
    // ...code for making use of the database connection...
} // "Dispose" of "db1" and "db2" called here; when their scope ends
```

[memory management]: #memory-management

## Threading

The Rust standard library supports threading, synchronisation and concurrency.
Also the language itself and the standard library do have basic support for the
concepts, a lot of additional functionality is provided by crates and will not
be covered in this document.

The following lists approximate mapping of threading types and methods in .NET
to Rust:

| .NET               | Rust                      |
| ------------------ | ------------------------- |
| `Thread`           | `std::thread::thread`     |
| `Thread.Start`     | `std::thread::spawn`      |
| `Thread.Join`      | `std::thread::JoinHandle` |
| `Thread.Sleep`     | `std::thread::sleep`      |
| `ThreadPool`       | -                         |
| `Mutex`            | `std::sync::Mutex`        |
| `Semaphore`        | -                         |
| `Monitor`          | `std::sync::Mutex`        |
| `ReaderWriterLock` | `std::sync::RwLock`       |
| `AutoResetEvent`   | `std::sync::Condvar`      |
| `ManualResetEvent` | `std::sync::Condvar`      |
| `Barrier`          | `std::sync::Barrier`      |
| `CountdownEvent`   | `std::sync::Barrier`      |
| `Interlocked`      | `std::sync::atomic`       |
| `Volatile`         | `std::sync::atomic`       |
| `ThreadLocal`      | `std::thread_local`       |

Launching a thread and waiting for it to finish works the same way in C#/.NET
and Rust. Below is a simple C# program that creates a thread (where the thread
prints some text to standard output) and then waits for it to end:

```csharp
using System;
using System.Threading;

var thread = new Thread(() => Console.WriteLine("Hello from a thread!"));
thread.Start();
thread.Join(); // wait for thread to finish
```

The same code in Rust would be as follows:

```rust
use std::thread;

fn main() {
    let thread = thread::spawn(|| println!("Hello from a thread!"));
    thread.join().unwrap(); // wait for thread to finish
}
```

Creating and initializing a thread object and starting a thread are two
different actions in .NET whereas in Rust both happen at the same time with
`thread::spawn`.

In .NET, it's possible to send data as an argument to a thread:

```csharp
#nullable enable

using System;
using System.Text;
using System.Threading;

var t = new Thread(obj =>
{
    var data = (StringBuilder)obj!;
    data.Append(" World!");
});

var data = new StringBuilder("Hello");
t.Start(data);
t.Join();

Console.WriteLine($"Phrase: {data}");
```

However, a more modern or terser version would use closures:

```csharp
using System;
using System.Text;
using System.Threading;

var data = new StringBuilder("Hello");

var t = new Thread(obj => data.Append(" World!"));

t.Start();
t.Join();

Console.WriteLine($"Phrase: {data}");
```

In Rust, there is no variation of `thread::spawn` that does the same. Instead,
the data is passed to the thread via a closure:

```rust
use std::thread;

fn main() {
    let data = String::from("Hello");
    let handle = thread::spawn(move || {
        let mut data = data;
        data.push_str(" World!");
        data
    });
    println!("Phrase: {}", handle.join().unwrap());
}
```

A few things to note:

- The `move` keyword is _required_ to _move_ or pass the ownership of `data`
  to the closure for the thread. Once this is done, it's no longer legal to
  continue to use the `data` variable of `main`, in `main`. If that is needed,
  `data` must be copied or cloned (depending on what the type of the value
  supports).

- Rust thread can return values, like tasks in C#, which becomes the return
  value of the `join` method.

- It is possible to also pass data to the C# thread via a clousre, like the
  Rust example, but the C# version does not need to worry about ownership
  since the memory behind the data will be reclaimed by the GC once no one is
  referencing it anymore.

### Synchronization

When data is shared between threads, one needs to synchronize read-write
access to the data in order to avoid corruption. The C# offers the `lock`
keyword as a synchronization primitive (which desugars to exception-safe use
of `Monitor` from .NET):

```csharp
using System;
using System.Threading;

var dataLock = new object();
var data = 0;
var threads = new List<Thread>();

for (var i = 0; i < 10; i++)
{
    var thread = new Thread(() =>
    {
        for (var j = 0; j < 1000; j++)
        {
            lock (dataLock)
                data++;
        }
    });
    threads.Add(thread);
    thread.Start();
}

foreach (var thread in threads)
    thread.Join();

Console.WriteLine(data);
```

In Rust, one must make explicit use of concurrency structures like `Mutex`:

```rust
use std::thread;
use std::sync::{Arc, Mutex};

fn main() {
    let data = Arc::new(Mutex::new(0)); // (1)

    let mut threads = vec![];
    for _ in 0..10 {
        let data = Arc::clone(&data); // (2)
        let thread = thread::spawn(move || { // (3)
            for _ in 0..1000 {
                let mut data = data.lock().unwrap();
                *data += 1; // (4)
            }
        });
        threads.push(thread);
    }

    for thread in threads {
        thread.join().unwrap();
    }

    println!("{}", data.lock().unwrap());
}
```

A few things to note:

- Since the ownership of the `Mutex` instance and in turn the data it guards
  will be shared by multiple threads, it is wrapped in an `Arc` (1). `Arc`
  provides atomic reference counting, which increments each time it is cloned
  (2) and decrements each time it is dropped. When the count reaches zero, the
  mutex and in turn the data it guards are dropped. This is discussed in more
  detail in [Memory Management]).

- The closure instance for each thread receives ownership (3) of the _cloned
  reference_ (2).

- The pointer-like code that is `*data += 1` (4), is not some unsafe pointer
  access even if it looks like it. It's updating the data _wrapped_ in the
  [mutex guard].

Unlike the C# version, where one can render it thread-unsafe by commenting out
the `lock` statement, the Rust version will refuse to compile if it's changed
in any way (e.g. by commenting out parts) that renders it thread-unsafe. This
demonstrates that writing thread-safe code is the developer's responsibility
in C# and .NET by careful use of synchronized structures whereas in Rust, one
can rely on the compiler.

The compiler is able to help because data structures in Rust are marked by
special _traits_ (see [Interfaces](#interfaces)): `Sync` and `Send`.
[`Sync`][sync.rs] indicates that references to a type's instances are safe to
share between threads. [`Send`][send.rs] indicates it's safe to instances of a
type across thread boundaries. For more information, see the “[Fearless
Concurrency]” chapter of the Rust book.

  [Extensible Concurrency]: https://doc.rust-lang.org/book/ch16-04-extensible-concurrency-sync-and-send.html
  [Fearless Concurrency]: https://doc.rust-lang.org/book/ch16-00-concurrency.html
  [mutex guard]: https://doc.rust-lang.org/stable/std/sync/struct.MutexGuard.html
  [sync.rs]: https://doc.rust-lang.org/stable/std/marker/trait.Sync.html
  [send.rs]: https://doc.rust-lang.org/stable/std/marker/trait.Send.html

### Producer-Consumer

The producer-consumer pattern is very common to distribute work between
threads where data is passed from producing threads to consuming threads
without the need for sharing or locking. .NET has very rich support for this,
but at the most basic level, `System.Collections.Concurrent` provides the `BlockingCollection` as shown in the next example in C#:

```csharp
using System;
using System.Threading;
using System.Collections.Concurrent;

var messages = new BlockingCollection<string>();
var producer = new Thread(() =>
{
    for (var n = 1; i < 10; i++)
        messages.Add($"Message #{n}");
    messages.CompleteAdding();
});

producer.Start();

// main thread is the consumer here
foreach (var message in messages.GetConsumingEnumerable())
    Console.WriteLine(message);

producer.Join();
```

The same can be done in Rust using _channels_. The standard library primarily
provides `mpsc::channel`, which is a channel that supports multiple producers
and a single consumer. A rough translation of the above C# example in Rust
would look as follows:

```rust
use std::thread;
use std::sync::mpsc;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();

    let procuder = thread::spawn(move || {
        for n in 1..10 {
            tx.send(format!("Message #{}", n)).unwrap();
        }
    });

    // main thread is the consumer here
    for received in rx {
        println!("{}", received);
    }

    procuder.join().unwrap();
}
```

Like channels in Rust, .NET also offers channels in the
`System.Threading.Channels` namespace, but it is primarily designed to be used
with tasks and asynchronous programming using `async` and `await`. The
equivalent of the [async-friendly channels in the Rust space is offered by the
Tokio runtime][tokio-channels].

  [tokio-channels]: https://tokio.rs/tokio/tutorial/channels

## Testing

### Test organization

.NET solutions use separate projects to host test code, irrespective of the
test framework being used (xUnit, NUnit, MSTest, etc.) and the type of tests
(unit or integration) being wirtten. The test code therefore lives in a
separate assembly than the application or library code being tested. In Rust,
it is a lot more conventional for _unit tests_ to be found in a separate test
sub-module (conventionally) named `tests`, but which is placed in same _source
file_ as the application or library module code that is the subject of the
tests. This has two benefits:

- The code/module and its unit tests live side-by-side.

- There is no need for a workaround like `[InternalsVisibleTo]` that exists in
  .NET because the tests have access to internals by virtual of being a
  sub-module.

The test sub-module is annotated with the `#[cfg(test)]` attribute, which has
the effect that the entire module is (conditionally) compiled and run only
when the `cargo test` command is issued.

Within the test sub-modules, test functions are annotated with the `#[test]`
attribute.

Integration tests are usually in a directory called `tests` that sits adjacent
to the `src` directory with the unit tests and source. `cargo test` compiles
each file in that directory as a separate crate and run all the methods
annotated with `#[test]` attribute. Since it is understood that integration
tests in the `tests` directory, there is no need to mark the modules in there
with the `#[cfg(test)]` attribute.

See also:

- [Test Organization][test-org]

  [test-org]: https://doc.rust-lang.org/book/ch11-03-test-organization.html

### Running tests

As simple as it can be, the equivalent of `dotnet test` in Rust is `cargo test`.

The default behavior of `cargo test` is to run all the tests in parallel, but this can be configured to run consecutively using only a single thread:

    cargo test -- --test-threads=1

For more information, see "[Running Tests in Parallel or
Consecutively][tests-exec]".

  [tests-exec]: https://doc.rust-lang.org/book/ch11-02-running-tests.html#running-tests-in-parallel-or-consecutively

### Output in tests

For very complex integration or end-to-end test, .NET developers sometimes log
what's happening during a test. The actual way they do this varies with each
test framework. For example, in NUnit, this is as simple as using
`Console.WriteLine`, but in XUnit, one uses `ITestOutputHelper`. In Rust, it's
similar to NUnit; that is, one simply writes to the standard output using
`println!`. The output captured during the running of the tests is not shown
by default unless `cargo test` is run the with `--show-output` option:

    cargo test --show-output

For more information, see "[Showing Function Output][test-output]".

  [test-output]: https://doc.rust-lang.org/book/ch11-02-running-tests.html#showing-function-output

### Assertions

.NET users have multiple ways to assert, depending on the framework being
used. For example, an assertion xUnit.net might look like:

```csharp
[Fact]
public void Something_Is_The_Right_Length()
{
    var value = "something";
    Assert.Equal(9, value.Length);
}
```

Rust does not require a separate framework or crate. The standard library
comes with built-in _macros_ that are good enough for most assertions in
tests:

- [`assert!`][assert]
- [`assert_eq!`][assert_eq]
- [`assert_ne!`][assert_ne]

Below is an example of `assert_eq` in action:

```rust
#[test]
fn something_is_the_right_length() {
    let value = "something";
    assert_eq!(9, value.len());
}
```

The standard library does not offer anything in the direction of data-driven
tests, such as `[Theory]` in xUnit.net.

  [assert]: https://doc.rust-lang.org/std/macro.assert.html
  [assert_eq]: https://doc.rust-lang.org/std/macro.assert_eq.html
  [assert_ne]: https://doc.rust-lang.org/std/macro.assert_ne.html

### Mocking

When writing tests for a .NET application or library, there exist several
frameworks, like Moq and NSubstitute, to mock out the dependencies of types.
There are similar crates for Rust too, like [`mockall`][mockall], that can
help with mocking. However, it is also possible to use [conditional
compilation] by making use of the [`cfg` attribute][cfg-attribute] as a simple
means to mocking without needing to rely on external crates or frameworks. The
`cfg` attribute conditionally includes the code it annotates based on a
configuration symbol, such as `test` for testing. This is not very different
to using `DEBUG` to conditionally compile code specifically for debug builds.
One downside of this approach is that you can only have one implementation for
all tests of the module.

When specified, the `#[cfg(test)]` attribute tells Rust to compile and run the
code only when executing the `cargo test` command, which behind-the-scenes
executes the compiler with `rustc --test`. The opposite is true for the
`#[cfg(not(test))]` attribute; it includes the annotated only when testing
with `cargo test`.

The example below shows mocking of a stand-alone function `var_os` from the
standard that reads and returns the value of an environment variable. It
conditionally imports a mocked version of the `var_os` function used by
`get_env`. When built with `cargo build` or run with `cargo run`, the compiled
binary will make use of `std::env::var_os`, but `cargo test` will instead
import `tests::var_os_mock` as `var_os`, thus causing `get_env` to use the
mocked version during testing:

```rust
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

/// Utility function to read an environmentvariable and return its value If
/// defined. It fails/panics if the valus is not valid Unicode.
pub fn get_env(key: &str) -> Option<String> {
    #[cfg(not(test))]                 // for regular builds...
    use std::env::var_os;             // ...import from the standard library
    #[cfg(test)]                      // for test builds...
    use tests::var_os_mock as var_os; // ...import mock from test sub-module

    let val = var_os(key);
    val.map(|s| s.to_str()     // get string slice
                 .unwrap()     // panic if not valid Unicode
                 .to_owned())  // convert to "String"
}

#[cfg(test)]
mod tests {
    use std::ffi::*;
    use super::*;

    pub(crate) fn var_os_mock(key: &str) -> Option<OsString> {
        match key {
            "FOO" => Some("BAR".into()),
            _ => None
        }
    }

    #[test]
    fn get_env_when_var_undefined_returns_none() {
        assert_eq!(None, get_env("???"));
    }

    #[test]
    fn get_env_when_var_defined_returns_some_value() {
        assert_eq!(Some("BAR".to_owned()), get_env("FOO"));
    }
}
```

  [mockall]: https://docs.rs/mockall/latest/mockall/
  [conditional compilation]: #conditional-compilation
  [cfg-attribute]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-attribute

### Code coverage

There is sophisticated tooling for .NET when it comes to analyzing test code
coverage. In Visual Studio, the tooling is built-in and integrated. In Visual
Studio Code, plug-ins exist. .NET developers might be familiar with [coverlet]
as well.

Rust is providing [built-in code coverage implementations][built-in-cov] for
collecting test code coverage.

There are also plug-ins available for Rust to help with code coverage analysis.
It's not seamlessly integrated, but with some manual steps, developers can
analyze their code in a visual way.

The combination of [Coverage Gutters][coverage.gutters] plug-in for Visual
Studio Code and [Tarpaulin] allows visual analysis of the code coverage in
Visual Studio Code. Coverage Gutters requires an LCOV file. Other tools besides
[Tarpaulin] can be used to generate that file.

Once setup, run the following command:

```bash
cargo tarpaulin --ignore-tests --out Lcov
```

This generates an LCOV Code Coverage file. Once `Coverage Gutters: Watch` is
enabled, it will be picked up by the Coverage Gutters plug-in, which will show
in-line visual indicators about the line coverage in the source code editor.

> Note: The location of the LCOV file is essential. If a workspace (see [Project
> Structure](#project-structure)) with multiple packages is present and a LCOV
> file is generated in the root using `--workspace`, that is the file that is
> being used - even if there is a file present directly in the root of the
> package. It is quicker to isolate to the particular package under test
> rather than generating the LCOV file in the root.

[coverage.gutters]: https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters
[tarpaulin]: https://github.com/xd009642/tarpaulin
[coverlet]: https://github.com/coverlet-coverage/coverlet
[built-in-cov]: https://doc.rust-lang.org/stable/rustc/instrument-coverage.html#test-coverage

## Benchmarking

Running benchmarks in Rust is done via [`cargo bench`][cargo-bench], a specific
command for `cargo` which is executing all the methods annotated with the
`#[bench]` attribute. This attribute is currently [unstable][bench-unstable] and
available only for the nightly channel.

.NET users can make use of `BenchmarkDotNet` library to benchmark methods and
track their performance. The equivalent of `BenchmarkDotNet` is a crate named
`Criterion`.

As per its [documentation][criterion-docs], `Criterion` collects and stores
statistical information from run to run and can automatically detect performance
regressions as well as measuring optimizations.

Using `Criterion` is possible to use the `#[bench]` attribute without moving to
the nightly channel.

As in `BenchmarkDotNet`, it is also possible to integrate benchmark results with
the [GitHub Action for Continuous Benchmarking][gh-action-bench]. `Criterion`,
in fact, supports multiple output formats, amongst which there is also the
`bencher` format, mimicking the nightly `libtest` benchmarks and compatible with
the above mentioned action.

[cargo-bench]: https://doc.rust-lang.org/cargo/commands/cargo-bench.html
[bench-unstable]: https://doc.rust-lang.org/rustc/tests/index.html#test-attributes
[criterion-docs]: https://bheisler.github.io/criterion.rs/book/index.html
[gh-action-bench]: https://github.com/benchmark-action/github-action-benchmark

## Logging and Tracing

.NET supports a number of logging APIs. For most cases, `ILogger` is a good
default choice, since it works with a variety of built-in and third-party
logging providers. In C#, a minimal example for structured logging could look
like:

```csharp
using Microsoft.Extensions.Logging;

using var loggerFactory = LoggerFactory.Create(builder => builder.AddConsole());
var logger = loggerFactory.CreateLogger<Program>();
logger.LogInformation("Hello {Day}.", "Thursday"); // Hello Thursday.
```

In Rust, a lightweight logging facade is provided by [log][log.rs]. It has less
features than `ILogger`, e.g. as it does not yet offer (stable) structured
logging or logging scopes.

For something with more feature parity to .NET, Tokio offers
[`tracing`][tracing.rs]. `tracing` is a framework for instrumenting Rust
applications to collect structured, event-based diagnostic information.
[`tracing_subscriber`][tracing-subscriber.rs] can be used to implement and
compose `tracing` subscribers. The same structured logging example from above
with `tracing` and `tracing_subscriber` looks like:

```rust
fn main() {
    // install global default ("console") collector.
    tracing_subscriber::fmt().init();
    tracing::info!("Hello {Day}.", Day = "Thursday"); // Hello Thursday.
}
```

[OpenTelemetry][opentelemetry.rs] offers a collection of tools, APIs, and SDKs
used to instrument, generate, collect, and export telemetry data based on the
OpenTelemetry specification. At the time of writing, the [OpenTelemetry Logging
API][opentelemetry-logging] is not yet stable and the Rust implementation [does
not yet support logging][opentelemetry-status.rs], but the tracing API is
supported.

[opentelemetry.rs]: https://crates.io/crates/opentelemetry
[tracing-subscriber.rs]: https://docs.rs/tracing-subscriber/latest/tracing_subscriber/
[opentelemetry-logging]: https://opentelemetry.io/docs/reference/specification/status/#logging
[opentelemetry-status.rs]: https://opentelemetry.io/docs/instrumentation/rust/#status-and-releases
[tracing.rs]: https://crates.io/crates/tracing
[log.rs]: https://crates.io/crates/log

## Conditional Compilation

Both .NET and Rust are providing the possibility for compiling specific code
based on external conditions.

In .NET it is possible to use the some [preprocessor directives][preproc-dir] in
order to control conditional compilation

```csharp
#if debug
    Console.WriteLine("Debug");
#else
    Console.WriteLine("Not debug");
#endif
```

In addition to predefined symbols, it is also possible to use the compiler
option _[DefineConstants]_ to define symbols that can be used with `#if`,
`#else`, `#elif` and `#endif` to compile source files conditionally.

In Rust it is possible to use the [`cfg attribute`][cfg],
the [`cfg_attr attribute`][cfg-attr] or the
[`cfg macro`][cfg-macro] to control conditional compilation

As per .NET, in addition to predefined symbols, it is also possible to use the
[compiler flag `--cfg`][cfg-flag] to arbitrarily set configuration options

The [`cfg attribute`][cfg] is requiring and evaluating a
`ConfigurationPredicate`

```rust
use std::fmt::{Display, Formatter};

struct MyStruct;

// This implementation of Display is only included when the OS is unix but foo is not equal to bar
// You can compile an executable for this version, on linux, with 'rustc main.rs --cfg foo=\"baz\"'
#[cfg(all(unix, not(foo = "bar")))]
impl Display for MyStruct {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str("Running without foo=bar configuration")
    }
}

// This function is only included when both unix and foo=bar are defined
// You can compile an executable for this version, on linux, with 'rustc main.rs --cfg foo=\"bar\"'
#[cfg(all(unix, foo = "bar"))]
impl Display for MyStruct {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        f.write_str("Running with foo=bar configuration")
    }
}

// This function is panicking when not compiled for unix
// You can compile an executable for this version, on windows, with 'rustc main.rs'
#[cfg(not(unix))]
impl Display for MyStruct {
    fn fmt(&self, _f: &mut Formatter<'_>) -> std::fmt::Result {
        panic!()
    }
}

fn main() {
    println!("{}", MyStruct);
}
```

The [`cfg_attr attribute`][cfg-attr] conditionally includes attributes based on
a configuration predicate.

```rust
#[cfg_attr(feature = "serialization_support", derive(Serialize, Deserialize))]
pub struct MaybeSerializableStruct;

// When the `serialization_support` feature flag is enabled, the above will expand to:
// #[derive(Serialize, Deserialize)]
// pub struct MaybeSerializableStruct;
```

The built-in [`cfg macro`][cfg-macro] takes in a single configuration predicate
and evaluates to the true literal when the predicate is true and the false
literal when it is false.

```rust
if cfg!(unix) {
  println!("I'm running on a unix machine!");
}
```

See also:

- [Conditional compilation][conditional-compilation]

### Features

Conditional compilation is also helpful when there is a need for providing
optional dependencies. With cargo "features", a package defines a set of named
features in the `[features]` table of Cargo.toml, and each feature can either be
enabled or disabled. Features for the package being built can be enabled on the
command-line with flags such as `--features`. Features for dependencies can be
enabled in the dependency declaration in Cargo.toml.

See also:

- [Features][features]

[features]: https://doc.rust-lang.org/cargo/reference/features.html
[conditional-compilation]: https://doc.rust-lang.org/reference/conditional-compilation.html#conditional-compilation
[cfg]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-attribute
[cfg-flag]: https://doc.rust-lang.org/rustc/command-line-arguments.html#--cfg-configure-the-compilation-environment
[cfg-attr]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg_attr-attribute
[cfg-macro]: https://doc.rust-lang.org/reference/conditional-compilation.html#the-cfg-macro
[preproc-dir]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/preprocessor-directives#conditional-compilation
[DefineConstants]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/language#defineconstants

## Environment and Configuration

### Accessing environment variables

.NET provides access to environment variables via the
`System.Environment.GetEnvironmentVariable` method. This method retrieves the
value of an environment variable at runtime.

```csharp
using System;

const string name = "EXAMPLE_VARIABLE";

var value = Environment.GetEnvironmentVariable(name);
if (string.IsNullOrEmpty(value))
    Console.WriteLine($"Variable '{name}' not set.");
else
    Console.WriteLine($"Variable '{name}' set to '{value}'.");
```

Rust is providing the same functionality of accessing an environment variable at
runtime via the `var` and `var_os` functions from the `std::env` module.

`var` function is returning a `Result<String, VarError>`, either returning the
variable if set or returning an error if the variable is not set or it is not
valid Unicode

`var_os` has a different signature giving back an `Option<OsString>`, either
returning some value if the variable is set, or returning None if the variable
is not set or it is containing not valid UTF-8

```rust
use std::env;


fn main() {
    let key = "ExampleVariable";
    match env::var(key) {
        Ok(val) => println!("{key}: {val:?}"),
        Err(e) => println!("couldn't interpret {key}: {e}"),
    }
}
```

```rust
use std::env;

fn main() {
    let key = "ExampleVariable";
    match env::var_os(key) {
        Some(val) => println!("{key}: {val:?}"),
        None => println!("{key} not defined in the enviroment"),
    }
}
```

Rust is also providing the functionality of accessing an environment variable at
compile time. The `env!` macro from `std::env` expands the value of the variable
at compile time, returning a `&'static str`. If the variable is not set, an
error is emitted.

```rust
use std::env;

fn main() {
    let example = env!("ExampleVariable");
    println!("{example}");
}
```

In .NET a compile time access to environment variables can be achieved, in a
less straightforward way, via [source generators][source-gen].

[source-gen]: https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/source-generators-overview

### Configuration

Configuration in .NET is possible with configuration providers. The framework is
providing several provider implementations via
`Microsoft.Extensions.Configuration` namespace and NuGet packages.

Configuration providers read configuration data from key-value pairs using
different sources and provide a unified view of the configuration via the
`IConfiguration` type.

```csharp
using Microsoft.Extensions.Configuration;

class Example {
    static void Main()
    {
        IConfiguration configuration = new ConfigurationBuilder()
            .AddEnvironmentVariables()
            .Build();

        var example = configuration.GetValue<string>("ExampleVar");

        Console.WriteLine(example);
    }
}
```

Other providers examples can be found in the official documentation
[Configurations provider in .NET][conf-net].

A similar configuration experience in Rust is available via use of third-party
crates such as [figment] or [config].

See the following example making use of [config] crate:

```rust
use config::{Config, Environment};

fn main() {
    let builder = Config::builder().add_source(Environment::default());

    match builder.build() {
        Ok(config) => {
            match config.get_string("examplevar") {
                Ok(v) => println!("{v}"),
                Err(e) => println!("{e}")
            }
        },
        Err(_) => {
            // something went wrong
        }
    }
}

```

[conf-net]: https://learn.microsoft.com/en-us/dotnet/core/extensions/configuration-providers
[figment]: https://crates.io/crates/figment
[config]: https://crates.io/crates/config

## LINQ

This section discusses LINQ within the context and for the purpose of querying
or transforming sequences (`IEnumerable`/`IEnumerable<T>`) and typically
collections like lists, sets and dictionaries.

### `IEnumerable<T>`

The equivalent of `IEnumerable<T>` in Rust is [`IntoIterator`][into-iter.rs].
Just as an implementation of `IEnumerable<T>.GetEnumerator()` returns a
`IEnumerator<T>` in .NET, an implementation of `IntoIterator::into_iter`
returns an [`Iterator`][iter.rs]. However, when it's time to iterate over the
items of a container advertising iteration support through the said types,
both languages offer syntactic sugar in the form of looping constructs for
iteratables. In C#, there is `foreach`:

```csharp
using System;
using System.Text;

var values = new[] { 1, 2, 3, 4, 5 };
var output = new StringBuilder();

foreach (var value in values)
{
    if (output.Length > 0)
        output.Append(", ");
    output.Append(value);
}

Console.Write(output); // Prints: 1, 2, 3, 4, 5
```

In Rust, the equivalent is simply `for`:

```rust
use std::fmt::Write;

fn main() {
    let values = [1, 2, 3, 4, 5];
    let mut output = String::new();

    for value in values {
        if output.len() > 0 {
            output.push_str(", ");
        }
        // ! discard/ignore any write error
        _ = write!(output, "{value}");
    }

    println!("{output}");  // Prints: 1, 2, 3, 4, 5
}
```

The `for` loop over an iterable essentially gets desuraged to the following:

```rust
use std::fmt::Write;

fn main() {
    let values = [1, 2, 3, 4, 5];
    let mut output = String::new();

    let iter = &mut values.into_iter();         // get iterator
    loop {                                      // loop indefinitely
        match iter.next() {                     //   get next item
            Some(value) => {                    //   when there's an item, do...
                if output.len() > 0 {
                    output.push_str(", ");
                }
                _ = write!(output, "{value}");
            },
            None => {                           //   when no more items, ...
                break;                          //     break out of loop
            }
        }
    }

println!("{output}");
}
```

Rust's ownership and data race condition rules apply to all instances and
data, and iteration is no exception. So while looping over an array might look
straightforward and very similar to C#, one has to be mindful about ownership
when needing to iterate the same collection/iterable more than once. The
following example iteraters the list of integers twice, once to print their sum
and another time to determine and print the maximum integer:

```rust
fn main() {
    let values = vec![1, 2, 3, 4, 5];

    // sum all values

    let mut sum = 0;
    for value in values {
        sum += value;
    }
    println!("sum = {sum}");

    // determine maximum value

    let mut max = None;
    for value in values {
        if let Some(some_max) = max { // if max is defined
            if value > some_max {     // and value is greater
                max = Some(value)     // then note that new max
            }
        } else {                      // max is undefined when iteration starts
            max = Some(value)         // so set it to the first value
        }
    }
    println!("max = {max:?}");
}
```

However, the code above is rejected by the compiler due to a subtle
difference: `values` has been changed from an array to a [`Vec<int>`][vec.rs],
a _vector_, which is Rust's type for growable arrays (like `List<T>` in .NET).
The first iteration of `values` ends up _consuming_ each value as the integers
are summed up. In other words, the ownership of _each item_ in the vector
passes to the iteration variable of the loop: `value`. Since `value` goes out
of scope at the end of each iteration of the loop, the instance it owns is
dropped. Had `values` been a vector of heap-allocated data, the heap memory
backing each item would get freed as the loop moved to the next item. To fix
the problem, one has to request iteration over _shared_ references via
`&values` in the `for` loop. As a result, `value` ends up being a shared
reference to an item as opposed to taking its ownership.

  [vec.rs]: https://doc.rust-lang.org/stable/std/vec/struct.Vec.html

Below is the updated version of the previous example that compiles. The fix is
to simply replace `values` with `&values` in each of the `for` loops.

```rust
fn main() {
    let values = vec![1, 2, 3, 4, 5];

    // sum all values

    let mut sum = 0;
    for value in &values {
        sum += value;
    }
    println!("sum = {sum}");

    // determine maximum value

    let mut max = None;
    for value in &values {
        if let Some(some_max) = max { // if max is defined
            if value > some_max {     // and value is greater
                max = Some(value)     // then note that new max
            }
        } else {                      // max is undefined when iteration starts
            max = Some(value)         // so set it to the first value
        }
    }
    println!("max = {max:?}");
}
```

The ownership and dropping can be seen in action even with `values` being an
array instead of a vector. Consider just the summing loop from the above
example over an array of a structure that wraps an integer:

```rust
struct Int(i32);

impl Drop for Int {
    fn drop(&mut self) {
        println!("{} dropped", self.0)
    }
}

fn main() {
    let values = [Int(1), Int(2), Int(3), Int(4), Int(5)];
    let mut sum = 0;

    for value in values {
        sum += value.0;
    }

    println!("sum = {sum}");
}
```

`Int` implements `Drop` so that a message is printed when an instance get
dropped. Running the above code will print:

    value = Int(1)
    Int(1) dropped
    value = Int(2)
    Int(2) dropped
    value = Int(3)
    Int(3) dropped
    value = Int(4)
    Int(4) dropped
    value = Int(5)
    Int(5) dropped
    sum = 15

It's clear that each value is acquired and dropped while the loop is running.
Once the loop is complete, the sum is printed. If `values` in the `for` loop
is changed to `&values` instead, like this:

```rust
for value in &values {
    // ...
}
```

then the output of the program will change radically:

    value = Int(1)
    value = Int(2)
    value = Int(3)
    value = Int(4)
    value = Int(5)
    sum = 15
    Int(1) dropped
    Int(2) dropped
    Int(3) dropped
    Int(4) dropped
    Int(5) dropped

This time, values are acquired but not dropped while looping because each item
doesn't get owned by the interation loop's variable. The sum is printed ocne
the loop is done. Finally, when the `values` array that still owns all the the
`Int` instances goes out of scope at the end of `main`, its dropping in turn
drops all the `Int` instances.

These examples demonstrate that while iterating collection types may seem to
have a lot of parallels between Rust and C#, from the looping constructs to
the iteration abstractions, there are still subtle differences with respect to
ownership that not kept in mind at all times otherwise the compiler will end
up rejecting the code.

See also:

- [Iterator][iter-mod]
- [Iterating by reference]

[into-iter.rs]: https://doc.rust-lang.org/std/iter/trait.IntoIterator.html
[iter.rs]: https://doc.rust-lang.org/core/iter/trait.Iterator.html
[iter-mod]: https://doc.rust-lang.org/std/iter/index.html
[iterating by reference]: https://doc.rust-lang.org/std/iter/index.html#iterating-by-reference

### Operators

_Operators_ in LINQ are implemented in the form of C# extension methods that
can be chained together to form a set of operations, with the most common
forming a query over some sort of data source. C# also offers a SQL-inspired
_query syntax_ with clauses like `from`, `where`, `select`, `join` and others
that can serve as an alternative or a companion to method chaining. Many
imperative loops can be re-written as much more expressive and composable
queries in LINQ.

Rust does not offer anything like C#'s query syntax. It has methods, called
_[adapters]_ in Rust terms, over iteratable types and therefore directly
comparable to chaining of methods in C#. However, whlie rewriting an
imperative loop as LINQ code in C# is often beneficial in expressivity,
robustness and composability, there is a trade-off with performance.
Compute-bound imperative loops _usually_ run faster because they can be
optimised by the JIT compiler and there are fewer virtual dispatches or
indirect function invocations incurred. The surprising part in Rust is that
there is no performance trade-off between choosing to use method chains on an
abstraction like an iterator over writing an imperative loop by hand. It's
therefore far more common to see the former in code.

The following table lists the most common LINQ methods and their approximate
counterparts in Rust.

| .NET              | Rust         | Note        |
| ----------------- | ------------ | ----------- |
| `Aggregate`       | `reduce`     | See note 1. |
| `Aggregate`       | `fold`       | See note 1. |
| `All`             | `all`        |             |
| `Any`             | `any`        |             |
| `Concat`          | `chain`      |             |
| `Count`           | `count`      |             |
| `ElementAt`       | `nth`        |             |
| `GroupBy`         | -            |             |
| `Last`            | `last`       |             |
| `Max`             | `max`        |             |
| `Max`             | `max_by`     |             |
| `MaxBy`           | `max_by_key` |             |
| `Min`             | `min`        |             |
| `Min`             | `min_by`     |             |
| `MinBy`           | `min_by_key` |             |
| `Reverse`         | `rev`        |             |
| `Select`          | `map`        |             |
| `Select`          | `enumerate`  |             |
| `SelectMany`      | `flat_map`   |             |
| `SelectMany`      | `flatten`    |             |
| `SequenceEqual`   | `eq`         |             |
| `Single`          | `find`       |             |
| `SingleOrDefault` | `try_find`   |             |
| `Skip`            | `skip`       |             |
| `SkipWhile`       | `skip_while` |             |
| `Sum`             | `sum`        |             |
| `Take`            | `take`       |             |
| `TakeWhile`       | `take_while` |             |
| `ToArray`         | `collect`    | See note 2. |
| `ToDictionary`    | `collect`    | See note 2. |
| `ToList`          | `collect`    | See note 2. |
| `Where`           | `filter`     |             |
| `Zip`             | `zip`        |             |

1. The `Aggregate` overload not accepting a seed value is equivalent to
   `reduce`, while the `Aggregate` overload accepting a seed value corresponds
   to `fold`.

2. [`collect`][collect.rs] in Rust generally works for any collectible type,
   which is defined as [a type that can initialize itself from an iterator
   (see `FromIterator`)][FromIter.rs]. `collect` needs a target type, which
   the compiler sometimes has trouble inferring so the _turbofish_ (`::<>`) is
   often used in conjunction with it, as in `collect::<Vec<_>>()`. This is why
   `collect` appears next to a number of LINQ extension methods that convert
   an enumerable/iterable source to some collection type instance.

  [FromIter.rs]: https://doc.rust-lang.org/stable/std/iter/trait.FromIterator.html

The following example shows how similar transforming sequences in C# is to
doing the same in Rust. First in C#:

```csharp
var result =
    Enumerable.Range(0, 10)
              .Where(x => x % 2 == 0)
              .SelectMany(x => Enumerable.Range(0, x))
              .Aggregate(0, (acc, x) => acc + x);

Console.WriteLine(result); // 50
```

And in Rust:

```rust
let result = (0..10)
    .filter(|x| x % 2 == 0)
    .flat_map(|x| (0..x))
    .fold(0, |acc, x| acc + x);

println!("{result}"); // 50
```

[section-meta-programming]: #meta-programming
[adapters]: https://doc.rust-lang.org/std/iter/index.html#adapters
[collect.rs]: https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.collect

### Deferred execution (laziness)

Many operators in LINQ are designed to be lazy such that they only do work
when absolutely required. This enables composition or chaining of several
operations/methods without causing any side-effects. For example, a LINQ
operator can return an `IEnumerable<T>` that is initialized, but does not
produce, compute or materialize any items of `T` until iterated. The operator
is said to have _deferred execution_ semantics. If each `T` is computed as
iteration reaches it (as opposed to when iteration begins) then the operator
is said to _stream_ the results.

Rust iterators have the same concept of [_laziness_][iter-laziness] and
streaming.

  [iter-laziness]: https://doc.rust-lang.org/std/iter/index.html#laziness

In both cases, this allows _infinite sequences_ to be represented, where the
underlying sequence is infinite, but the developer decides how the sequence
should be terminated . The following example shows this in C#:

```csharp
foreach (var x in InfiniteRange().Take(5))
    Console.Write($"{x} "); // Prints "0 1 2 3 4"

IEnumerable<int> InfiniteRange()
{
    for (var i = 0; ; ++i)
        yield return i;
}
```

Rust supports the same concept through infinite ranges:

```rust
// Generators and yield in Rust are unstable at the moment, so
// instead, this sample uses Range:
// https://doc.rust-lang.org/std/ops/struct.Range.html

for value in (0..).take(5) {
    print!("{value} "); // Prints "0 1 2 3 4"
}
```

### Iterator Methods (`yield`)

C# has the `yield` keword that enables the developer to quickly write an
_iterator method_. The return type of an iterator method can be an
`IEnumerable<T>` or an `IEnumerator<T>`. The compiler then converts the body
of the method into a concrete implementation of the return type, instead of
the developer having to write a full-blown class each time.
_[Generators][generators.rs]_, as they're called in Rust, are still considered
an unstable feature at the time of this writing.

  [generators.rs]: https://doc.rust-lang.org/beta/unstable-book/language-features/generators.html

## Meta Programming

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

To understand more about how to write declarative macros, it is possible to read
the rust reference chapter [macros by example].

[Procedural macros] are different than declarative macros. Those accept some code
as an input, operate on that code, and produce some code as an output.

Another technique used in C# for metaprogramming is reflection. Rust is not
supporting reflection.

### Function-like macros

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

### Derive macros

Derive macros can create new items given the token stream of a struct, enum, or
union. An example of a derive macro is the `#[derive(Clone)]` one, which is
generating the needed code for making the input struct/enum/union implement the
`Clone` trait.

In order to understand how to define a custom derive macro, it is possible to
read the rust reference for [derive macros]

[derive macros]: https://doc.rust-lang.org/reference/procedural-macros.html#derive-macros

### Attribute macros

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

[source-gen]: https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/source-generators-overview
[T4]: https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2015/modeling/code-generation-and-t4-text-templates?view=vs-2015&redirectedfrom=MSDN
[template]: https://github.com/Azure/iotedge-lorawan-starterkit/blob/dev/LoRaEngine/modules/LoRaWanNetworkSrvModule/LoraTools/JsonReader.g.tt
[concretization]: https://github.com/Azure/iotedge-lorawan-starterkit/blob/dev/LoRaEngine/modules/LoRaWanNetworkSrvModule/LoraTools/JsonReader.g.cs
[macros]: https://doc.rust-lang.org/book/ch19-06-macros.html
[macros by example]: https://doc.rust-lang.org/reference/macros-by-example.html
[procedural macros]: https://doc.rust-lang.org/reference/procedural-macros.html

## Asynchronous Programming

Both .NET and Rust support asynchronous programming models, which look similar
to each other with respect to their usage. The following example shows, on a
very high level, how async code looks like in C#:

```csharp
async Task<string> PrintDelayed(string message, CancellationToken cancellationToken)
{
    await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken);
    return $"Message: {message}";
}
```

Rust code is structured similarly. The following sample relies on [async-std]
for the implementation of `sleep`:

```rust
use std::time::Duration;
use async_std::task::sleep;

async fn format_delayed(message: &str) -> String {
    sleep(Duration::from_secs(1)).await;
    format!("Message: {}", message)
}
```

1. The Rust [`async`][async.rs] keyword transforms a block of code into a state
   machine that implements a trait called [`Future`][future.rs], similarly to
   how the C# compiler transforms `async` code into a state machine. In both
   languages, this allows for writing asynchronous code sequentially.

2. Note that for both Rust and C#, asynchronous methods/functions are prefixed
   with the async keyword, but the return types are different. Asynchronous
   methods in C# indicate the full and actual return type because it can vary.
   For example, it is common to see some methods return a `Task<T>` while others
   return a `ValueTask<T>`. In Rust, it is enough to specify the _inner type_
   `String` because it's _always some future_; that is, a type that implements
   the `Future` trait.

3. The `await` keywords are in different positions in C# and Rust. In C#, a
   `Task` is awaited by prefixing the expression with `await`. In Rust,
   suffixing the expression with the `.await` keyword allows for _method
   chaining_, even though `await` is not a method.

See also:

- [Asynchronous programming in Rust]

[async-std]: https://docs.rs/async-std/latest/async_std/
[async.rs]: https://doc.rust-lang.org/std/keyword.async.html
[future.rs]: https://doc.rust-lang.org/std/future/trait.Future.html
[Asynchronous programming in Rust]: https://rust-lang.github.io/async-book/

### Executing tasks

From the following example the `PrintDelayed` method executes, even though it is
not awaited:

```csharp
var cancellationToken = CancellationToken.None;
PrintDelayed("message", cancellationToken); // Prints "message" after a second.
await Task.Delay(TimeSpan.FromSeconds(2), cancellationToken);

async Task PrintDelayed(string message, CancellationToken cancellationToken)
{
    await Task.Delay(TimeSpan.FromSeconds(1), cancellationToken);
    Console.WriteLine(message);
}
```

In Rust, the same function invocation does not print anything.

```rust
use async_std::task::sleep;
use std::time::Duration;

#[tokio::main] // used to support an asynchronous main method
async fn main() {
    print_delayed("message"); // Prints nothing.
    sleep(Duration::from_secs(2)).await;
}

async fn print_delayed(message: &str) {
    sleep(Duration::from_secs(1)).await;
    println!("{}", message);
}
```

This is because futures are lazy: they do nothing until they are run. The most
common way to run a `Future` is to `.await` it. When `.await` is called on a
`Future`, it will attempt to run it to completion. If the `Future` is blocked,
it will yield control of the current thread. When more progress can be made, the
`Future` will be picked up by the executor and will resume running, allowing the
`.await` to resolve (see [`async/.await`][async-await.rs]).

While awaiting a function works from within other `async` functions, `main` [is
not allowed to be `async`][error-E0752]. This is a consequence of the fact that
Rust itself does not provide a runtime for executing asynchronous code. Hence,
there are libraries for executing asynchronous code, called [async runtimes].
[Tokio][tokio.rs] is such an async runtime, and it is frequently used.
[`tokio::main`][tokio-main.rs] from the above example marks the `async main`
function as entry point to be executed by a runtime, which is set up
automatically when using the macro.

[tokio.rs]: https://crates.io/crates/tokio
[tokio-main.rs]: https://docs.rs/tokio/latest/tokio/attr.main.html
[async-await.rs]: https://rust-lang.github.io/async-book/03_async_await/01_chapter.html#asyncawait
[error-E0752]: https://doc.rust-lang.org/error-index.html#E0752
[async runtimes]: https://rust-lang.github.io/async-book/08_ecosystem/00_chapter.html#async-runtimes
[executor.rs]: https://rust-lang.github.io/async-book/02_execution/04_executor.html

### Task cancellation

The previous C# examples included passing a `CancellationToken` to asynchronous
methods, as is considered best practice in .NET. `CancellationToken`s can be
used to abort an asynchronous operation.

Because futures are inert in Rust (they make progress only when polled),
cancellation works differently in Rust. When dropping a `Future`, the `Future`
will make no further progress. It will also drop all instantiated values up to
the point where the future is suspended due to some outstanding asynchronous
operation. This is why most asynchronous functions in Rust don't take an
argument to signal cancellation, and is why dropping a future is sometimes being
referred to as _cancellation_.

[`tokio_util::sync::CancellationToken`][cancellation-token.rs] offers an
equivalent to the .NET `CancellationToken` to signal and react to cancellation,
for cases where implementing the `Drop` trait on a `Future` is unfeasible.

[cancellation-token.rs]: https://docs.rs/tokio-util/latest/tokio_util/sync/struct.CancellationToken.html
[join-handle.rs]: https://docs.rs/tokio/latest/tokio/task/struct.JoinHandle.html#cancel-safety

### Executing multiple Tasks

In .NET, `Task.WhenAny` and `Task.WhenAll` are frequently used to handle the
execution of multiple tasks.

`Task.WhenAny` completes as soon as any task completes. Tokio, for example,
provides the [`tokio::select!`][tokio-select] macro as an alternative for
`Task.WhenAny`, which means to wait on multiple concurrent branches.

```csharp
var cancellationToken = CancellationToken.None;

var result =
    await Task.WhenAny(Delay(TimeSpan.FromSeconds(2), cancellationToken),
                       Delay(TimeSpan.FromSeconds(1), cancellationToken));

Console.WriteLine(result.Result); // Waited 1 second(s).

async Task<string> Delay(TimeSpan delay, CancellationToken cancellationToken)
{
    await Task.Delay(delay, cancellationToken);
    return $"Waited {delay.TotalSeconds} second(s).";
}
```

The same example for Rust:

```rust
use std::time::Duration;
use tokio::{select, time::sleep};

#[tokio::main]
async fn main() {
    let result = select! {
        result = delay(Duration::from_secs(2)) => result,
        result = delay(Duration::from_secs(1)) => result,
    };

    println!("{}", result); // Waited 1 second(s).
}

async fn delay(delay: Duration) -> String {
    sleep(delay).await;
    format!("Waited {} second(s).", delay.as_secs())
}
```

Again, there are crucial differences in semantics between the two examples. Most
importantly, `tokio::select!` will cancel all remaining branches, while
`Task.WhenAny` leaves it up to the user to cancel any in-flight tasks.

Similarly, `Task.WhenAll` can be replaced with [`tokio::join!`][tokio-join].

[tokio-select]: https://docs.rs/tokio/latest/tokio/macro.select.html
[tokio-join]: https://docs.rs/tokio/latest/tokio/macro.join.html

### Multiple consumers

In .NET a `Task` can be used across multiple consumers. All of them can await
the task and get notified when the task is completed or failed. In Rust, the
`Future` can not be cloned or copied, and `await`ing will move the ownership.
The `futures::FutureExt::shared` extension creates a cloneable handle to a
`Future`, which then can be distributed across multiple consumers.

```rust
use futures::FutureExt;
use std::time::Duration;
use tokio::{select, time::sleep, signal};
use tokio_util::sync::CancellationToken;

#[tokio::main]
async fn main() {
    let token = CancellationToken::new();
    let child_token = token.child_token();

    let bg_operation = background_operation(child_token);

    let bg_operation_done = bg_operation.shared();
    let bg_operation_final = bg_operation_done.clone();

    select! {
        _ = bg_operation_done => {},
        _ = signal::ctrl_c() => {
            token.cancel();
        },
    }

    bg_operation_final.await;
}

async fn background_operation(cancellation_token: CancellationToken) {
    select! {
        _ = sleep(Duration::from_secs(2)) => println!("Background operation completed."),
        _ = cancellation_token.cancelled() => println!("Background operation cancelled."),
    }
}
```

#### Asynchronous iteration

While in .NET there are [`IAsyncEnumerable<T>`][async-enumerable.net] and
[`IAsyncEnumerator<T>`][net-async-enumerator], Rust does not yet have an API for
asynchronous iteration in the standard library. To support asynchronous
iteration, the [`Stream`][stream.rs] trait from [`futures`][futures-stream.rs]
offers a comparable set of functionality.

In C#, writing async iterators has comparable syntax to when writing synchronous
iterators:

```csharp
await foreach (int item in RangeAsync(10, 3).WithCancellation(CancellationToken.None))
    Console.Write(item + " "); // Prints "10 11 12".

async IAsyncEnumerable<int> RangeAsync(int start, int count)
{
    for (int i = 0; i < count; i++)
    {
        await Task.Delay(TimeSpan.FromSeconds(i));
        yield return start + i;
    }
}
```

In Rust, there are several types that implement the `Stream` trait, and hence
can be used for creating streams, e.g. `futures::channel::mpsc`. For a syntax
closer to C#, [`async-stream`][tokio-async-stream] offers a set of macros that
can be used to generate streams succinctly.

```rust
use async_stream::stream;
use futures_core::stream::Stream;
use futures_util::{pin_mut, stream::StreamExt};
use std::{
    io::{stdout, Write},
    time::Duration,
};
use tokio::time::sleep;

#[tokio::main]
async fn main() {
    let stream = range(10, 3);
    pin_mut!(stream); // needed for iteration
    while let Some(result) = stream.next().await {
        print!("{} ", result); // Prints "10 11 12".
        stdout().flush().unwrap();
    }
}

fn range(start: i32, count: i32) -> impl Stream<Item = i32> {
    stream! {
        for i in 0..count {
            sleep(Duration::from_secs(i as _)).await;
            yield start + i;
        }
    }
}
```

[async-enumerable.net]: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.iasyncenumerable-1
[async-enumerator.net]: https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.iasyncenumerator-1
[stream.rs]: https://rust-lang.github.io/async-book/05_streams/01_chapter.html
[futures-stream.rs]: https://docs.rs/futures/latest/futures/stream/trait.Stream.html
[tokio-async-stream]: https://github.com/tokio-rs/async-stream

## Project Structure

While there are conventions around structuring a project  in .NET, they are
less strict compared to the Rust project structure conventions. When creating
a two-project solution using Visual Studio 2022 (a class library and an xUnit
test project), it will create the following structure:

    .
    |   SampleClassLibrary.sln
    +---SampleClassLibrary
    |       Class1.cs
    |       SampleClassLibrary.csproj
    +---SampleTestProject
            SampleTestProject.csproj
            UnitTest1.cs
            Usings.cs

- Each project resides in a separate directory, with its own `.csproj` file.
- At the root of the repository is a `.sln` file.

Cargo uses the following conventions for the [package
layout][cargo-package-layout] to make it easy to dive into a new Cargo
[package][rust-package]:

    .
    +-- Cargo.lock
    +-- Cargo.toml
    +-- src/
    |   +-- lib.rs
    |   +-- main.rs
    +-- benches/
    |   +-- some-bench.rs
    +-- examples/
    |   +-- some-example.rs
    +-- tests/
        +-- some-integration-test.rs

- `Cargo.toml` and `Cargo.lock` are stored in the root of the package.
- `src/lib.rs` is the default library file, and `src/main.rs` is the default
  executable file (see [target auto-discovery]).
- Benchmarks go in the `benches` directory, integration tests go in the `tests`
  directory (see [testing][section-testing],
  [benchmarking][section-benchmarking]).
- Examples go in the `examples` directory.
- There is no separate crate for unit tests, unit tests live in the same file as
  the code (see [testing][section-testing]).

[package layout]: https://doc.rust-lang.org/cargo/guide/project-layout.html
[rust-package]: https://doc.rust-lang.org/cargo/appendix/glossary.html#package
[target auto-discovery]: https://doc.rust-lang.org/cargo/reference/cargo-targets.html#target-auto-discovery
[section-testing]: #Testing
[section-benchmarking]: #Benchmarking

### Managing large projects

For very large projects in Rust, Cargo offers [workspaces][cargo-workspaces] to
organize the project. A workspace can help manage multiple related packages that
are developed in tandem. Some projects use [_virtual
manifests_][cargo-virtual-manifest], especially when there is no primary
package.

[cargo-workspaces]: https://doc.rust-lang.org/book/ch14-03-cargo-workspaces.html
[cargo-virtual-manifest]: https://doc.rust-lang.org/cargo/reference/workspaces.html#virtual-workspace

### Managing dependency versions

When managing larger projects in .NET, it may be appropriate to manage the
versions of dependencies centrally, using strategies such as [Central Package
Management]. Cargo introduced [workspace inheritance] to manage dependencies
centrally.

[Central Package Management]: https://learn.microsoft.com/en-us/nuget/consume-packages/Central-Package-Management
[workspace inheritance]: https://doc.rust-lang.org/cargo/reference/workspaces.html#the-package-table

## Compilation and Building

### .NET CLI

The equivalent of the .NET CLI (`dotnet`) in Rust is [Cargo] (`cargo`). Both
tools are entry-point wrappers that simplify use of other low-level tools. For
example, although you could invoke the C# compiler directly (`csc`) or MSBuild
via `dotnet msbuild`, developers tend to use `dotnet build` to build their
solution. Similarly in Rust, while you could use the Rust compiler (`rustc`)
directly, using `cargo build` is generally far simpler.

[cargo]: https://doc.rust-lang.org/cargo/

### Building

Building an executable in .NET using [`dotnet build`][net-build-output]
restores pacakges, compiles the project sources into an [assembly]. The
assembly contain the code in Intermediate Language (IL) and can _typically_ be
run on any platform supported by .NET and provided the .NET runtime is
installed on the host. The assemblies coming from dependent packages are
generally co-located with the project's output assembly. [`cargo
build`][cargo-build] in Rust does the same, except the Rust compiler
statically links (although there exist other [linking options][linkage]) all
code into a single, platform-dependent, binary.

Developers use `dotnet publish` to prepare a .NET executable for distribution,
either as a _framework-dependent deployment_ (FDD) or _self-contained
deployment_ (SCD). In Rust, there is no equivalent to `dotnet publish` as the
build output already contains a single, platform-dependent binary for each
target.

When building a library in .NET using [`dotnet build`][net-build-output], it
will still generate an [assembly] containing the IL. In Rust, the build output
is, again, a platform-dependent, compiled library for each library target.

See also:

- [Crate]

[net-build-output]: https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-build#description
[assembly]: https://learn.microsoft.com/en-us/dotnet/standard/assembly/
[cargo-build]: https://doc.rust-lang.org/cargo/commands/cargo-build.html#cargo-build1
[linkage]: https://doc.rust-lang.org/reference/linkage.html
[crate]: https://doc.rust-lang.org/book/ch07-01-packages-and-crates.html

### Dependencies

In .NET, the contents of a project file define the build options and
dependencies. In Rust, when using Cargo, a `Cargo.toml` declares the
dependencies for a package. A typical project file will look like:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="morelinq" Version="3.3.2" />
  </ItemGroup>

</Project>
```

The equivalent `Cargo.toml` in Rust is defined as:

```toml
[package]
name = "hello_world"
version = "0.1.0"

[dependencies]
tokio = "1.0.0"
```

Cargo follows a convention that `src/main.rs` is the crate root of a binary
crate with the same name as the package. Likewise, Cargo knows that if the
package directory contains `src/lib.rs`, the package contains a library crate
with the same name as the package.

### Packages

NuGet is most commonly used to install packages, and various tools supported it.
For example, adding a NuGet package reference with the .NET CLI will add the
dependency to the project file:

  dotnet add package morelinq

In Rust this works almost the same if using Cargo to add packages.

  cargo add tokio

The most common package registry for .NET is [nuget.org] whereas Rust packages
are usually shared via [crates.io].

[nuget.org]: https://www.nuget.org/
[crates.io]: https://crates.io

### Static code analysis

Since .NET 5, the Roslyn analyzers come bundled with the .NET SDK and provide
code quality as well as code-style analysis. The equivalent linting tool in Rust
is [Clippy].

Similarly to .NET, where the build fails if warnings are present by setting
[`TreatWarningsAsErrors`][treat-warnings-as-errors] to `true`, Clippy can fail
if the compiler or Clippy emits warnings (`cargo clippy -- -D warnings`).

There are further static checks to consider adding to a Rust CI pipeline:

- Run [`cargo doc`][cargo-doc] to ensure that documentation is correct.
- Run [`cargo check --locked`][cargo-check] to enforce that the `Cargo.lock`
  file is up-to-date.

[clippy]: https://github.com/rust-lang/rust-clippy
[treat-warnings-as-errors]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/errors-warnings
[cargo-doc]: https://doc.rust-lang.org/cargo/commands/cargo-doc.html
[cargo-check]: https://doc.rust-lang.org/cargo/commands/cargo-check.html#manifest-options
