# Threading

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

- It is possible to also pass data to the C# thread via a closure, like the
  Rust example, but the C# version does not need to worry about ownership
  since the memory behind the data will be reclaimed by the GC once no one is
  referencing it anymore.
