//
//  WaitPageViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 7/8/21.
//

import UIKit
import Firebase

class WaitPageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var welcomeBackLabel: UILabel!
    @IBOutlet weak var generateCodeLabel: UILabel!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    
    var ref:DatabaseReference = Database.database().reference()
    
    var code = ""
    var segueID = ""
    
    let screenSize:CGRect = UIScreen.main.bounds
    
    @IBOutlet weak var joinGameOutlet: UIButton!
    @IBOutlet weak var hostGameOutlet: UIButton!
    @IBOutlet weak var randomQueueOutlet: UIButton!
    @IBOutlet weak var mainMenuOutlet: UIButton!
    @IBOutlet weak var logOutOutlet: UIButton!
    
    var buttonsArr = [UIButton]()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        buttonsArr = [joinGameOutlet, hostGameOutlet, randomQueueOutlet, mainMenuOutlet, logOutOutlet]
        setupViewMode(buttons: buttonsArr)
        roundButtonEdges(buttons: buttonsArr)
        
        roundTextFieldEdges(tf: codeTextField)
        
        codeTextField.layer.borderWidth = 1.0
        codeTextField.layer.borderColor = UIColor.systemGray2.cgColor
        
//        let email = String(Auth.auth().currentUser!.email!)
//        let uid = String(Auth.auth().currentUser!.uid)
        
        let displayName = String(Auth.auth().currentUser!.displayName!)
        
//        print(email, uid, displayName)
        
        welcomeBackLabel.text = "Welcome back \(displayName)!"
        
        codeTextField.isHidden = false
        joinGameOutlet.isHidden = false
        codeTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardOnTap()
        
        codeTextField.delegate = self
//        self.codeTextField.autocapitalizationType = .words
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
//        codeTextField.text = "\(16 - updateText.count)"
        
        return updateText.count <= 8
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
            print("Leaving Waiting Page")
            self.dismiss(animated: true, completion: nil)
            
//                        self.presentingViewController?.dismiss(animated: true, completion: nil)
        //            can chain multiple to go back to root
//                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        
        
        //          Is suppossed to Pop to Root View Controller
        //          Does not pop to root pops to login page
                    self.navigationController?.popToRootViewController(animated: true)
        
        
        //            let vc = StartUpPageViewController()
        //            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            logOut()
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
                
                //                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
                self.dismiss(animated: true, completion: nil)
                self.displayAlert(title: "Logged Out!", message: "User logged out.")
//                self.navigationController?.popToRootViewController(animated: true)
            }
            
        case 2:
            displayAlert(title: "Coming Soon!", message: "Be on the lookout for an update!")
            print("Random Queue")
        case 3:
            // Host Game Button
            // do db stuff on arrival to next page, if the user leaves the matchmakingpage remove the game code from the database
            
//            let dispatchGroup = DispatchGroup()
            
//            code = requestRoomCode()
//            print(code)
////
//            dispatchGroup.enter()
//
//            // need to check if code is in db
//            // if yes, regenerate code
//            // if no continue with segue
//
            
//
//            requestRoomCode { verfiedCode in
//                self.code = verfiedCode
//                print(verfiedCode)
//            }
//
//            dispatchGroup.leave()
            
//            dispatchGroup.notify(queue: .main) {
//                print("Finished all requests.")
            code = generateCode()
            self.segueID = "hostGame"
            
            let screenWidth = self.screenSize.width
            let screenHeight = self.screenSize.height
            
            let loadingAnimationSize:CGFloat = 100
            
            let loadingAnimation = SpinnerView(frame: CGRect(x: (screenWidth/2.0) - loadingAnimationSize/2, y: (screenHeight/2.0) - loadingAnimationSize/2, width: loadingAnimationSize, height: loadingAnimationSize))
           
            self.codeTextField.isHidden = true
            self.joinGameOutlet.isHidden = true
            
            self.view.addSubview(loadingAnimation)
 
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in

                loadingAnimation.removeFromSuperview()
            self.performSegue(withIdentifier: self.segueID, sender: self)
            }
            
            
//            }
            
        case 4:
            // Join Game Button
            // do db stuff from other swift file then segue
            // add async to completion of firebase functions to check if more than one user is in the room and if the room actually exists
            let dispatchGroup = DispatchGroup()
            
            var verify = [
                "vfCode": false,
                "vfPlayers": false
            ]
            
            dispatchGroup.enter()
            
            verifyCode(tf: codeTextField) { success in
                verify["vfCode"] = success
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            
            verifyPlayers(tf: codeTextField) { success in
                verify["vfPlayers"] = success
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                print("Finished all requests.")
                print(verify)
                
                if verify["vfCode"]! && verify["vfPlayers"]! {
                    print("Proceed to next page.")
                    self.segueID = "joinGame"
                    
                    // add player to db
                    
                    let param = [
                        "O": "\(String((Auth.auth().currentUser?.uid)!))"
                    ]
                    
                    self.ref.child("room").child(self.codeTextField.text!.uppercased()).child("players").updateChildValues(param)
                    
                    self.performSegue(withIdentifier: self.segueID, sender: self)
                }
                else {
                    self.displayAlert(title: "Error Joining Room", message: "Please check if room ID is valid.")
                    print("Error connecting to room.")
                }
            }
            
        default:
            break
        }
    }
    
    func verifyCode(tf: UITextField, completion: @escaping (_ success: Bool) -> Void) {
        if tf.text!.isEmpty || tf.text!.uppercased().count < 8 {
            completion(false)
        }
        else {
            self.ref.child("room").child(tf.text!.uppercased()).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists() {
                    
                    print("code exists")
                    completion(true)
                }
                else {
                    
                    print("code does not exist")
                    completion(false)
                }
            }
        }
    }
    
    func verifyPlayers(tf: UITextField, completion: @escaping (_ success: Bool) -> Void) {
        var counter = 0
        
        if tf.text!.isEmpty {
            completion(false)
        }
        
        else {
            self.ref.child("room").child(tf.text!.uppercased()).child("players").observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    
                    for _ in snapshot.children {
                        
                        counter += 1
                        //                        player.append(String(name))
                    }
                }
                
                //                print(player, player.count)
                //                print(counter)
                
                if counter < 2 {
                    print("1 Player able to join")
                    completion(true)
                }
                else {
                    print("Player Limit Reached")
                    completion(false)
                }
            }
        }
    }
    
    func generateCode() -> String {
        var c = ""

        func randomLetter() -> String {
            return (65...90).map{String(UnicodeScalar($0))}.randomElement()!
        }
        
        func randomNumber() -> String {
            return String(Int.random(in: 0...9))
        }

        for i in 0...7 {
            if i % 2 == 0 {
                c += randomLetter()
            }
            
            else {
                c += randomNumber()
            }
        }
        
//        print(c)
        return c
    }
    
    func requestRoomCode() -> String {
        let c = generateCode()
        var codeBool = "dainxaoicxnw"
        print(codeBool)
        
        
//        let dg = DispatchGroup()
//        dg.enter()
//        print(c)

        checkIfCodeIsUsed(c: c) { success in
            codeBool = success
            
        }
        
//        dg.leave()
        
        print(codeBool)
        
        if codeBool == "true" {
            return c
        }
        else {
//            requestRoomCode()
            print("bad code")
        }
        
        
//            dg.notify(queue: .main) {
//
//            }
        return ""
    }
    
    func checkIfCodeIsUsed(c: String, completion: @escaping (_ success: String) -> Void) {
//        let dispatchGroup = DispatchGroup()
//
//        dispatchGroup.enter()
        DispatchQueue.main.async {
        self.ref.child("room").child(c).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                // do not continue
                completion("false")
                print("code is in use")
//                dispatchGroup.leave()
                
            }
            else {
                completion("true")
                // continue
                print("code does not exist")
//                dispatchGroup.leave()
            }
        }
        }
        
        

//        dispatchGroup.notify(queue: .main) {
//            print("done")
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hostGame" {
            
            // Send code forward, then do db stuff, you will see
            let destination = segue.destination as! MatchmakingViewController
            
            destination.codeToGet = code
            destination.segueIDToGet = segueID
            
        }
        
        if segue.identifier == "joinGame" {
            
            // Send code forward, then do db stuff, you will see
            let destination = segue.destination as! MatchmakingViewController
            
            destination.codeToGet = codeTextField.text!.uppercased()
            destination.segueIDToGet = segueID
            
        }
    }
    
    
    
    func dismissViewControllers() {
        guard let vc = self.presentingViewController else { return }
        
        while (vc.presentingViewController != nil) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Stops segue if conditions are not met
        return false
    }
}
