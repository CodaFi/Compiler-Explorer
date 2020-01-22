//
//  NetworkActivityIndicatorPublisher.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 22.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Combine
import Foundation

/// A network activity indicator publisher with reference counter.
/// `startActivity()` increments the counter, `stopActivity()` decrements it.
/// If the counter changes from 0 to 1, publishes `true`. If the counter changes from 1 to 0,
/// publishes `false`.
public final class NetworkActivityIndicatorPublisher: Publisher {

  public typealias Output = Bool

  public typealias Failure = Never

  private let lock = NSRecursiveLock()

  private let subject = CurrentValueSubject<Bool, Never>(false)

  private var counter: UInt = 0

  /// Increments the reference count. If the reference count was zero, publishes `true`.
  func startActivity() {
    lock.lock()
    defer { lock.unlock() }
    counter += 1
    if counter == 1 {
      subject.send(true)
    }
  }

  /// Decrements the reference count. If the reference count became zero, publishes `false`.
  func stopActivity() {
    lock.lock()
    defer { lock.unlock() }
    guard counter > 0 else {
      return
    }
    counter -= 1
    if counter == 0 {
      subject.send(false)
    }
  }

  public func receive<Downstream: Subscriber>(subscriber: Downstream)
    where Downstream.Input == Output, Downstream.Failure == Failure
  {
    subject.subscribe(subscriber)
  }
}
