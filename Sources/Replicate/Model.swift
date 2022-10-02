import struct Foundation.Date
import AnyCodable

/// A machine learning model hosted on Replicate.
public struct Model: Identifiable {
    public typealias ID = String

    /// The visibility of the model.
    public enum Visibility: String, Decodable {
        /// Public visibility.
        case `public`

        /// Private visibility.
        case `private`
    }

    /// A version of a model.
    public struct Version: Identifiable {
        public typealias ID = String

        /// The ID of the version.
        public let id: String

        /// When the version was created.
        public let createdAt: Date

        /// An OpenAPI description of the model inputs and outputs.
        public let openAPISchema: AnyCodable
    }

    /// A collection of models.
    public struct Collection: Decodable {
        /// The name of the collection.
        public let name: String

        /// The slug of the collection,
        /// like super-resolution or image-restoration.
        ///
        /// See <https://replicate.com/collections>
        public let slug: String

        /// A description for the collection.
        public let description: String

        /// A list of models in the collection.
        public let models: [Model]
    }

    /// The ID of the model.
    public var id: ID { "\(owner)/\(name)" }

    /// The name of the user or organization that owns the model.
    public let owner: String

    /// The name of the model.
    public let name: String

    /// A link to the model on Replicate.
    public let url: String

    /// A link to the model source code on GitHub.
    public let githubURL: String?

    /// A link to the model's paper.
    public let paperURL: String?

    /// A link to the model's license.
    public let licenseURL: String?

    /// A description for the model.
    public let description: String

    /// The visibility of the model.
    public let visibility: Visibility

    /// The latest version of the model, if any.
    public let latestVersion: Version?
}

// MARK: - Decodable

extension Model: Decodable {
    private enum CodingKeys: String, CodingKey {
        case owner
        case name
        case url
        case githubURL = "github_url"
        case paperURL = "paper_url"
        case licenseURL = "license_url"
        case description
        case visibility
        case latestVersion = "lastest_version"
    }
}

extension Model.Version: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case openAPISchema = "openapi_schema"
    }
}
