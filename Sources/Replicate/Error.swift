/// An error returned by the Replicate HTTP API
public struct Error: Swift.Error, Decodable {
    /// A description of the error.
    public let detail: String
}
