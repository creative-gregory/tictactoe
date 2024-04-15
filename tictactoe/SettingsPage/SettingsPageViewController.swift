//
//  SettingsPageViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 7/30/21.
//

import UIKit
import Firebase

class SettingsPageViewController: UIViewController {
    let defaults = UserDefaults.standard
    var buttonsArr = [UIButton]()
    
    @IBOutlet weak var closeButtonOutlet: UIButton!
    @IBOutlet weak var removeAdsButtonOutlet: UIButton!
    @IBOutlet weak var logOutButtonOutlet: UIButton!
    
    @IBOutlet weak var currentUserEmailLabel: UILabel!
    
    let currentUser = Auth.auth().currentUser?.email
    
    let emailVer =  Auth.auth().currentUser?.isEmailVerified
    
    override func viewWillAppear(_ animated: Bool) {
        buttonsArr = [
            closeButtonOutlet,
            removeAdsButtonOutlet,
            logOutButtonOutlet
        ]
        
        setupViewMode(buttons: buttonsArr)
        roundButtonEdges(buttons: buttonsArr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if currentUser == nil {
            self.currentUserEmailLabel.text = "No Current User"
        }
        else {
            self.currentUserEmailLabel.text = "User: \(currentUser!) - Verified: \(emailVer!)"
        }
    }
    

    @IBAction func viewModeSegmentControl(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            defaults.set("L", forKey: "viewMode")
//            print("Light")
//        case 1:
//            defaults.set("D", forKey: "viewMode")
//            print("Dark")
//        default:
//            break
//        }
//
//        print(sender.selectedSegmentIndex)
    }
    
    @IBAction func buttons(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.dismiss(animated: true)
            
        case 1:
            print("delete account")
//            logOut()
            
//            currentUserEmailLabel.text = "No Current User"
//            displayAlert(title: "Logged Out!", message: "User logged out.")
        default:
            break
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Stops segue if conditions are not met
        return false
    }
    
    // changes color scheme based on the current viewmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            print("View Mode Changed")
            
            setupViewMode(buttons: buttonsArr)
        }
    }
}
