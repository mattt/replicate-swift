import AnyCodable
import Foundation

/// Stable diffusion fork for generating tileable outputs
public enum MaterialStable_Diffusion: Predictable {
  public static let modelID = "tommoore515/material_stable_diffusion"

  public static let versionID = "3b5c0242f8925a4ab6c79b4c51e9b4ce6374e9b07b5e8461d89e692fd0faa449"

  public struct Input: Codable {
    /// Prompt
    /// Input prompt
    public var prompt: String?

    /// Width of output image. Maximum size is 1024x768 or 768x1024 because of memory limits
    public var width: AnyCodable?

    /// Height of output image. Maximum size is 1024x768 or 768x1024 because of memory limits
    public var height: AnyCodable?

    /// Init Image
    /// Inital image to generate variations of. Will be resized to the specified width and height
    public var initImage: URL?

    /// Mask
    /// Black and white image to use as mask for inpainting over init_image. Black pixels are inpainted and white pixels are preserved. Experimental feature, tends to work better with prompt strength of 0.5-0.7
    public var mask: URL?

    /// Prompt Strength
    /// Prompt strength when using init image. 1.0 corresponds to full destruction of information in init image
    public var promptStrength: Double?

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
      width: AnyCodable? = 512,
      height: AnyCodable? = 512,
      initImage: URL? = nil,
      mask: URL? = nil,
      promptStrength: Double? = 0.8,
      numOutputs: AnyCodable? = 1,
      numInference_steps: Int? = 50,
      guidanceScale: Double? = 7.5,
      seed: Int? = nil
    ) {
      self.prompt = prompt
      self.width = width
      self.height = height
      self.initImage = initImage
      self.mask = mask
      self.promptStrength = promptStrength
      self.numOutputs = numOutputs
      self.numInference_steps = numInference_steps
      self.guidanceScale = guidanceScale
      self.seed = seed
    }

    private enum CodingKeys: String, CodingKey {
      case prompt = "prompt"
      case width = "width"
      case height = "height"
      case initImage = "init_image"
      case mask = "mask"
      case promptStrength = "prompt_strength"
      case numOutputs = "num_outputs"
      case numInference_steps = "num_inference_steps"
      case guidanceScale = "guidance_scale"
      case seed = "seed"
    }
  }

  public typealias Output = [URL]
}
