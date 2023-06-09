//
//  LoginViewController.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 25/01/2023.
//

import Foundation
import UIKit
import Combine

class LoginViewModel {
    @Published var user: Result<User,UserControllerErrors>? =  nil

    var cancellables = Set<AnyCancellable>()
    var controller:UserController? {
        didSet(value) {
            value != nil ? bind(controller: value!) : nil
        }
    }
    
    func loginUser(username:String, pword:String) {
        controller?.login(username: "", pword: "")
    }
    
    func bind(controller:UserController) {
        controller.user.compactMap{$0}.asResult().map { result in result.map { $0.0} }
        .assign(to: &self.$user)
    }
}


class LoginViewController: UIViewController {
    
    var userNameInput: UITextField!
    var passwordInput: UITextField!
    var submitButton: UIButton!
    
    var viewModel: LoginViewModel?

    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        
        userNameInput = UITextField()
        userNameInput.translatesAutoresizingMaskIntoConstraints = false
        userNameInput.placeholder = "User Name"
        
        passwordInput = UITextField()
        passwordInput.translatesAutoresizingMaskIntoConstraints = false
        passwordInput.placeholder = "Password"
        
        submitButton = UIButton()
        submitButton.setTitle("submit", for: .normal)
        submitButton.backgroundColor = UIColor.black
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        submitButton.isEnabled = true
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 5;
        stackView.addArrangedSubview(userNameInput)
        stackView.addArrangedSubview(passwordInput)
        stackView.addArrangedSubview(submitButton)

        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func submitButtonPressed(_ sender:UIButton) {
        viewModel?.loginUser(username: userNameInput.text ?? "", pword: passwordInput.text ?? "")
    }

}
