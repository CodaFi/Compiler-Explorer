//
//  PageViewController.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import UIKit

private func pageViewControllerOptions(for idiom: UIUserInterfaceIdiom) -> UIPageViewController {
  switch idiom {
  case .pad:
    return UIPageViewController(
      transitionStyle: .pageCurl,
      navigationOrientation: .horizontal,
      // OK, this one's the worst API now.
      options: [ .spineLocation : NSNumber(value: UIPageViewController.SpineLocation.mid.rawValue) ])
  case .phone:
        return UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal)
  default:
    fatalError()
  }
}

struct PageViewController: UIViewControllerRepresentable {
  let controllers: [UIViewController]
  @Binding var currentPage: Int

  init(controllers: [UIViewController], currentPage: Binding<Int>) {
    self.controllers = controllers
    self._currentPage = currentPage
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(controllers: self.controllers, currentPage: self.$currentPage)
  }

  func makeUIViewController(context: Context) -> UIPageViewController {
    let pageViewController = pageViewControllerOptions(for: UIDevice.current.userInterfaceIdiom)
    pageViewController.dataSource = context.coordinator
    pageViewController.delegate = context.coordinator
    pageViewController.isDoubleSided = UIDevice.current.userInterfaceIdiom == .pad
    return pageViewController
  }

  func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      pageViewController.setViewControllers(self.controllers, direction: .forward, animated: false)
    case .phone:
      pageViewController.setViewControllers([self.controllers[self.currentPage]], direction: .forward, animated: true)
    default:
      fatalError()
    }
  }

  class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let controllers: [UIViewController]
    @Binding var currentPage: Int

    init(controllers: [UIViewController], currentPage: Binding<Int>) {
      self.controllers = controllers
      self._currentPage = currentPage
    }

    // FIXME: This is never called? Documentation is a lie.
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
      switch UIDevice.current.userInterfaceIdiom {
      case .pad:
        return .mid
      case .phone:
        return .min
      default:
        fatalError()
      }
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerBefore viewController: UIViewController) -> UIViewController? {
      guard let index = self.controllers.firstIndex(of: viewController) else {
        return nil
      }
      if index == 0 {
        return nil
      }
      return self.controllers[index - 1]
    }

    func pageViewController(
      _ pageViewController: UIPageViewController,
      viewControllerAfter viewController: UIViewController) -> UIViewController? {
      guard let index = self.controllers.firstIndex(of: viewController) else {
        return nil
      }
      if index + 1 == self.controllers.count {
        return nil
      }
      return self.controllers[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
      if completed,
        let visibleViewController = pageViewController.viewControllers?.first,
        let index = self.controllers.firstIndex(of: visibleViewController) {
        self.currentPage = index
      }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
      return self.controllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
      return 0
    }
  }
}

#if DEBUG
struct PageViewController_Previews: PreviewProvider {
  static var previews: some View {
    PageViewController(controllers: [ ], currentPage: .constant(0))
  }
}
#endif
