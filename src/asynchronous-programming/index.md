# Asynchronous Programming

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

## Executing tasks

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

## Task cancellation

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

## Executing multiple Tasks

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

## Multiple consumers

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

## Asynchronous iteration

While in .NET there are [`IAsyncEnumerable<T>`][async-enumerable.net] and
[`IAsyncEnumerator<T>`][async-enumerator.net], Rust does not yet have an API for
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
