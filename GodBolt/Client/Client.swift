//
//  Client.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import Combine
import Foundation
import Hammond
import Logging

public final class Client {

  public static let shared = Client()

  private let defaultHost = URL(string: "https://godbolt.org")!

  private let logger: Logger = {
    var logger = Logger(label: "com.codafi.GodBolt.client")
    logger.logLevel = .trace
    return logger
  }()

  public let networkActivityIndicator = NetworkActivityIndicatorPublisher()

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

  private func urlRequest<Request: GodBoltRequest>(for request: Request) -> URLRequest {
    var urlRequest = URLRequest(url: defaultHost.appendingPathComponent(request.path))
    urlRequest.httpMethod = Request.method.rawValue
    urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    return urlRequest
  }

  private func performHTTPRequest<Request: GodBoltRequest>(
    _ request: Request
  ) -> AnyPublisher<Request.Result, Error> {
    logger.trace("Performing HTTP request:\n\(urlRequest(for: request))")
    networkActivityIndicator.startActivity()
    return session
      .dataTaskPublisher(for: urlRequest(for: request))
      .handleEvents(receiveCompletion: { _ in self.networkActivityIndicator.stopActivity() },
                    receiveCancel: { self.networkActivityIndicator.stopActivity() })
      .log(logger,
           level: .trace,
           formatOutput: { "\n\(prettyPrintJSON($0.data))" },
           formatFailure: { "Request failed: \($0.localizedDescription)" })
      .mapError { $0 as Error }
      .tryMap { data, response -> RawResponse in
        guard let response = response as? HTTPURLResponse else {
          throw URLError(.badServerResponse)
        }
        return RawResponse(body: data, statusCode: HTTPStatusCode(rawValue: response.statusCode))
      }.tryMap(Request.extractResult)
      .eraseToAnyPublisher()
  }

  public func requestLanguages() -> AnyPublisher<[Language], Error> {
    performHTTPRequest(LanguagesRequest())
  }

  public func requestCompilers(for language: Language? = nil) -> AnyPublisher<[Compiler], Error> {
    performHTTPRequest(CompilersRequest(language: language))
  }

  public func requestCompile(using compiler: Compiler,
                             of source: Source) -> AnyPublisher<Response, Error> {
    performHTTPRequest(CompileSourceRequest(compiler: compiler, source: source))
  }

  public func requestShortlinkInfo(for linkID: String) -> AnyPublisher<SessionContainer, Error> {
    performHTTPRequest(ShortlinkInfoRequest(linkID: linkID))
  }

  public func requestShortString(using compiler: Compiler,
                                 of source: Source) -> AnyPublisher<Shortlink, Error> {
    performHTTPRequest(ShortStringRequest(compiler: compiler, source: source))
  }
}

private func prettyPrintJSON(_ data: Data) -> String {
  let result: Data
  do {
    let json = try JSONSerialization.jsonObject(with: data)
    result = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
  } catch {
    result = data
  }
  return String(decoding: result, as: UTF8.self)
}
