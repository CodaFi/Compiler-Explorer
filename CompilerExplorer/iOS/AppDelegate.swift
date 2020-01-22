//
//  AppDelegate.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import GodBolt

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject, Identifiable {

  var window: UIWindow?

  var languageCancellable: AnyCancellable? = nil
  @Published var selectedLanguage: Language? = nil

  private let client = Client()

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    window.makeKeyAndVisible()
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      window.rootViewController = DocumentBrowserViewController(client: client)
      self.languageCancellable = self.$selectedLanguage.sink { lang in
        guard let lang = lang else {
          return
        }
        self.dismisssForLanguageChange(language: lang)
      }
    case .phone:
      let vm = GotoShortlinkViewModel(client: client)
      window.rootViewController = UIHostingController(
        rootView: DocumentTemplateView(
          chosen: Binding(get: { self.selectedLanguage },
                          set: { self.selectedLanguage = $0 }),
          viewModel: .init(client: client)
      ).environmentObject(vm))
      self.languageCancellable = self.$selectedLanguage
        .combineLatest(vm.shortlinkValue)
        .receive(on: DispatchQueue.main)
        .sink { values in
          switch values {
          case (nil, nil):
            return
          case let (nil, session?):
            self.dismisssForSessionChange(session: session)
          case let (lang?, nil):
            self.dismisssForLanguageChange(language: lang)
          case (_?, _?):
            fatalError("Wat?")
          }
        }
    default:
      fatalError()
    }
    return true
  }

  func dismisssForLanguageChange(language: Language) {
    window?.rootViewController?.presentedViewController?.dismiss(animated: true)
    let newName = "temp.\(ExtensionManager.fileExtension(for: language))"

    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(newName)
    let doc = Document(fileURL: url)
    doc.save(to: url, for: .forCreating) { (_) in
      doc.close(completionHandler: { (_) in
      })
    }

    let documentViewController = DocumentViewController(document: doc, client: client)
    window?.rootViewController?.present(documentViewController, animated: true, completion: nil)
  }

  func dismisssForSessionChange(session: SessionContainer) {
    window?.rootViewController?.presentedViewController?.dismiss(animated: true)
    guard let session = session.sessions.first else {
      // FIXME: Error handling
      return
    }
    guard let compiler = session.compilers.first else {
      // FIXME: Error handling
      return
    }
    let newName = "temp.\(session.language)"

    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(newName)
    let doc = Document(fileURL: url)
    doc.save(to: url, for: .forCreating) { (_) in
      doc.close(completionHandler: { (_) in
      })
    }

    let documentViewController = DocumentViewController(document: doc, client: client)
    window?.rootViewController?.present(documentViewController, animated: true, completion: nil)
    documentViewController.loadSession(session, compiler: compiler)
  }
}
