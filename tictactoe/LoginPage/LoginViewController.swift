//
//  LoginViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 7/7/21.
//

import UIKit
import Firebase
//import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
    @IBOutlet weak var googleLoginOutlet: UIButton!
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var mainMenuOutlet: UIButton!
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var signInWithLabel: UILabel!
    @IBOutlet weak var noAccountLabel: UILabel!
    
    // Loading Animation Variables
    let screenSize:CGRect = UIScreen.main.bounds
    let loadingAnimationSize:CGFloat = 100
    
    var buttonsArr = [UIButton]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            print("Go to Online - User Logged In.")

//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let newViewController = storyBoard.instantiateViewController(withIdentifier: "waitPage") as! WaitPageViewController
//            newViewController.modalPresentationStyle = .fullScreen
//            self.present(newViewController, animated: true, completion: nil)
            self.performSegue(withIdentifier: "waitPage", sender: self)
        }
        else {
            print("Go to Online - No User Logged In.")
        }
        
        buttonsArr = [loginOutlet, mainMenuOutlet]
        setupViewMode(buttons: buttonsArr)
        roundButtonEdges(buttons: buttonsArr)
        
        
        circularButtonStyle(button: googleLoginOutlet, color: .white)

        emailTextField.layer.borderWidth    = 1.0
        emailTextField.layer.borderColor    = UIColor.systemGray2.cgColor

        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.systemGray2.cgColor

        roundTextFieldEdges(tf: emailTextField)
        roundTextFieldEdges(tf: passwordTextField)
        
        self.loginOutlet.isHidden           = false
        self.orLabel.isHidden               = false
        self.signInWithLabel.isHidden       = false
        self.googleLoginOutlet.isHidden     = false
        self.noAccountLabel.isHidden        = false
        self.signUpButtonOutlet.isHidden    = false
        
        self.emailTextField.text            = ""
        self.passwordTextField.text         = ""
        
        self.passwordTextField.isSecureTextEntry = true
        
        self.emailTextField.attributedPlaceholder       = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText])
        self.passwordTextField.attributedPlaceholder    = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText])
    }
    
    // changes color scheme based on the current viewmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            print("View Mode Changed")
            
            setupViewMode(buttons: buttonsArr)
        }
    }
    
    @IBAction func buttons(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            // Login
            print("Email")
            authSignIn(email: emailTextField, password: passwordTextField)
        case 1:
            // Login with Google
            print("Google")
        case 2:
            // Sign Up
            print("Sign Up")
            self.performSegue(withIdentifier: "signUpPage", sender: self)
        case 3:
            // Forgot Password
            print("Forgot Password")
        case 4:
            self.presentingViewController?.dismiss(animated: true, completion: nil)
//            print(4)
//            self.dismiss(animated: true, completion: nil)
        default:
            print("Do Nothing")
            break
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // work on Auth functions
    func authSignIn(email: UITextField, password: UITextField) {
        if email.text!.isEmpty {
            textFieldHandler(tf: email, errorText: "Please enter a email.", color: .systemRed, shake: true)
            // Make email text field shake and turn red, clear current text, and include print statement in the place holder text
        }
        if password.text!.isEmpty {
            textFieldHandler(tf: password, errorText: "Please enter a password.", color: .systemRed, shake: true)
            // Make password text field shake and turn red, clear current text, and include print statement in the place holder text
        }
        
        else {
            Auth.auth().signIn(withEmail: String(email.text!), password: String(password.text!)) { (result, error) in
                if error == nil {
//                if error == nil && self.isEmailVerified() {
                    print("Signed In")
                    self.textFieldHandler(tf: email, errorText: " ", color: .systemGreen, shake: false)
                    self.textFieldHandler(tf: password, errorText: " ", color: .systemGreen, shake: false)
                    
                    let screenWidth = self.screenSize.width
                    let screenHeight = self.screenSize.height
                    
                    let myView = SpinnerView(frame: CGRect(x: (screenWidth/2.0) - self.loadingAnimationSize/2, y: (screenHeight/2.0) - self.loadingAnimationSize/2, width: self.loadingAnimationSize, height: self.loadingAnimationSize))
                    
                    self.view.addSubview(myView)
                    
                    self.loginOutlet.isHidden           = true
                    self.orLabel.isHidden               = true
                    self.signInWithLabel.isHidden       = true
                    self.googleLoginOutlet.isHidden     = true
                    self.noAccountLabel.isHidden        = true
                    self.signUpButtonOutlet.isHidden    = true
                    
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                        print("Account Creation Success")

                        myView.removeFromSuperview()
                        self.performSegue(withIdentifier: "waitPage", sender: self)
                    }
                }
                else if error != nil && !self.isEmailVerified() {
                    print(error!.localizedDescription)
                    
                    switch error!.localizedDescription {
                    case "There is no user record corresponding to this identifier. The user may have been deleted.":
                        // Make password text field shake and turn red, clear current text, and include print statement in the place holder text
                        self.textFieldHandler(tf: email, errorText: "Email not on record.", color: .systemRed, shake: true)
                        print("Email does not exist.")
                        
                    case "The password is invalid or the user does not have a password." :
                        self.textFieldHandler(tf: password, errorText: "Password does not match user info.", color: .systemRed, shake: true)
                        print("Password Error")
                        // Make password text field shake and turn red, clear current text, and include print statement in the place holder text
                    
//                    case "There is no user record corresponding to this identifier. The user may have been deleted.":
//                        self.textFieldHandler(tf: email, errorText: " ", color: .systemGreen, shake: false)
//                        self.textFieldHandler(tf: password, errorText: "Password does not match user info.", color: .systemRed, shake: true)
//
//                    case "The password is invalid or the user does not have a password.":
//                        self.textFieldHandler(tf: email, errorText: " ", color: .systemGreen, shake: false)
//                        self.textFieldHandler(tf: password, errorText: "Password does not match user info.", color: .systemRed, shake: true)
                        
                    case "Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.":
                        print("Account is locked.")
                    // idk what to do here, email the user that they have been locked out...
                    default:
                        break
                    }


                    
                }
                
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Stops segue if conditions aew not met
        return false
    }
    
}
