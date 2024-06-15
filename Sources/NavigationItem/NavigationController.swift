//
//  NavigationController.swift
//  SwiftUI-NavigationItem
//
//  Created by Aswath Narayanan on 15/06/24.
//

import SwiftUI

extension View {
    /// Access the NavigationController of the underlying `UINavigationController`
    ///
    /// Please attach `navigationController()` or `navigationController(customize:)` to your `NavigationView` or simply use `NavigationItemView`
    /// This will expose the underlying `UINavigationController` in the `Environment` for easier
    /// access.
    ///
    /// While the `NavigationController` will still be found without this, it may be delayed or glitchy without this in certain situations.
    ///
    /// - Parameter animated: Pass `true` to animate the customization; otherwise, pass `false`. Defaults to `true`
    /// - Parameter customize: Callback with the found `UINavigationController`
    public func navigationController(animated: Bool = true, customize: @escaping (UINavigationController) -> Void) -> some View {
        modifier(NavigationControllerModifier_1(animated: animated, customize: customize))
    }
}

extension NavigationView {
    /// Access the NavigationController of the underlying `UINavigationController` and expose it in the `Environment`
    ///
    /// - Parameter animated: Pass `true` to animate the customization; otherwise, pass `false`. Defaults to `true`
    /// - Parameter customize: Callback with the found `UINavigationController`
    ///
    /// This is needed on the `NavigationView` in order to be able to expose the `UINavigationController` to all subviews
    public func navigationController(animated: Bool = true, customize: @escaping ((UINavigationController) -> Void)) -> some View {
        modifier(NavigationControllerModifier_1(animated: animated, customize: customize, forceEnvironment: true))
    }
    
    /// Expose the the NavigationController of the underlying `UINavigationController` in the `Environment`
    ///
    /// While not strictly necessary to expose the the underlying `UINavigationController`
    /// in the `Environment` it is advised to do so as it heavily simplifies finding the `UINavigationController`. Without exposure accessing the NavigationController might be slightly
    /// delayed and may cause glitches.
    ///
    /// This is needed on the `NavigationView` in order to be able to expose the `UINavigationController` to all subviews
    public func navigationController() -> some View {
        modifier(NavigationControllerModifier_1(animated: false, customize: nil, forceEnvironment: true))
    }
}

#if swift(>=5.7)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension NavigationStack {
    /// Access the NavigationController of the underlying `UINavigationController` and expose it in the `Environment`
    ///
    /// - Parameter animated: Pass `true` to animate the customization; otherwise, pass `false`. Defaults to `true`
    /// - Parameter customize: Callback with the found `UINavigationController`
    ///
    /// This is needed on the `NavigationView` in order to be able to expose the `UINavigationController` to all subviews
    public func navigationController(animated: Bool = true, customize: @escaping ((UINavigationController) -> Void)) -> some View {
        modifier(NavigationControllerModifier_1(animated: animated, customize: customize, forceEnvironment: true))
    }
    
    /// Expose the the NavigationController of the underlying `UINavigationController` in the `Environment`
    ///
    /// While not strictly necessary to expose the the underlying `UINavigationController`
    /// in the `Environment` it is advised to do so as it heavily simplifies finding the `UINavigationController`. Without exposure accessing the NavigationController might be slightly
    /// delayed and may cause glitches.
    ///
    /// This is needed on the `NavigationStack` in order to be able to expose the `UINavigationController` to all subviews
    public func navigationController() -> some View {
        modifier(NavigationControllerModifier_1(animated: false, customize: nil, forceEnvironment: true))
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension NavigationSplitView {
    /// Access the NavigationController of the underlying `UINavigationController` and expose it in the `Environment`
    ///
    /// - Parameter animated: Pass `true` to animate the customization; otherwise, pass `false`. Defaults to `true`
    /// - Parameter customize: Callback with the found `UINavigationController`
    ///
    /// This is needed on the `NavigationView` in order to be able to expose the `UINavigationController` to all subviews
    public func navigationController(animated: Bool = true, customize: @escaping ((UINavigationController) -> Void)) -> some View {
        modifier(NavigationControllerModifier_1(animated: animated, customize: customize, forceEnvironment: true))
    }
    
    /// Expose the the NavigationController of the underlying `UINavigationController` in the `Environment`
    ///
    /// While not strictly necessary to expose the the underlying `UINavigationController`
    /// in the `Environment` it is advised to do so as it heavily simplifies finding the `UINavigationController`. Without exposure accessing the NavigationController might be slightly
    /// delayed and may cause glitches.
    ///
    /// This is needed on the `NavigationSplitView` in order to be able to expose the `UINavigationController` to all subviews
    public func navigationController() -> some View {
        modifier(NavigationControllerModifier_1(animated: false, customize: nil, forceEnvironment: true))
    }
}
#endif

struct NavigationControllerModifier_1: ViewModifier {
    var animated: Bool
    let customize: ((UINavigationController) -> Void)?
    var forceEnvironment = false

    @Environment(\.navigationController) var navigationController
    @State private var holder: UINavigationController?
    
    func body(content: Content) -> some View {
        if !forceEnvironment, let navigationController = navigationController {
            content
                .onAppear {
                    DispatchQueue.main.async {
                        customize(navigationController: navigationController)
                    }
                }
                .animation(.default, value: forceEnvironment)
        } else {
            content
                .overlay(overlay)
                .environment(\.navigationController, holder)
        }
    }
    
    private func customize(navigationController: UINavigationController) {
        if animated {
            UIView.animate(withDuration: 0.35) {
                customize?(navigationController)
            }
        } else {
            customize?(navigationController)
        }
    }
    
    var overlay: some View {
        FindNavigationController {
            holder = $0
            customizeOverlay()
        }
        .frame(width: 0, height: 0)
        .onAppear {
            customizeOverlay()
        }
    }
    
    
    func customizeOverlay() {
        DispatchQueue.main.async {
            guard let navController = holder else { return }
            customize(navigationController: navController)
        }
    }
}
