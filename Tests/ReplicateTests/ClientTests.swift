import XCTest
@testable import Replicate

final class ClientTests: XCTestCase {
    var client = Client.valid

    static override func setUp() {
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    func testCreatePrediction() async throws {
        let version: Model.Version.ID = "5c7d5dc6dd8bf75c1acaa8565735e7986bc5b66206b55cca93cb72c9bf15ccaa"
        let prediction = try await client.createPredication(version: version, input: ["text": "Alice"])
        XCTAssertEqual(prediction.id, "ufawqhfynnddngldkgtslldrkq")
        XCTAssertEqual(prediction.version, version)
    }

    func testGetPrediction() async throws {
        let prediction = try await client.getPrediction("ufawqhfynnddngldkgtslldrkq")
        XCTAssertEqual(prediction.id, "ufawqhfynnddngldkgtslldrkq")
    }

    func testGetPredictions() async throws {
        let predictions = try await client.getPredictions()
        XCTAssertNil(predictions.previous)
        XCTAssertEqual(predictions.next, "cD0yMDIyLTAxLTIxKzIzJTNBMTglM0EyNC41MzAzNTclMkIwMCUzQTAw")
        XCTAssertEqual(predictions.results.count, 1)
    }

    func testGetModel() async throws {
        let model = try await client.getModel("replicate/hello-world")
        XCTAssertEqual(model.owner, "replicate")
        XCTAssertEqual(model.name, "hello-world")
    }

    func testGetModelVersions() async throws {
        let versions = try await client.getModelVersions("replicate/hello-world")
        XCTAssertNil(versions.previous)
        XCTAssertNil(versions.next)
        XCTAssertEqual(versions.results.count, 2)
        XCTAssertEqual(versions.results.first?.id, "5c7d5dc6dd8bf75c1acaa8565735e7986bc5b66206b55cca93cb72c9bf15ccaa")
    }

    func testGetModelVersion() async throws {
        let version = try await client.getModelVersion("replicate/hello-world", version: "5c7d5dc6dd8bf75c1acaa8565735e7986bc5b66206b55cca93cb72c9bf15ccaa")
        XCTAssertEqual(version.id, "5c7d5dc6dd8bf75c1acaa8565735e7986bc5b66206b55cca93cb72c9bf15ccaa")
    }


    func testGetModelCollection() async throws {
        let collection = try await client.getModelCollection(slug: "super-resolution")
        XCTAssertEqual(collection.slug, "super-resolution")
    }

    func testUnauthenticated() async throws {
        do {
            let _ = try await Client.unauthenticated.getPredictions()
            XCTFail("unauthenticated requests should fail")
        } catch {
            guard let error = error as? Replicate.Error else {
                return XCTFail("invalid error")
            }

            XCTAssertEqual(error.detail, "Invalid token.")
        }
    }
}

private extension Client {
    static var valid: Client {
        return Client(token: MockURLProtocol.validToken).mocked
    }

    static var unauthenticated: Client {
        return Client(token: "").mocked
    }

    private var mocked: Self {
        let configuration = session.configuration
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        return self
    }
}
