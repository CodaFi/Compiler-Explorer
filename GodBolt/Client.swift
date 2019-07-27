//
//  Client.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import Foundation
import Combine

public final class Client {
  public static let shared = Client()

  private let defaultHost = "https://godbolt.org"
  private let confinementQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.name = "com.codafi.GodBolt.client"
    return queue
  }()
  private var session: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = [
      "ACCEPT": "application/json",
      "ContentType": "application/json",
    ]
    return URLSession(configuration: configuration)
  }()

  private init() {

  }

  public func requestLanguages() -> AnyPublisher<[Language], Error> {
    var request = URLRequest(url: endpointURL(self.defaultHost, "/api/languages"))
    request.httpMethod = "GET"
    return self.session.dataTaskPublisher(for: request)
      .map({ $0.0 })
      .decode(type: [Language].self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
  }

  public func requestCompilers(for language: Language? = nil) -> AnyPublisher<[Compiler], Error> {
    var request = URLRequest(url: endpointURL(self.defaultHost, "/api/compilers/\(language?.id ?? "")"))
    request.httpMethod = "GET"
    return self.session.dataTaskPublisher(for: request)
      .map({ $0.0 })
      .decode(type: [Compiler].self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
  }

  public func requestCompile(using compiler: Compiler, of source: Source) -> AnyPublisher<Response, Error> {
    var request = URLRequest(url: endpointURL(self.defaultHost, "/api/compiler/\(compiler.id)/compile"))
    request.httpMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.httpBody = try! JSONEncoder().encode(source)
    return self.session.dataTaskPublisher(for: request)
      .map({ $0.0 })
      .decode(type: Response.self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
  }

  public func requestShortlinkInfo(for linkID: String) -> AnyPublisher<SessionContainer, Error> {
    var request = URLRequest(url: endpointURL(self.defaultHost, "/api/shortlinkinfo/\(linkID)"))
    request.httpMethod = "GET"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    return self.session.dataTaskPublisher(for: request)
      .flatMap { (data, response) -> Result<Data, URLError>.Publisher in
        guard let httpResponse = response as? HTTPURLResponse else {
          return Result<Data, URLError>.failure(URLError(.badServerResponse)).publisher
        }
        guard httpResponse.statusCode == 200 else {
          return Result<Data, URLError>.failure(URLError(.badServerResponse)).publisher
        }
        return Result<Data, URLError>.success(data).publisher
      }
        .decode(type: SessionContainer.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
  }

//  public func requestShortString(using compiler: Compiler, of source: Source) -> AnyPublisher<Response, Error> {
//    var request = URLRequest(url: endpointURL(self.defaultHost, "/shortener"))
//    request.httpMethod = "POST"
//    request.httpBody = try! JSONEncoder().encode(source)
//    return self.session.dataTaskPublisher(for: request)
//      .map({ $0.0 })
//      .decode(type: Response.self, decoder: JSONDecoder())
//      .eraseToAnyPublisher()
//  }
}

private func endpointURL(_ base: String, _ route: String) -> URL {
  return URL(string: base + route)!
}
