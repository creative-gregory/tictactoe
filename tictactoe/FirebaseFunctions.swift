//
//  FirebaseFunctions.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 8/7/21.
//

import UIKit
import Firebase

extension UIViewController {
    func buttonsToEnable(buttons: [UIButton], board: [String:String]) {
        for (k, v) in board {
            if v == " " {
                buttons[Int(k)!].isEnabled = true
            }
        }
    }
    
    func buttonsToDisable(buttons: [UIButton], board: [String:String]) {
        for (k, v) in board {
            if v != " " {
                buttons[Int(k)!].isEnabled = false
            }
        }
    }
    
    
    
}
