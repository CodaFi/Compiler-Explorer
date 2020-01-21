//
//  Endpoints.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Hammond

struct LanguagesRequest: GodBoltRequest {

  typealias Result = [Language]

  var path: String { "/api/languages" }

  static var method: HTTPMethod { .get }
}

struct CompilersRequest: GodBoltRequest {

  typealias Result = [Compiler]

  var language: Language?

  var path: String { "/api/compilers/\(language?.id ?? "")" }

  static var method: HTTPMethod { .get }
}

struct CompileSourceRequest: GodBoltRequest {

  typealias Result = Response

  var compiler: Compiler

  var source: Source

  var path: String { "/api/compiler/\(compiler.id)/compile" }

  static var method: HTTPMethod { .post }

  var body: Source { source }
}

struct ShortlinkInfoRequest: GodBoltRequest {

  typealias Result = SessionContainer

  var linkID: String

  var path: String { "/api/shortlinkinfo/\(linkID)" }

  static var method: HTTPMethod { .get }
}

struct ShortStringRequest: GodBoltRequest {

  typealias Result = Shortlink

  var compiler: Compiler

  var source: Source

  var path: String { "/shortener" }

  static var method: HTTPMethod { .post }

  var body: SessionContainer {
    let sessionCompiler = SessionContainer.SessionCompiler(id: compiler.id,
                                                           options: source.options.userArguments,
                                                           filters: source.options.filters,
                                                           libs: [],
                                                           specialoutputs: [],
                                                           tools: [])
    let session = SessionContainer.Session(id: 1,
                                           language: compiler.language,
                                           source: source.source,
                                           conformanceview: false,
                                           compilers: [sessionCompiler])
    return SessionContainer(sessions: [session])
  }
}
