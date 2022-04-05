//
//  RootViewController.swift
//  TestApp
//
//  Created by Sergey Kononov on 04/04/2022.
//

import UIKit


class RootViewController: UIViewController {
    private var currentController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pinController = PinViewController(nibName: "PinViewController", bundle: nil)
        pinController.delegate = self
        currentController = pinController
        
        addChild(currentController)
        currentController.view.frame = view.bounds
        view.addSubview(currentController.view)
        currentController.didMove(toParent: self)
    }
    
    // MARK: - Root navigation public methods
    
    func switchToMainScreen() {
        let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController")
        animateFadeTransition(to: mainController)
    }
    
    func switchToPinScreen() {
        let pinController = PinViewController(nibName: "PinViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: pinController)
        animateFadeTransition(to: navController)
    }
    
    // MARK: - Private
    
    private func animateTransition(_ animation: UIView.AnimationOptions, to newController: UIViewController, completion: (() -> Void)? = nil) {
        newController.view.frame = view.bounds
        currentController.willMove(toParent: nil)
        addChild(newController)

        transition(from: currentController, to: newController, duration: 0.3, options: [animation, .curveEaseOut], animations: {}) { [weak self] completed in
            self?.currentController.removeFromParent()
            newController.didMove(toParent: self)
            self?.currentController = newController
            completion?()
        }
    }
    
    private func animateFadeTransition(to newController: UIViewController, completion: (() -> Void)? = nil) {
        animateTransition(.transitionCrossDissolve, to: newController, completion: completion)
    }
}

// MARK: - PinViewControllerDelegate

extension RootViewController: PinViewControllerDelegate {
    func pinViewControllerVerifySuccess(_ controller: PinViewController) {
        switchToMainScreen()
    }
}
