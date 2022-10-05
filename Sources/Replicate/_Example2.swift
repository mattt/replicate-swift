import AnyCodable
import Foundation

/// Generate Pokémon from a text description
public enum TextToPokemon: Predictable {
  public static let modelID = "lambdal/text-to-pokemon"

  public static let versionID = "3554d9e699e09693d3fa334a79c58be9a405dd021d3e11281256d53185868912"

  public struct Input: Codable {
    /// Prompt
    /// Input prompt
    public var prompt: String?

    /// Number of images to output
    public var numOutputs: AnyCodable?

    /// Num Inference Steps
    /// Number of denoising steps
    public var numInference_steps: Int?

    /// Guidance Scale
    /// Scale for classifier-free guidance
    public var guidanceScale: Double?

    /// Seed
    /// Random seed. Leave blank to randomize the seed
    public var seed: Int?

    public init(
      prompt: String? = "",
      numOutputs: AnyCodable? = 1,
      numInference_steps: Int? = 25,
      guidanceScale: Double? = 7.5,
      seed: Int? = nil
    ) {
      self.prompt = prompt
      self.numOutputs = numOutputs
      self.numInference_steps = numInference_steps
      self.guidanceScale = guidanceScale
      self.seed = seed
    }

    private enum CodingKeys: String, CodingKey {
      case prompt = "prompt"
      case numOutputs = "num_outputs"
      case numInference_steps = "num_inference_steps"
      case guidanceScale = "guidance_scale"
      case seed = "seed"
    }
  }

  public typealias Output = [URL]
}
