//
//  EmbeddingObject.swift
//
//
//  Created by James Rochabrun on 10/12/23.
//

import Foundation

/// [Represents an embedding vector returned by embedding endpoint.](https://platform.openai.com/docs/api-reference/embeddings/object)
struct EmbeddingObject: Decodable {
   
   /// The object type, which is always "embedding".
   let object: String
   /// The embedding vector, which is a list of floats. The length of vector depends on the model as listed in the embedding guide.[https://platform.openai.com/docs/guides/embeddings]
   let embedding: [Float]
   /// The index of the embedding in the list of embeddings.
   let index: Int
}
