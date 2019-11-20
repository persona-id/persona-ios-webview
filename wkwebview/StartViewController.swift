//
//  StartViewController.swift
//  wkwebview
//
//  Created by Paulo Fierro on 20/11/19.
//  Copyright © 2019 Persona Identities Inc. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    /// Handle button taps.
    @IBAction func handleButtonTap(_ sender: Any) {
        let viewController = PersonaViewController()
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
}

extension StartViewController: PersonaViewControllerDelegate {

    /// Handle a successful verification.
    func verificationSucceeded(viewController: PersonaViewController, inquiryId: String) {
        viewController.dismiss(animated: true, completion: nil)
        print("Verification succeeded with inquiryId: \(inquiryId)")
    }

    /// Handle a failed verification.
    func verificationFailed(viewController: PersonaViewController) {
        viewController.dismiss(animated: true, completion: nil)
        print("Verification failed")
    }
}
