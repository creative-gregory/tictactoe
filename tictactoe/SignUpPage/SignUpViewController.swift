//
//  SignUpViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 7/7/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var confirmPasswordTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    
    @IBOutlet weak var registerButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    let screenSize:CGRect = UIScreen.main.bounds
    
    var ref:DatabaseReference = Database.database().reference()
    
    var buttonsArr = [UIButton]()
    
    @IBAction func buttons(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            authRegistation(email: emailTextField, username: usernameTextField, password: passwordTextField, confirmPassword: confirmPasswordTextField)
        case 1:
            self.dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    // Need to round Text Field corners
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardOnTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        buttonsArr = [registerButtonOutlet, cancelButtonOutlet]
        
        setupViewMode(buttons: buttonsArr)
        roundButtonEdges(buttons: buttonsArr)
        
        roundTextFieldEdges(tf: emailTextField)
        roundTextFieldEdges(tf: usernameTextField)
        roundTextFieldEdges(tf: passwordTextField)
        roundTextFieldEdges(tf: confirmPasswordTextField)
        
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = UIColor.systemGray2.cgColor
        
        usernameTextField.layer.borderWidth = 1.0
        usernameTextField.layer.borderColor = UIColor.systemGray2.cgColor
        
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.systemGray2.cgColor
        
        confirmPasswordTextField.layer.borderWidth = 1.0
        confirmPasswordTextField.layer.borderColor = UIColor.systemGray2.cgColor
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    // changes color scheme based on the current viewmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            print("View Mode Changed")
            
            setupViewMode(buttons: buttonsArr)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Stops segue if conditions aew not met
        return false
    }
    
    
    func checkSignUpParams(email: UITextField, username: UITextField, password: UITextField, confirmPassword: UITextField) -> Bool {
        // Add error handling for passwords to match and shake/turn red if not match
        // Add error handling for email, username, and both password field being empty
        if email.text!.isEmpty {
            textFieldHandler(tf: email, errorText: "Please enter a email.", color: .systemRed, shake: true)
            
            return false
        }
        
        if username.text!.isEmpty {
            textFieldHandler(tf: username, errorText: "Please enter a username.", color: .systemRed, shake: true)
            
            return false
        }
        
        if username.text!.count < 1 || username.text!.count >= 15 {
            print("Username must be between 1 - 15 Characters")
            self.textFieldHandler(tf: username, errorText: "Display name too long.", color: .systemRed, shake: true)
            self.textFieldHandler(tf: password, errorText: "Password", color: .systemRed, shake: true)
            self.textFieldHandler(tf: confirmPassword, errorText: "Confirm Password" , color: .systemRed, shake: true)
            
            return false
        }
        
        if password.text! != confirmPassword.text! {
            self.textFieldHandler(tf: password, errorText: "Passwords do not match", color: .systemRed, shake: true)
            self.textFieldHandler(tf: confirmPassword, errorText: "Confirm Password", color: .systemRed, shake: true)
            
            confirmPassword.text! = " "
            
            return false
        }
        
        if password.text!.isEmpty {
            textFieldHandler(tf: password, errorText: "Please enter a password.", color: .systemRed, shake: true)
            
            return false
        }
        
        if confirmPassword.text!.isEmpty {
            textFieldHandler(tf: confirmPassword, errorText: "Please confirm password.", color: .systemRed, shake: true)
            
            return false
        }
        
        return true
    }
    
    func authRegistation(email: UITextField, username: UITextField, password: UITextField, confirmPassword: UITextField) {
        
        if !checkSignUpParams(email: email, username: username, password: password, confirmPassword: confirmPassword) {
            print("There was an error")
        }
        
        else {
            Auth.auth().createUser(withEmail: String(email.text!), password: String(password.text!)) { (result, error) in
                if error == nil {
                    
                    Auth.auth().signIn(withEmail: String(email.text!), password: String(password.text!)) { (result, error) in
                        if error == nil {
                            
                            self.setUserDisplayName(username: self.generateDisplayNameTag(name: username.text!))
                            
                            self.textFieldHandler(tf: email, errorText: " ", color: .systemGreen, shake: false)
                            self.textFieldHandler(tf: username, errorText: " ", color: .systemGreen, shake: false)
                            self.textFieldHandler(tf: password, errorText: " ", color: .systemGreen, shake: false)
                            self.textFieldHandler(tf: confirmPassword, errorText: " ", color: .systemGreen, shake: false)
                            
                            
                            let screenWidth = self.screenSize.width
                            let screenHeight = self.screenSize.height
                            
                            let loadingAnimationSize:CGFloat = 100
                            
                            let loadingAnimation = SpinnerView(frame: CGRect(x: (screenWidth/2.0) - loadingAnimationSize/2, y: (screenHeight/2.0) - loadingAnimationSize/2, width: loadingAnimationSize, height: loadingAnimationSize))
                            
                            self.view.addSubview(loadingAnimation)
                            
                            self.registerButtonOutlet.isHidden = true
                            self.cancelButtonOutlet.isHidden = true
                            
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                                print("Account Creation Successful")

                                loadingAnimation.removeFromSuperview()
                                
//                                self.performSegue(withIdentifier: "waitPage", sender: self)
//                                self.navigationController?.popToRootViewController(animated: true)
//                                not smooth but works
                                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            }
                        }
                    }
                }
                
                else if error != nil {
                    print(error!.localizedDescription)
                    
                    if error!.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        self.textFieldHandler(tf: email, errorText: "Email not on record.", color: .systemRed, shake: true)
                        print("Email does not exist.")
                        // Make password text field shake and turn red, clear current text, and include print statement in the place holder text
                    }
                    
                    if error!.localizedDescription == "The password is invalid or the user does not have a password." {
                        self.textFieldHandler(tf: password, errorText: "Password does not match user info.", color: .systemRed, shake: true)
                        print("Password Error")
                        // Make password text field shake and turn red, clear current text, and include print statement in the place holder text
                    }
                    
                    if error!.localizedDescription != "There is no user record corresponding to this identifier. The user may have been deleted." && error!.localizedDescription == "The password is invalid or the user does not have a password." {
                        self.textFieldHandler(tf: email, errorText: " ", color: .systemGreen, shake: false)
                        self.textFieldHandler(tf: password, errorText: "Password does not match user info.", color: .systemRed, shake: true)
                    }
                    
                    if error!.localizedDescription == "Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later." {
                        // idk what to do here, email the user that they have been locked out...
                    }
                    
                    if error!.localizedDescription == "The email address is already in use by another account." {
                        self.textFieldHandler(tf: email, errorText: "Email currently in use.", color: .systemRed, shake: true)
                    }
                    
                    if error!.localizedDescription == "The password must be 6 characters long or more." {
                        self.textFieldHandler(tf: password, errorText: "Password strength is too weak.", color: .systemRed, shake: true)
                        
                        confirmPassword.text! = " "
                    }
                    
                    if error!.localizedDescription == "The email address is badly formatted." {
                        self.textFieldHandler(tf: email, errorText: "Improper email format.", color: .systemRed, shake: true)
                    }
                }
            }
        }
    }
    
    func setUserDisplayName(username: String) {
        // Add Unique Numbers to the end  like "#0000" randomized and check the database of current users
        if let currentUser = Auth.auth().currentUser?.createProfileChangeRequest() {
            currentUser.displayName = String(username)
            currentUser.commitChanges(completion: {error in
                if let error = error {
                    print(error)
                }
                else {
                    print("DisplayName Set")
                }
            })
        }
    }
    
    
    // both need work and more thoughtout 
    func generateDisplayNameTag(name: String) -> String {
        // add tag numbers here
        
       var nameWithTag = "\(name)#\(String(Int.random(in: 1000...9999)))"
        
        if !checkDisplayNameAvailability(possibleName: name) {
            nameWithTag = generateDisplayNameTag(name: name)
            // recursive call to get another tag if necessary
        }
        
//        print(nameWithTag)
        self.ref.child("names").childByAutoId().setValue(["\(Auth.auth().currentUser!.uid)":nameWithTag])
        
        return nameWithTag
    }
    
    func checkDisplayNameAvailability(possibleName: String) -> Bool {
        // check db for name
        // if in the db return false
        // if not in the db return true
        var r = true
        
        self.ref.child("names").observe(.value) { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let childSnapshot = child as! DataSnapshot
                    let names = childSnapshot.value as! NSDictionary
                    
                    print(names)
                }
//                print(snapshot)
                print("Name Exists")
            }
            else {
                print("Name does not exists")
                
                r = false
            }
        }
        return r
    }
    
    
}
