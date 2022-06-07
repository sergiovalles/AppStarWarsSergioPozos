//
//  LoginViewController.swift
//  starwars
//
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ActionButton: UIButton!
    @IBOutlet weak var ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailTextField.delegate = self
        PasswordTextField.delegate = self
        createDismissKeyboardTapGesture()
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextFields()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func onLogin(_ sender: Any?) {
        guard let email = EmailTextField.text, let password = PasswordTextField.text else { return }
        self.view.endEditing(true)
        NetworkManager.shared.doLogin(for: email, password: password, success: { user in
            DispatchQueue.main.async {
                let detailVC = DetailViewController(user: user)
                detailVC.title = user.name
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }) { error in
            DispatchQueue.main.async {
                self.ErrorLabel.text = error
            }
        }
        
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    private func initUI() {
        // BUTTON
        ActionButton.backgroundColor = .systemYellow
        ActionButton.layer.cornerRadius = 10
        // ERROR LABEL
        ErrorLabel.text = ""
        
    }
    
    private func clearTextFields() {
        EmailTextField.text = ""
        PasswordTextField.text = ""
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.ErrorLabel.text != "" {
            DispatchQueue.main.async {
                self.ErrorLabel.text = ""
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.PasswordTextField {
            self.onLogin(nil)
        }
        return true
    }
}
