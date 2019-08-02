//
//  PageControl.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/2/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    class Coordinator: NSObject {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }

        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

#if DEBUG
struct PageControl_Previews: PreviewProvider {
    static var previews: some View {
      PageControl(numberOfPages: 2, currentPage: .constant(0))
    }
}
#endif
