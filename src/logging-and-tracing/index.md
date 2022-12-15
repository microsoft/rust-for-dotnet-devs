# Logging and Tracing

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
