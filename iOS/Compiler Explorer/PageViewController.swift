//
//  PageViewController.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import UIKit

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
    let pageViewController = UIPageViewController(
      transitionStyle: .scroll,
      navigationOrientation: .horizontal)
    pageViewController.dataSource = context.coordinator
    pageViewController.delegate = context.coordinator

    return pageViewController
  }

  func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
    pageViewController.setViewControllers([self.controllers[self.currentPage]], direction: .forward, animated: true)
  }

  class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    let controllers: [UIViewController]
    @Binding var currentPage: Int

    init(controllers: [UIViewController], currentPage: Binding<Int>) {
      self.controllers = controllers
      self._currentPage = currentPage
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
  }
}

#if DEBUG
struct PageViewController_Previews: PreviewProvider {
  static var previews: some View {
    PageViewController(controllers: [ ], currentPage: .constant(0))
  }
}
#endif
