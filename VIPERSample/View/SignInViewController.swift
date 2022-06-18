//
//  ViewController.swift
//  VIPERSample
//
//  Created by Hikaru Kuroda on 2022/06/18.
//

import UIKit

protocol SignInView: AnyObject {
    func setButtonEnable(isEnabled: Bool)
    func showError(title: String, message: String)
}

final class SignInViewController: UIViewController {

    private let stackView = UIStackView()
    private let idTextField = PaddingTextField(top: 5, left: 5, bottom: 5, right: 5)
    private let passwordTextField = PaddingTextField(top: 5, left: 5, bottom: 5, right: 5)
    private let signInButton = UIButton()

    var presenter: SignInPresentation!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        signInButton.addTarget(self, action: #selector(didTapSignInButton(_:)), for: .touchUpInside)

        idTextField.addTarget(self, action: #selector(didChangeID(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didChangePassword(_:)), for: .editingChanged)
    }

    private func setupView() {
        view.backgroundColor = .white

        stackView.axis = .vertical
        stackView.spacing = 40
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true

        stackView.addArrangedSubview(idTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(signInButton)

        idTextField.placeholder = "ID"

        passwordTextField.placeholder = "password"

        signInButton.isEnabled = false
        signInButton.alpha = 0.2
        signInButton.setTitle("サインイン", for: .normal)
        signInButton.setTitleColor(.black, for: .normal)
    }

    private func didChangeIDOrPassword() {
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        presenter.didChange(id, or: password)
    }


    @objc private func didChangeID(_ sender: UITextField) {
        didChangeIDOrPassword()
    }

    @objc private func didChangePassword(_ sender: UITextField) {
        didChangeIDOrPassword()
    }

    @objc private func didTapSignInButton(_ sender: UIButton) {
        let id = idTextField.text ?? ""
        let pass = passwordTextField.text ?? ""
        presenter.didTapSignInButton(id: id, password: pass)
    }
}

extension SignInViewController: SignInView {
    func setButtonEnable(isEnabled: Bool) {
        signInButton.isEnabled = isEnabled

        let alpha = isEnabled ? 1 : 0.2
        signInButton.alpha = alpha
    }

    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "閉じる", style: .default)
        alert.addAction(closeAction)
        self.present(alert, animated: true)
    }
}

