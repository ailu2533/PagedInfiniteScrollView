import SwiftUI
import UIKit

public class CustomPageViewController: UIPageViewController {
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

public struct PagedInfiniteScrollView<S: Steppable & Comparable, Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = CustomPageViewController

    let content: (S) -> Content
    @Binding var currentPage: S

    public init(content: @escaping (S) -> Content, currentPage: Binding<S>) {
        self.content = content
        _currentPage = currentPage
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> CustomPageViewController {
        let pageViewController = CustomPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        let initialViewController = UIHostingController(rootView: IdentifiableContent(index: currentPage, content: { content(currentPage) }))

        initialViewController.view.backgroundColor = .clear

        pageViewController.setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)

        return pageViewController
    }

    public func updateUIViewController(_ uiViewController: CustomPageViewController, context: Context) {
        let currentViewController = uiViewController.viewControllers?.first as? UIHostingController<IdentifiableContent<Content, S>>
        let currentIndex = currentViewController?.rootView.index ?? .origin

        if currentPage != currentIndex {
            let direction: UIPageViewController.NavigationDirection = currentPage > currentIndex ? .forward : .reverse
            let newViewController = UIHostingController(rootView: IdentifiableContent(index: currentPage, content: { content(currentPage) }))
            newViewController.view.backgroundColor = .clear

            uiViewController.setViewControllers([newViewController], direction: direction, animated: true, completion: nil)
        }
    }

    public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PagedInfiniteScrollView

        init(_ parent: PagedInfiniteScrollView) {
            self.parent = parent
        }

        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let currentView = viewController as? UIHostingController<IdentifiableContent<Content, S>>, let currentIndex = currentView.rootView.index as S? else {
                return nil
            }

            guard let previousIndex = currentIndex.backward() else {
                return nil
            }

            let newViewController = UIHostingController(rootView: IdentifiableContent(index: previousIndex, content: { parent.content(previousIndex) }))
            newViewController.view.backgroundColor = .clear

            return newViewController
        }

        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let currentView = viewController as? UIHostingController<IdentifiableContent<Content, S>>, let currentIndex = currentView.rootView.index as S? else {
                return nil
            }

            guard let nextIndex = currentIndex.forward() else {
                return nil
            }

            let newViewController = UIHostingController(rootView: IdentifiableContent(index: nextIndex, content: { parent.content(nextIndex) }))
            newViewController.view.backgroundColor = .clear

            return newViewController
        }

        public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
               let currentView = pageViewController.viewControllers?.first as? UIHostingController<IdentifiableContent<Content, S>>,
               let currentIndex = currentView.rootView.index as S? {
                parent.currentPage = currentIndex
            }
        }
    }
}

public struct IdentifiableContent<Content: View, S: Steppable>: View {
    let index: S
    let content: Content

    public init(index: S, @ViewBuilder content: () -> Content) {
        self.index = index
        self.content = content()
    }

    public var body: some View {
        content
    }
}
