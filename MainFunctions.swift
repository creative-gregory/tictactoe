//
//  MainFunctions.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 6/27/21.
//

import UIKit
import Firebase

extension UIViewController {    
    // Gameplay Functions
    func createBoard() -> [Int:String] {
        var board = [Int:String]()
        let maxMoves = 8
        
        for i in 0...maxMoves {
            board[i] = " "
        }
        
        return board
    }
    
    func isMoveValid(board: [Int:String], index: Int) -> Bool {
        if board[index] == " " {
            return true
        }
        return false
    }
    
    func OnUserWins(player: String, board: inout [Int:String], buttons: [UIButton], checkWin: inout Bool, playerCounter: inout Int) {
        disableButtons(buttons: buttons)
    }
    
    func lightUpButtons(buttonsToHighlight: [UIButton], color: UIColor) {
        // highlight the user who wins buttons that correspond to what was the winning configuration
        
        switch color {
        case .systemTeal:
            for button in buttonsToHighlight {
                button.backgroundColor = color
            }
        case .systemGreen:
            for button in buttonsToHighlight {
                button.backgroundColor = color
            }
        case .systemRed:
            for button in buttonsToHighlight {
                button.backgroundColor = color
            }
        default:
            break
        }
    }
    
    func setupViewMode(buttons: [UIButton]) {
        let dark:UIColor = .systemGray5
        let light:UIColor = .systemGray6
        
        switch traitCollection.userInterfaceStyle {
        case .light:
            for button in buttons {
                button.backgroundColor = light
                button.layer.borderWidth = 1.0
                button.layer.borderColor = UIColor.systemGray5.cgColor
                button.setTitleColor(.systemGray, for: .normal)
            }
            
        case .dark:
            for button in buttons {
                button.backgroundColor = dark
                button.layer.borderWidth = 1.0
                button.layer.borderColor = UIColor.lightGray.cgColor
                button.setTitleColor(.white, for: .normal)
            }
             
        default:
            break
        }
    }
    
    // Check Draw Condition
    func checkIfFull(dict: [Int:String]) -> Bool {
        for (_, v) in dict {
            if v == " " {
                return true
            }
        }
        return false
    }
    
    func checkWin(board: inout [Int:String], checkWin: inout Bool, playerCounter: inout Int, buttons: [UIButton]) -> Bool {
        var winStr = " "
        let maxMoves = 9
        
        
        //        Draw Condition
        //        var drawArray = [Int]()
        //
        //        for (_, v) in board {
        //            if v != " " {
        //                drawArray.append(1)
        //            }
        //        }
        
        //        if drawArray.reduce(0, +) == maxMoves {
        //            winStr = "Draw!"
        //
        //            lightUpButtons(buttonsToHighlight: buttons, color: .systemTeal)
        //            OnUserWins(player: " ", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
        //            print(winStr)
        //
        //            return true
        //        }
        if playerCounter <= maxMoves {
            // Horizontal Win
            for i in stride(from: 0, through: 6, by: 3) {
                if board[i] == "X" && board[i + 1] == "X"  && board[i + 2] == "X" {
                    winStr = "Player X Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 1], buttons[i + 2]], color: .systemGreen)
                    OnUserWins(player: "X", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    print(winStr)
                    
                    return true
                }
                
                if board[i] == "O" && board[i + 1] == "O"  && board[i + 2] == "O" {
                    winStr = "Player O Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 1], buttons[i + 2]], color: .systemGreen)
                    OnUserWins(player: "O", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    print(winStr)
                    
                    return true
                }
            }
            
            //Vertical Win
            for i in stride(from: 0, to: 3, by: 1) {
                if board[i] == "X" && board[i + 3] == "X"  && board[i + 6] == "X" {
                    winStr = "Player X Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 3], buttons[i + 6]], color: .systemGreen)
                    OnUserWins(player: "X", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    print(winStr)
                    
                    return true
                }
                
                if board[i] == "O" && board[i + 3] == "O"  && board[i + 6] == "O" {
                    winStr = "Player O Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 3], buttons[i + 6]], color: .systemGreen)
                    OnUserWins(player: "O", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    print(winStr)
                    
                    return true
                }
            }
            
            // Left Diagonal
            if board[0] == "X" && board[4] == "X"  && board[8] == "X" {
                winStr = "Player X Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[0], buttons[4], buttons[8]], color: .systemGreen)
                OnUserWins(player: "X", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                print(winStr)
                
                return true
            }
            
            if board[0] == "O" && board[4] == "O"  && board[8] == "O" {
                winStr = "Player O Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[0], buttons[4], buttons[8]], color: .systemGreen)
                OnUserWins(player: "O", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                print(winStr)
                
                return true
            }
            
            // Right Diagonal
            if board[2] == "X" && board[4] == "X"  && board[6] == "X" {
                winStr = "Player X Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[2], buttons[4], buttons[6]], color: .systemGreen)
                OnUserWins(player: "X", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                print(winStr)
                
                return true
            }
            
            if board[2] == "O" && board[4] == "O"  && board[6] == "O" {
                winStr = "Player O Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[2], buttons[4], buttons[6]], color: .systemGreen)
                OnUserWins(player: "O", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                print(winStr)
                
                return true
            }
        }
        
        if playerCounter == maxMoves {
            lightUpButtons(buttonsToHighlight: buttons, color: .systemTeal)
            OnUserWins(player: "DRAW!", board: &board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
            
            print(winStr)
            return true
        }

        return false
    }
    
    func resetGame(board: inout [Int:String], buttons: [UIButton], checkWin: inout Bool, playerCounter: inout Int) {
        board.removeAll()
        board = createBoard()
        
        resetButtonText(buttons: buttons)
        enableButtons(buttons: buttons)

        playerCounter = 0
        
        checkWin = false
        
        print("Board Reset")
    }
    // Make function to set button text to nil
    
    func resetButtonText(buttons: [UIButton]) {
        for button in buttons {
            button.setTitle(nil, for: .normal)
        }
    }
    
    // Disables the Buttons on reset
    func disableButtons(buttons: [UIButton]) {
//        let red:UIColor = .red
        
        for button in buttons {
            button.isEnabled = false
        }
    }
    
    // Re-enables the Buttons on reset
    func enableButtons(buttons: [UIButton]) {
        for button in buttons {
            button.isEnabled = true
        }

        setupViewMode(buttons: buttons)
    }
    
    // Style Functions
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // make function to round button edges and round a button completely
    func roundButtonEdges(buttons: [UIButton]) {
        for button in buttons {
            button.layer.cornerRadius = 15.0
        }
    }
    
    // for perfect circle button if x and y dimension are equal
    func circularButtonStyle(button : UIButton, color: UIColor){
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.backgroundColor = color
    }
    
    func printGameDetails(board: [Int:String], player: Int, counter: Int, index: Int) {
        print("\(board), player : \(player), button index : \(index), move counter: \(counter)")
    }
    
    func dismissKeyboardOnTap() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    

    func shakeTextField(textField: UITextField) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.0825
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 10, y: textField.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textField.center.x + 10, y: textField.center.y))

        textField.layer.add(animation, forKey: "position")
    }
    
    func textFieldHandler(tf: UITextField, errorText: String, color: UIColor, shake: Bool) {
        if shake {
            shakeTextField(textField: tf)
            tf.text = nil
            tf.layer.borderColor = UIColor.systemRed.cgColor
        }
        else {
            tf.layer.borderColor = UIColor.systemGreen.cgColor
        }
        
        tf.attributedPlaceholder = NSAttributedString(string: errorText, attributes: [NSAttributedString.Key.foregroundColor: color])
        tf.layer.borderWidth = 1.0
    }
    
    func roundTextFieldEdges(tf: UITextField) {
        tf.layer.cornerRadius = 10
        tf.layer.masksToBounds = true
//        tf.layer.borderColor = UIColor.black.cgColor
    }
    
    
//    func deleteCurrentUser() {
//        Auth.auth().currentUser?.delete(completion: <#T##((Error?) -> Void)?##((Error?) -> Void)?##(Error?) -> Void#>)
//    }
    
    
    func isEmailVerified() -> Bool {
        let user = Auth.auth().currentUser
        
        switch user?.isEmailVerified {
        case true:
            print("User is Verified.")
            return true
        case false:
            print("User is not Verified.")
            user?.sendEmailVerification {(error) in
                guard let error = error else {
                    return print("Verification Sent.")
                }
                
            }
            return false
        default:
            break
        }
        return false
    }
    
    

    
//    func errorHandler(error: String) -> Bool {
//        switch
//    }
    
    func logOut() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        do {
            try Auth.auth().signOut()
            print("user signed out")
        } catch let signOutError as NSError {
            print("Error signing out: %@: ", signOutError)
        }
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            print("log out occured")
        }
    }
}
