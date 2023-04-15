# Synchronization

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
special _traits_ (see [Interfaces]): `Sync` and `Send`. [`Sync`][sync.rs]
indicates that references to a type's instances are safe to share between
threads. [`Send`][send.rs] indicates it's safe to instances of a type across
thread boundaries. For more information, see the “[Fearless Concurrency]”
chapter of the Rust book.

  [Fearless Concurrency]: https://doc.rust-lang.org/book/ch16-00-concurrency.html
  [Memory Management]: ../memory-management/index.md
  [mutex guard]: https://doc.rust-lang.org/stable/std/sync/struct.MutexGuard.html
  [sync.rs]: https://doc.rust-lang.org/stable/std/marker/trait.Sync.html
  [send.rs]: https://doc.rust-lang.org/stable/std/marker/trait.Send.html
  [interfaces]: ../language/custom-types.md#interfaces
