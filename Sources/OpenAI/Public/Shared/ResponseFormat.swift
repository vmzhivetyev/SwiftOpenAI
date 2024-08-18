//
//  ResponseFormat.swift
//  
//
//  Created by James Rochabrun on 4/13/24.
//

import Foundation


/// Defaults to text
/// Setting to `json_object` enables JSON mode. This guarantees that the message the model generates is valid JSON.
/// Note that your system prompt must still instruct the model to produce JSON, and to help ensure you don't forget, the API will throw an error if the string JSON does not appear in your system message.
/// Also note that the message content may be partial (i.e. cut off) if `finish_reason="length"`, which indicates the generation exceeded max_tokens or the conversation exceeded the max context length.
/// Must be one of `text `or `json_object`.
public enum ResponseFormat: Codable {
   case auto
   case type(String)
    /**
     To use Structured Outputs, simply specify

     `response_format: { "type": "json_schema", "json_schema": … , "strict": true }`
     */
    case structuredOutput(schema: JSONSchema)

   enum CodingKeys: String, CodingKey {
       case type = "type"
       case json_schema = "json_schema"
   }
    
    public struct JSONSchema: Encodable {
        let name: String
        let schema: any Encodable
        let strict: Bool
        
        enum CodingKeys: String, CodingKey {
            case name
            case schema
            case strict
        }
        
        public init(name: String, schema: any Encodable, strict: Bool = true) {
            self.name = name
            self.schema = schema
            self.strict = strict
        }
        
        public func encode(to encoder: any Encoder) throws {
            if let jsonEncoder = encoder as? JSONEncoder {
                if !jsonEncoder.outputFormatting.contains(.sortedKeys) {
                    assertionFailure()
                    jsonEncoder.outputFormatting = jsonEncoder.outputFormatting.union(.sortedKeys)
                }
            }
            var container = encoder.container(keyedBy: JSONSchema.CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(schema, forKey: .schema)
            try container.encode(strict, forKey: .strict)
        }
    }

   public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      switch self {
      case .auto:
         try container.encode("text", forKey: .type)
      case .type(let responseType):
         try container.encode(responseType, forKey: .type)
      case .structuredOutput(let schema):
          try container.encode("json_schema", forKey: .type)
          try container.encode(schema, forKey: .json_schema)
      }
   }

   public init(from decoder: Decoder) throws {
      // Handle the 'type' case:
      if let container = try? decoder.container(keyedBy: CodingKeys.self),
         let responseType = try? container.decode(String.self, forKey: .type) {
         self = .type(responseType)
         return
      }

      // Handle the 'auto' case:
      let container = try decoder.singleValueContainer()
      switch try container.decode(String.self) {
      case "auto":
         self = .auto
      default:
         throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid response_format structure")
      }
   }
}
