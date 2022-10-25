# Rust for .NET Developers 

The document source can be found in the file `rust-for-dotnet-dev.md`.

## Building

### Windows

To build an HTML version of the document, you will need [`grip`][grip] and
Python. Run:

    .\pie.ps1

in a PowerShell 7 prompt to ensure Python and the required dependencies are
installed. This only needs to be done the first time. To uninstall anytime,
simply add the `-Uninstall` switch to the above script invocation.

Next, run:

    .\build.cmd

This will place the HTML version at `out\index.html`.

  [grip]: https://github.com/joeyespo/grip
