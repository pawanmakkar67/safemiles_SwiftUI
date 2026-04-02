import Foundation

/// A common logging utility to handle debug-only print statements.
public struct AppLog {
    /// Prints the given items if the app is built in Debug mode.
    /// Shadows the standard print behavior but remains explicit.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to print.
    ///   - separator: A string to print between each item. The default is a single space (" ").
    ///   - terminator: A string to print after all items have been printed. The default is a newline ("\n").
    public static func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
        #endif
    }
}
