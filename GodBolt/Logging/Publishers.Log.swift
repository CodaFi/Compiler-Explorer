//
//  Publishers.OSLog.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Combine
import Logging

extension Publisher {
  public func log(_ logger: Logger,
                  level: Logger.Level,
                  formatOutput: @escaping (Output) -> Logger.Message,
                  formatFailure: @escaping (Failure) -> Logger.Message,
                  metadata: Logger.Metadata? = nil) -> Publishers.Log<Self> {
    .init(upstream: self,
          logger: logger,
          level: level,
          metadata: metadata,
          formatOutput: formatOutput,
          formatFailure: formatFailure)
  }
}

extension Publishers {
  public struct Log<Upstream: Publisher>: Publisher {

    public typealias Output = Upstream.Output

    public typealias Failure = Upstream.Failure

    public let upstream: Upstream

    public let logger: Logger

    public let level: Logger.Level

    public let metadata: Logger.Metadata?

    public let formatOutput: (Upstream.Output) -> Logger.Message

    public let formatFailure: (Upstream.Failure) -> Logger.Message

    public func receive<Downstream: Subscriber>(subscriber: Downstream)
      where Downstream.Input == Output, Downstream.Failure == Failure
    {
      upstream.handleEvents(
        receiveOutput: { output in
          self.logger.log(level: self.level, self.formatOutput(output), metadata: self.metadata)
        },
        receiveCompletion: { completion in
          if case let .failure(error) = completion {
            self.logger.log(level: self.level, self.formatFailure(error), metadata: self.metadata)
          }
        }
      ).subscribe(subscriber)
    }
  }
}
