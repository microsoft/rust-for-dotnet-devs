# Resource Management

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

In .NET, attempting to use an object after calling `Dispose` on it will typically
cause `ObjectDisposedException` to be thrown at runtime. In Rust, the compiler
ensures at compile-time that this cannot happen.

[memory management]: ../memory-management/index.md
