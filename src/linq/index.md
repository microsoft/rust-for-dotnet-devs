# LINQ

This section discusses LINQ within the context and for the purpose of querying
or transforming sequences (`IEnumerable`/`IEnumerable<T>`) and typically
collections like lists, sets and dictionaries.

## `IEnumerable<T>`

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

    let mut iter = values.into_iter();      // get iterator
    while let Some(value) = iter.next() {   // loop as long as there are more items
        if output.len() > 0 {
            output.push_str(", ");
        }
        _ = write!(output, "{value}");
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
ownership that can lead to the compiler rejecting the code in some instances.

See also:

- [Iterator][iter-mod]
- [Iterating by reference]

[into-iter.rs]: https://doc.rust-lang.org/std/iter/trait.IntoIterator.html
[iter.rs]: https://doc.rust-lang.org/core/iter/trait.Iterator.html
[iter-mod]: https://doc.rust-lang.org/std/iter/index.html
[iterating by reference]: https://doc.rust-lang.org/std/iter/index.html#iterating-by-reference

## Operators

_Operators_ in LINQ are implemented in the form of C# extension methods that
can be chained together to form a set of operations, with the most common
forming a query over some sort of data source. C# also offers a SQL-inspired
_query syntax_ with clauses like `from`, `where`, `select`, `join` and others
that can serve as an alternative or a companion to method chaining. Many
imperative loops can be re-written as much more expressive and composable
queries in LINQ.

Rust does not offer anything like C#'s query syntax. It has methods, called
_[adapters]_ in Rust terms, over iterable types and therefore directly
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

[adapters]: https://doc.rust-lang.org/std/iter/index.html#adapters
[collect.rs]: https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.collect

## Deferred execution (laziness)

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

## Iterator Methods (`yield`)

C# has the `yield` keword that enables the developer to quickly write an
_iterator method_. The return type of an iterator method can be an
`IEnumerable<T>` or an `IEnumerator<T>`. The compiler then converts the body
of the method into a concrete implementation of the return type, instead of
the developer having to write a full-blown class each time.
_[Coroutines][coroutines.rs]_, as they're called in Rust, are still considered
an unstable feature at the time of this writing.

  [coroutines.rs]: https://doc.rust-lang.org/unstable-book/language-features/coroutines.html
