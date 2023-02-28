# Contributing

You are invited to contribute 💖 to this guide by opening issues and
submitting pull requests!

Here are some ideas 💡 for how and where you can help most with
contributions:

- Fix any spelling or grammatical mistakes you see as you read.

- Fix technical inaccuracies.

- Fix logical or compilation errors in code examples.

- Improve the English, especially if it's your native tongue or you have
  excellent proficiency in the language.

- Expand an explanation to provide more context or improve the clarity of some
  topic or concept.

- Keep it fresh with changes in C#, .NET and Rust. For example, if there is a
  change in C# or Rust that brings the two languages closer together then some
  parts, including sample code, may need revision.

If you're making a small to modest correction, such fixing a spelling error or
a syntax error in a code example, then feel free to submit a pull request
directly. For changes that may require a large effort on your part (and
reviewers as a result), it is strongly recommended that you submit an issue
and seek approval of the maintainers/editors before investing your time. It
will avoid heartbreak 💔 if the pull request is rejected for various reasons.

Making quick contributions has been made super simple. If you see an error on
a page and happen to be online, you can click edit icon 📝 in the corner of
the page to edit the Markdown source of the content and submit a change.

## Contribution Guidelines

- Stick to the goals of this guide laid out in the [introduction]; put another
  way, avoid the non-goals!

- Prefer to keep text short and use short, concise and realistic code examples
  to illustrate a point.

- As much as it is possible, always provide and compare examples in Rust and
  C#.

- Feel free to use latest C#/Rust language features if it makes an example
  simpler, concise and alike across the two languages.

- Avoid using community packages in C# examples. Stick to the .NET [Base Class
  Library] as much as possible. Since the [Rust Standard Library] has a much
  smaller API surface, it is more acceptable to call out crates for some
  functionality, should it be necessary for illustration (like [`rand`][rand]
  for random number generation), but make sure they are mature, popular and
  trusted.

- Make example code as self-contained as possible and runnable (unless the
  idea is to illustrate a compile-time or run-time error).

- Maintain the general style of this guide, which is to avoid using _you_ as
  if the reader is being told or instructed; use the third-person voice
  instead. For example, instead of saying, &ldquo;You represent optional data
  in Rust with the `Option<T>` type&rdquo;, write instead, &ldquo;Rust has the
  `Option<T>` type that is used to represent optional data&rdquo;.

  [introduction]: introduction.md
  [Base Class Library]: https://learn.microsoft.com/en-us/dotnet/standard/framework-libraries#base-class-library
  [Rust Standard Library]: https://doc.rust-lang.org/std/
  [rand]: https://docs.rs/rand/latest/rand/
