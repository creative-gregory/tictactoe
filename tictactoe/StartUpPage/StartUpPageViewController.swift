//
//  StartUpPageViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 4/5/21.
//

import UIKit
import Firebase

class StartUpPageViewController: UIViewController {
    var counter = 0
    
    @IBOutlet weak var TwoPlayerButton: UIButton!
    @IBOutlet weak var SoloButton: UIButton!
    @IBOutlet weak var OnlineButton: UIButton!
    @IBOutlet weak var SettingsButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    var buttonsArr = [UIButton]()
    
    @IBOutlet weak var currentUserEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        setViewMode()
        buttonsArr = [TwoPlayerButton, SoloButton, OnlineButton, SettingsButton]
        setupViewMode(buttons: buttonsArr)
        roundButtonEdges(buttons: buttonsArr)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
            self.performSegue(withIdentifier: "2VSPage", sender: self)
            print("Go to Two Player Versus")
        case 1:
            self.performSegue(withIdentifier: "SoloVSPage", sender: self)
            print("Go to Solo Versus")
        case 2:
//            print("Go to Online Page")
//            self.performSegue(withIdentifier: "loginPage", sender: self)
            
            
            if Auth.auth().currentUser != nil {
                print("Go to Online - User Logged In.")
//                self.performSegue(withIdentifier: "loginPage", sender: self)



//                Method 1 - Works but very laggy
//                let vc = WaitPageViewController()
//                self.navigationController?.pushViewController(vc, animated: true)


//                Method 2 - Works no Nav Bar
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "waitPage") as! WaitPageViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)

//                Method 3 - Works has Nav Bar but will not dismiss when shown, had to go to the navi page and set the page view to full                  screen to show the nav bar
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "waitPage") as! WaitPageViewController
//                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                print("Go to Online - No User Logged In.")
                self.performSegue(withIdentifier: "loginPage", sender: self)
            }
        case 3:
            print("Go to Settings")
            
            self.performSegue(withIdentifier: "settingsPage", sender: self)
            
        default:
            break
        }
        
    }
    
    var ref:DatabaseReference = Database.database().reference()
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
}
