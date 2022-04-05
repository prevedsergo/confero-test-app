//
//  PinViewController.swift
//  TestApp
//
//  Created by Sergey Kononov on 04/04/2022.
//

import UIKit
import LocalAuthentication


protocol PinViewControllerDelegate: AnyObject {
    func pinViewControllerVerifySuccess(_ controller: PinViewController)
}
    

class PinViewController: UIViewController {
    
    enum ButtonImageType {
        case backSpace
    }
    
    @IBOutlet private var messageLabel: UILabel!
    @IBOutlet private var pinStackView: UIStackView!
    @IBOutlet private var deleteButton: UIButton!
    
    weak var delegate: PinViewControllerDelegate?
    var newPin: String = ""
    
    private let validCode = "1111"
    private let pinLength = 4
    private var pin: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        deleteButton.setImage(buttonImageType(.backSpace), for: .normal)
        deleteButton.isHidden = false
    }
    
    // MARK: - Private
    
    private func buttonImageType(_ type: ButtonImageType) -> UIImage? {
        var image: UIImage?
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large)
        
        switch type {
        case .backSpace:
            image = UIImage(systemName: "delete.left", withConfiguration: largeConfig)
        }
        return image
    }
    
    private func refreshPinView() {
        guard pinStackView.arrangedSubviews.count == pinLength else {
            NSLog("[PinViewController]: refreshPinView(): arrangedSubviews.count is not match to pinLength")
            return
        }
        
        for index in 0 ..< pinLength {
            let imageView = pinStackView.arrangedSubviews[index] as! UIImageView
            imageView.tintColor = .white
            imageView.image = index < pin.count ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
        }
    }
    
    @objc private func pinAction() {
        if pin != validCode {
            perform(#selector(clearPin), with: nil, afterDelay: 0.3)
        } else {
            delegate?.pinViewControllerVerifySuccess(self)
        }

    }
    
    @objc func clearPin() {
        pin = ""
        refreshPinView()
    }
    
    // MARK: - Actions
        
    @IBAction private func digitTouched(_ sender: UIButton) {
        guard pin.count < pinLength else {
            NSLog("[PinViewController]: digitTouched(): pin.count == pinLength")
            return
        }
        
        pin += sender.title(for: .normal) ?? ""
        refreshPinView()
        
        if pin.count == pinLength {
            perform(#selector(pinAction), with: nil, afterDelay: 0.4)
        }
    }
    
    @IBAction private func deleteDigit(_ sender: UIButton) {
        guard !pin.isEmpty else {
            NSLog("[PinViewController]: deleteDigit(): pin is empty")
            return
        }
        
        pin.removeLast()
        refreshPinView()
    }
}
