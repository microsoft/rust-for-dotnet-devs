# Producer-Consumer

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

    let producer = thread::spawn(move || {
        for n in 1..10 {
            tx.send(format!("Message #{}", n)).unwrap();
        }
    });

    // main thread is the consumer here
    for received in rx {
        println!("{}", received);
    }

    producer.join().unwrap();
}
```

Like channels in Rust, .NET also offers channels in the
`System.Threading.Channels` namespace, but it is primarily designed to be used
with tasks and asynchronous programming using `async` and `await`. The
equivalent of the [async-friendly channels in the Rust space is offered by the
Tokio runtime][tokio-channels].

  [tokio-channels]: https://tokio.rs/tokio/tutorial/channels
