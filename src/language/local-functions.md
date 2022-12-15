# Local Functions

C# and Rust offer local functions, but local functions in Rust are limited to
the equivalent of static local functions in C#. In other words, local
functions in Rust cannot use variables from their surrounding lexical scope;
but _closures_ can.
