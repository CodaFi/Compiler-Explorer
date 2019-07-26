//
//  Source.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

public struct Source: Codable {
  public struct Options: Codable {
    public struct Filter: OptionSet {
      public let rawValue: Int32

      public init(rawValue: Int32) {
        self.rawValue = rawValue
      }

      public static let intel       = Filter(rawValue: 1 << 0)
      public static let demangle    = Filter(rawValue: 1 << 1)
      public static let directives  = Filter(rawValue: 1 << 2)
      public static let comments    = Filter(rawValue: 1 << 3)
      public static let labels      = Filter(rawValue: 1 << 4)
      public static let trim        = Filter(rawValue: 1 << 5)

      public enum CodingKeys: String, CodingKey {
        case intel
        case demangle
        case directives
        case comments
        case labels
        case trim
      }
    }

    public let userArguments: String
    public let filters: Filter

    public init(arguments: String, filters: Filter) {
      self.userArguments = arguments
      self.filters = filters
    }
  }


  public let source: String
  public let options: Options

  public init(source: String, options: Options) {
    self.source = source
    self.options = options
  }
}

extension Source.Options.Filter: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.contains(.intel), forKey: .intel)
    try container.encode(self.contains(.demangle), forKey: .demangle)
    try container.encode(self.contains(.directives), forKey: .directives)
    try container.encode(self.contains(.comments), forKey: .comments)
    try container.encode(self.contains(.labels), forKey: .labels)
    try container.encode(self.contains(.trim), forKey: .trim)
  }
}

extension Source.Options.Filter: Decodable {
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    var set = Source.Options.Filter(rawValue: 0)
    if try values.decode(Bool.self, forKey: .intel) {
      set.formUnion(.intel)
    }
    if try values.decode(Bool.self, forKey: .demangle) {
      set.formUnion(.demangle)
    }
    if try values.decode(Bool.self, forKey: .directives) {
      set.formUnion(.directives)
    }
    if try values.decode(Bool.self, forKey: .comments) {
      set.formUnion(.comments)
    }
    if try values.decode(Bool.self, forKey: .labels) {
      set.formUnion(.labels)
    }
    if try values.decode(Bool.self, forKey: .trim) {
      set.formUnion(.trim)
    }
    self.rawValue = set.rawValue
  }
}
