public protocol Predictable {
    associatedtype Input: Codable
    associatedtype Output: Codable

    static var modelID: Model.ID { get }
    static var versionID: Model.Version.ID { get }
}

// MARK: -

extension Predictable {
    public static func predict(with client: Client, input: Input, wait: Bool = false) async throws -> Prediction<Input, Output> {
        return try await client.createPrediction(Prediction<Input, Output>.self,
                                                 version: Self.versionID,
                                                 input: input,
                                                 wait: wait)
    }
}
