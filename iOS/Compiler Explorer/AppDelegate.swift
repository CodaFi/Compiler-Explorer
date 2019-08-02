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
  @Published var selectedLanguage: Language? = nil {
    willSet {
      self.objectWillChange.send()
    }
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      window.rootViewController = DocumentBrowserViewController()
    case .phone:
      window.rootViewController = UIHostingController(rootView: DocumentTemplateView(chosen: self[\.selectedLanguage]))
    default:
      fatalError()
    }
    self.window = window
    window.makeKeyAndVisible()
    self.languageCancellable = self.$selectedLanguage.sink { value in
      guard let value = value else {
        return
      }
      self.dismisssForLanguageChange(language: value)
    }
    return true
  }

  func dismisssForLanguageChange(language: Language) {
    window?.rootViewController?.presentedViewController?.dismiss(animated: true)
    let newName = "temp" + language.id

    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(newName)
    let doc = Document(fileURL: url, language: language)
    doc.save(to: url, for: .forCreating) { (_) in
      doc.close(completionHandler: { (_) in
      })
    }

    let documentViewController = DocumentViewController(document: doc)
    window?.rootViewController?.present(documentViewController, animated: true, completion: nil)
  }


  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }



}

