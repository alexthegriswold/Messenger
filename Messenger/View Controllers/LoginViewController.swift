//
//  LoginViewController.swift
//  Messenger
//
//  Created by Melinda Griswold on 8/27/18.
//  Copyright © 2018 com.MobilePic. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let authenticator = UserAuthenticator()
    
    //MARK: Views
    let formView: FormView = {
        let view = FormView(frame: .zero, type: .login)
        return view
    }()
    
    let grayOutView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.alpha = 0.0
        return view
    }()
    
    //MARK: View Controller override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set attributes
        title = "Login"
        
        //set views
        formView.forgotPasswordDelegate = self
        formView.formViewDelegate = self
        formView.frame = view.frame
        grayOutView.frame = view.frame
        [formView, grayOutView].forEach { view.addSubview($0) }
        
        //navbar
        //setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let formInput = formView.formInputs.first else { return }
        formInput.textField.becomeFirstResponder()
        
        for formInput in formView.formInputs {
            formInput.textField.text?.removeAll()
        }
        
        formView.setSubmitButton(to: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension LoginViewController: ForgotPasswordViewDelegate {
    func didTapForgotPassword() {
        self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
    }
}

extension LoginViewController: FormViewDelegate {
    func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didTapSubmit(formEntries: [String]) {
        
        let username = formEntries[0].lowercased()
        let password = formEntries[1]
        
        let (success, response, user) = authenticator.authenticate(password: password, for: username)
        
        if success {
            let messengerViewController = MessengerViewController(collectionViewLayout: UICollectionViewFlowLayout(), user: user!)
            let navigationController = UINavigationController(rootViewController: messengerViewController)
            self.present(navigationController, animated: true, completion: nil)
        } else {
            self.view.endEditing(true)
            self.grayOutView.alpha = 0.5
    
            let alertMessage = authenticator.createLoginStringResponse(for: response)
            let viewModel = AlertViewModel(title: "Whoops!", subtitle: alertMessage, buttonTitle: "Ok")
            let viewController = AlertViewController(viewModel: viewModel)
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: AlertViewControllerDelegate {
    
    func alertIsDismissing() {
        UIView.animate(withDuration: 0.4) {
            self.grayOutView.alpha = 0.0
        }
    }
    
    func alertDidDismiss() {
        
    }
}

extension LoginViewController: LoadingViewControllerDelegate {
    func loadingTimedOut() {
        
        let viewModel = AlertViewModel(title: "Bad Connection", subtitle: "We were unable to sign you in. Please try again later.", buttonTitle: "Ok")
        let viewController = AlertViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.delegate = self
        self.present(viewController, animated: false, completion: nil)
    }
}
