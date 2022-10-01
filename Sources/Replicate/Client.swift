import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import AnyCodable

/// A [Replicate HTTP API](https://replicate.com/docs/reference/http) client.
public class Client {
    /// A paginated collection of results.
    public struct Pagination<Result> {
        /// A pointer to a page of results.
        public struct Cursor: RawRepresentable, Hashable {
            public var rawValue: String

            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }

        /// A pointer to the previous page of results
        public let previous: Cursor?

        /// A pointer to the next page of results.
        public let next: Cursor?

        /// The results for this page.
        public let results: [Result]
    }

    private let token: String
    internal var session = URLSession(configuration: .default)

    /// Creates a client with the specified API token.
    ///
    /// You can get an Replicate API token on your
    /// [account page](https://replicate.com/account).
    ///
    /// - Parameter token: The API token.
    public init(token: String) {
        self.token = token
    }

    /// Create a prediction
    ///
    /// - Parameters:
    ///    - version:
    ///         The ID of the model version that you want to run.
    ///
    ///         You can get your model's versions using the API,
    ///         or find them on the website by clicking
    ///         the "Versions" tab on the Replicate model page,
    ///         e.g. replicate.com/replicate/hello-world/versions,
    ///         then copying the full SHA256 hash from the URL.
    ///
    ///         The version ID is the same as the Docker image ID
    ///         that's created when you build your model.
    ///    - input:
    ///        The input depends on what model you are running.
    ///
    ///        To see the available inputs,
    ///        click the "Run with API" tab on the model you are running.
    ///        For example, stability-ai/stable-diffusion
    ///        takes `prompt` as an input.
    ///    - webhook:
    ///         A webhook that is called when the prediction has completed.
    ///
    ///         It will be a `POST` request where
    ///         the request body is the same as
    ///         the response body of the get prediction endpoint.
    ///         If there are network problems,
    ///         we will retry the webhook a few times,
    ///         so make sure it can be safely called more than once.
    ///    - cursor: A pointer to a page of results to fetch.
    public func createPredication(version: Model.Version.ID,
                                  input: [String: AnyEncodable],
                                  webhook: URL? = nil,
                                  cursor: Pagination<Prediction>.Cursor? = nil)
        async throws -> Prediction
    {
        return try await fetch(.post, "predictions", params: input)
    }

    /// Get a prediction
    ///
    /// - Parameter id: The ID of the prediction you want to fetch.
    public func getPrediction(id: Prediction.ID) async throws -> Prediction {
        return try await fetch(.get, "predictions/\(id)")
    }

    /// Get a list of predictions
    ///
    /// - Parameter cursor: A pointer to a page of results to fetch.
    public func getPredictions(cursor: Pagination<Prediction>.Cursor? = nil)
        async throws -> Pagination<Prediction>
    {
        return try await fetch(.get, "predictions", cursor: cursor)
    }

    /// Get a model
    ///
    /// - Parameters:
    ///    - owner: The name of the user or organization that owns the model.
    ///    - name: The name of the model.
    public func getModel(owner: String,
                         name: String)
        async throws -> Model
    {
        return try await fetch(.get, "models/\(owner)/\(name)")
    }

    /// Get a list of model versions
    ///
    /// - Parameters:
    ///    - owner: The name of the user or organization that owns the model.
    ///    - name: The name of the model.
    ///    - cursor: A pointer to a page of results to fetch.
    public func getModelVersions(owner: String,
                                 name: String,
                                 cursor: Pagination<Model.Version>.Cursor? = nil)
        async throws -> Pagination<Model.Version>
    {
        return try await fetch(.get, "models/\(owner)/\(name)/versions", cursor: cursor)
    }

    /// Get a model version
    ///
    /// - Parameters:
    ///    - owner: The name of the user or organization that owns the model.
    ///    - name: The name of the model.
    ///    - version: The ID of the version.
    public func getModelVersion(owner: String,
                                name: String,
                                version: Model.Version.ID)
        async throws -> Model.Version
    {
        return try await fetch(.get, "models/\(owner)/\(name)/\(version)")
    }

    /// Get a collection of models
    ///
    /// - Parameters:
    ///    - slug:
    ///         The slug of the collection,
    ///         like super-resolution or image-restoration.
    ///         
    ///         See <https://replicate.com/collections>
    public func getModelCollection(slug: String)
        async throws -> Model.Collection
    {
        return try await fetch(.get, "collections/\(slug)")
    }

    // MARK: -

    private enum Method: String {
        case get = "GET"
        case post = "POST"
    }

    private func fetch<T: Decodable>(_ method: Method, _ path: String, cursor: Pagination<T>.Cursor?) async throws -> Pagination<T> {
        var params: [String: AnyEncodable]? = nil
        if let cursor {
            params = ["cursor": "\(cursor)"]
        }

        return try await fetch(method, path, params: params)
    }

    private func fetch<T: Decodable>(_ method: Method, _ path: String, params: [String: AnyEncodable]? = nil) async throws -> T {
        var urlComponents = URLComponents(string: "https://api.replicate.com/v1/" + path)
        var httpBody: Data? = nil

        switch method {
        case .get:
            if let params {
                var queryItems: [URLQueryItem] = []
                for (key, value) in params {
                    queryItems.append(URLQueryItem(name: key, value: value.description))
                }
                urlComponents?.queryItems = queryItems
            }
        case .post:
            if let params {
                let encoder = JSONEncoder()
                httpBody = try encoder.encode(params)
            }
        }

        guard let url = urlComponents?.url else {
            throw Error(detail: "invalid request \(method) \(path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        if let httpBody {
            request.httpBody = httpBody
            request.addValue("Content-Type", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        switch (response as? HTTPURLResponse)?.statusCode {
        case (200..<300)?:
            return try decoder.decode(T.self, from: data)
        default:
            if let error = try? decoder.decode(Error.self, from: data) {
                throw error
            }

            throw Error(detail: "invalid response: \(response)")
        }
    }
}

// MARK: - Decodable

extension Client.Pagination: Decodable where Result: Decodable {
    private enum CodingKeys: String, CodingKey {
        case results
        case previous
        case next
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.previous = try? container.decode(Cursor.self, forKey: .previous)
        self.next = try? container.decode(Cursor.self, forKey: .next)
        self.results = try container.decode([Result].self, forKey: .results)
    }
}

extension Client.Pagination.Cursor: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let urlComponents = URLComponents(string: string),
           let queryItem = urlComponents.queryItems?.first(where: { $0.name == "cursor" }),
           let value = queryItem.value
        else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "invalid cursor")
            throw DecodingError.dataCorrupted(context)
        }

        self.rawValue = value
    }
}

// MARK: -

extension Client.Pagination.Cursor: CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}

extension Client.Pagination.Cursor: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: -

private extension JSONDecoder.DateDecodingStrategy {
    static let iso8601WithFractionalSeconds = custom {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds]

        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)

        guard let date = formatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }

        return date
    }
}
