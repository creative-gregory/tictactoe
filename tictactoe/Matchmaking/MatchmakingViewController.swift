//
//  MatchmakingViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 7/30/21.
//

import UIKit
import Firebase

class MatchmakingViewController: UIViewController {
    var gameBoard = [String:String]()
    var ref:DatabaseReference = Database.database().reference()
    
    var codeToGet = ""
    var segueIDToGet = ""
    var playerCounter = 0
    
    var checkWin = false
    let maxMoves = 8
    
    var buttonsArr = [UIButton]()
    var boardButtonsArr = [UIButton]()
    
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet weak var button0Outlet: UIButton!
    @IBOutlet weak var button1Outlet: UIButton!
    @IBOutlet weak var button2Outlet: UIButton!
    @IBOutlet weak var button3Outlet: UIButton!
    @IBOutlet weak var button4Outlet: UIButton!
    @IBOutlet weak var button5Outlet: UIButton!
    @IBOutlet weak var button6Outlet: UIButton!
    @IBOutlet weak var button7Outlet: UIButton!
    @IBOutlet weak var button8Outlet: UIButton!
    
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var playAgainButtonOutlet: UIButton!
    @IBOutlet weak var copyCodeOutlet: UIButton!
    
//    @IBOutlet weak var codeLabel: UILabel!
//    @IBOutlet weak var codeTextView: UITextView!
    
    @IBOutlet weak var xWinsLabel: UILabel!
    @IBOutlet weak var oWinsLabel: UILabel!
    
    // search database for both user's uid, then push the board
    override func viewWillAppear(_ animated: Bool) {
        if segueIDToGet == "hostGame" {
            print("Player is Host.")
            
            let param = [
                "X": "\(String((Auth.auth().currentUser?.uid)!))"
            ]
            
            gameBoard = createBoardFB()
            
            self.ref.child("room").child(codeToGet).child("players").updateChildValues(param)
            self.ref.child("room").child(codeToGet).child("board").setValue(gameBoard)
            self.ref.child("room").child(codeToGet).child("counter").setValue(playerCounter)
            self.ref.child("room").child(codeToGet).child("x-wins").setValue(0)
            self.ref.child("room").child(codeToGet).child("o-wins").setValue(0)
            
            copyCodeOutlet.setTitle("Room ID: " + codeToGet, for: .normal)
        }
        else {
            copyCodeOutlet.setTitle("Room ID: " + codeToGet, for: .normal)
            copyCodeOutlet.isEnabled = false
            
            print("Player is Guest.")
            print(codeToGet)
        }
        
        boardButtonsArr = [
            button0Outlet,
            button1Outlet,
            button2Outlet,
            button3Outlet,
            button4Outlet,
            button5Outlet,
            button6Outlet,
            button7Outlet,
            button8Outlet
        ]
        
        buttonsArr = [playAgainButtonOutlet, backButtonOutlet]
        
        setupViewMode(buttons: buttonsArr + boardButtonsArr)
        roundButtonEdges(buttons: buttonsArr + boardButtonsArr)
        resetButtonText(buttons: boardButtonsArr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestCounterFB { [self] counter in
            self.playerCounter = counter
//            self.xWinsLabel.text = String(self.playerCounter)
            
            if self.playerCounter % 2 == 0 && !self.checkWin {
                self.oWinsLabel.textColor = .label
                self.xWinsLabel.textColor = .systemGreen
            }
            if self.playerCounter % 2 == 1 && !self.checkWin {
                self.oWinsLabel.textColor = .systemGreen
                self.xWinsLabel.textColor = .label
            }
            
            requestBoardFromFB(completion: { board in
                self.gameBoard = board
                self.setButtonTitle(b: self.gameBoard)

                //            print(board)
            })
 
            if !checkWin {
                if segueIDToGet == "hostGame" && playerCounter % 2 == 1 {
                    print("join turn")
                    buttonsToDisable(buttons: boardButtonsArr, board: gameBoard)
                    
                }
                
                if segueIDToGet == "joinGame" && playerCounter % 2 == 0 {
                    print("host turn")
                    buttonsToDisable(buttons: boardButtonsArr, board: gameBoard)
                }
                else {
                    buttonsToEnable(buttons: boardButtonsArr, board: gameBoard)
                }
            }
            
            self.checkWin = self.checkWinFB(board: self.gameBoard, checkWin: &self.checkWin, playerCounter: &self.playerCounter, buttons: self.boardButtonsArr)

            
            print(self.playerCounter)
        }
        
        playAgainButtonOutlet.isHidden = true
        
        handlesOnUserLeavePage()
        
        restartListener(user: segueIDToGet) { resDict in
            self.restartHandler(restart: resDict)
        }

    }
    
    func createBoardFB() -> [String:String] {
        var dict = [String:String]()
        for i in 0...8 {
            dict["\(i)"] = " "
        }
        return dict
    }
    
    func handlesOnUserLeavePage() {
        switch segueIDToGet {
        case "hostGame":
            self.onHostDisconnect(id: segueIDToGet)
        case "joinGame":
            self.sendGuestToMenuOnHostQuit()
            self.onGuestDisconnects(id: segueIDToGet)
        default:
            break
        }
    }
    
    func onHostDisconnect(id: String) {
        if id == "hostGame" {
            self.ref.child("room").child(codeToGet).onDisconnectRemoveValue()
        }
        else {
            self.ref.child("room").child(codeToGet).child("players").child("O").onDisconnectRemoveValue()
        }
    }
    
    func onGuestDisconnects(id: String) {
        if id == "joinGame" {
            self.ref.child("room").child(codeToGet).child("players").child("O").onDisconnectRemoveValue()
        }
    }
    
    func sendGuestToMenuOnHostQuit() {
//        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        self.ref.child("room").child(codeToGet).observe(.value) { snapshot in
            if !snapshot.exists() {
                print("Host has disconnected.")
                self.dismiss(animated: true)
            }
        }
        
        dispatchGroup.leave()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if segueIDToGet == "hostGame" {
            self.ref.child("room").child(codeToGet).removeValue()
        }
        else {
            self.ref.child("room").child(codeToGet).child("players").child("O").removeValue()
        }
    }
    
//    didSet var for restart
    
   
    
    @IBAction func buttons(_ sender: UIButton) {
        switch sender.tag {
        case 0...8:
            self.placeMoveFirebase(player: self.playerCounter % 2, index: sender.tag)
        case 9:
            displayAlertNewGame(user: segueIDToGet)
            print("Reset Game")
        case 10:
            self.dismiss(animated: true, completion: nil)
        case 11:
            let pasteboard = UIPasteboard.general
            pasteboard.string = codeToGet
            
            copyCodeOutlet.setTitle("Room ID: " + codeToGet, for: .normal)
            displayAlert(title: codeToGet, message: "Room ID has been copied to clipboard.")
        default:
            print("Do Nothing")
            break
        }
    }
    
    // changes color scheme based on the current viewmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            print("View Mode Changed")
            
            setupViewMode(buttons: buttonsArr)
        }
    }
    
    func isMoveValidFB(board: [String:String], move: Int) -> Bool {
        if board["\(move)"] == " " {
            return true
        }
            
        return false
    }
    
    func placeMoveFirebase(player: Int, index: Int) {
        let players = ["0" : "X", "1" : "O"]
        
        if isMoveValidFB(board: gameBoard, move: index) {
            switch (player, segueIDToGet) {
            case (0, "hostGame"):
                self.ref.child("room").child(codeToGet).child("board").child("\(index)").setValue(players[String(player)])
                playerCounter += 1
                self.ref.child("room").child(codeToGet).child("counter").setValue(playerCounter)
                
            case (1, "joinGame"):
                self.ref.child("room").child(codeToGet).child("board").child("\(index)").setValue(players[String(player)])
                playerCounter += 1
                self.ref.child("room").child(codeToGet).child("counter").setValue(playerCounter)

            default:
                break
            }
        }

        else {
            displayAlert(title: "Move Invalid!", message: "Please Try Another Move!")
        }
    }
    
    func OnUserWinsFB(player: String, board: [String:String], buttons: [UIButton], checkWin: inout Bool, playerCounter: inout Int) {
        disableButtons(buttons: boardButtonsArr)
        playAgainButtonOutlet.isHidden = false
    }
    
    func checkWinFB(board: [String:String], checkWin: inout Bool, playerCounter: inout Int, buttons: [UIButton]) -> Bool {
        var winStr = "winner undecided"
        let maxMoves = 9
        
//        dispatchGroup.enter()
        
        if playerCounter <= maxMoves {
            // Horizontal Win
            for i in stride(from: 0, through: 6, by: 3) {
                if board["\(i)"] == "X" && board["\(i + 1)"] == "X" && board["\(i + 2)"] == "X" {
                    winStr = "Player X Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 1], buttons[i + 2]], color: .systemGreen)
                    OnUserWinsFB(player: "X", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    
                    return true
//                    noValidWin.append(true)
                }
                
                if board["\(i)"] == "O" && board["\(i + 1)"] == "O" && board["\(i + 2)"] == "O" {
                    winStr = "Player O Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 1], buttons[i + 2]], color: .systemGreen)
                    OnUserWinsFB(player: "O", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    
                    return true
                }
            }
            
            //Vertical Win
            for i in stride(from: 0, to: 3, by: 1) {
                if board["\(i)"] == "X" && board["\(i + 3)"] == "X" && board["\(i + 6)"] == "X" {
                    winStr = "Player X Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 3], buttons[i + 6]], color: .systemGreen)
                    OnUserWinsFB(player: "X", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    
                    return true
                }
                
                if board["\(i)"] == "O" && board["\(i + 3)"] == "O" && board["\(i + 6)"] == "O" {
                    winStr = "Player O Wins!"
                    
                    lightUpButtons(buttonsToHighlight: [buttons[i], buttons[i + 3], buttons[i + 6]], color: .systemGreen)
                    OnUserWinsFB(player: "O", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                    
                    return true
                }
            }
            
            // Left Diagonal
            if board["0"] == "X" && board["4"] == "X" && board["8"] == "X" {
                winStr = "Player X Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[0], buttons[4], buttons[8]], color: .systemGreen)
                OnUserWinsFB(player: "X", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                
                return true
            }
            
            if board["0"] == "O" && board["4"] == "O" && board["8"] == "O" {
                winStr = "Player O Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[0], buttons[4], buttons[8]], color: .systemGreen)
                OnUserWinsFB(player: "O", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                
                return true
            }
            
            // Right Diagonal
            if board["2"] == "X" && board["4"] == "X" && board["6"] == "X" {
                winStr = "Player X Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[2], buttons[4], buttons[6]], color: .systemGreen)
                OnUserWinsFB(player: "X", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                
                return true
            }
            
            if board["2"] == "O" && board["4"] == "O" && board["6"] == "O" {
                winStr = "Player O Wins!"
                
                lightUpButtons(buttonsToHighlight: [buttons[2], buttons[4], buttons[6]], color: .systemGreen)
                OnUserWinsFB(player: "O", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
                
                return true
            }
        }
        
        if playerCounter == maxMoves && winStr == "winner undecided" {
            winStr = "DRAW!"
            
            lightUpButtons(buttonsToHighlight: buttons, color: .systemTeal)
            OnUserWinsFB(player: "DRAW!", board: board, buttons: buttons, checkWin: &checkWin, playerCounter: &playerCounter)
            
            return true
        }
        
        print(gameBoard)
        print(checkWin, winStr)
//        dispatchGroup.leave()
        return false
    }
    
    
    func setButtonTitle(b: [String:String]) {
        for (k, v) in gameBoard {
            boardButtonsArr[Int(k)!].setTitle(v, for: .normal)
        }
    }
    
    func requestCounterFB(completion: @escaping (_ success: Int) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        self.ref.child("room").child(codeToGet).child("counter").observe(.value) { snapshot in
            if snapshot.exists() {
                
                let counter =  snapshot.value as! NSNumber
                
                let n = counter as! Int
//                    print("player counter:", self.playerCounter)
                completion(n)
            }
        }
        
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            print("counter data captured.")
        }
    }
    
    func requestValidMoveFB(index: Int, completion: @escaping (_ success: Bool) -> Void) {
//        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        self.ref.child("room").child(codeToGet).child("board").child("\(index)").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let boardVal = snapshot.value as! NSString
                
                if boardVal == " " {
                    completion(true)
                    // Index is empty
                }
                else {
                    completion(false)
                    // Index is not empty
                }
            }
        }
        
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            print("move data captured.")
        }
    }
    
    func requestBoardFromFB(completion: @escaping (_ success: [String:String]) -> Void) {
        var d = [String:String]()
//        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        self.ref.child("room").child(codeToGet).child("board").observe(.value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    let childSnapshot = child as! DataSnapshot
                    
                    let boardKey = childSnapshot.key as NSString
                    let boardVal = childSnapshot.value as! NSString
                    
                    d[String(boardKey)] = String(boardVal)
                    
                }
                completion(d)
            }
        }
        
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            
            print("board data captured.")
        }
    }
    
    func requestPlayerDetailsFB(completion: @escaping (_ success: [String:String]) -> Void) {
//        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        self.ref.child("room").child(codeToGet).child("players").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                
                let playerInfo =  snapshot.value as! NSDictionary
                
                completion(playerInfo as! [String:String])
            }
        }
        
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            print("player data captured.")
        }
    }
    
    func displayAlertNewGame(user: String) {
        let title = "Would you like to restart?"
        var message = ""
        
        switch user {
        case "hostGame":
            message = "Host would like to restart."
        case "joinGame":
            message = "Guest would like to restart."
            
        default:
            break
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
            self.onUserSelectYesRestart(user: user)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { action in
            self.onUserSelectNoRestart(user: user)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func onUserSelectYesRestart(user: String) {
        var param = [String:Bool]()
        
        switch user {
        case "hostGame":
            param = ["X": true]
        case "joinGame":
            param = ["O": true]
        default:
            break
        }
        
        print("Restart - Yes")
        self.ref.child("room").child(codeToGet).child("restart").updateChildValues(param)
    }
    
    func onUserSelectNoRestart(user: String) {
        var param = [String:Bool]()
        
        switch user {
        case "hostGame":
            param = ["X": false]
        case "joinGame":
            param = ["O": false]
        default:
            break
        }
        
        print("Restart - No")
        self.ref.child("room").child(codeToGet).child("restart").updateChildValues(param)
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    func restartListener(user: String, completion: @escaping (_ success: [String:Bool]) -> Void) {
        var restartDict = [String:Bool]()
        
        dispatchGroup.enter()
        
        self.ref.child("room").child(codeToGet).child("restart").observe(.value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    let childSnapshot = child as! DataSnapshot
                    
                    let player = childSnapshot.key as NSString
                    let restartOpt = childSnapshot.value as! Bool

                    restartDict[String(player)] = restartOpt
                }
            }
            
            completion(restartDict)
        }
        
        
//        restartHandler(restart: restartDict) // this function is not running for some off reason
        // need to make completion handler for the listener function
        
        self.dispatchGroup.leave()
    }
    
    func restartHandler(restart: [String:Bool]) {
        if restart.count == 2{
            if restart["X"]! == true && restart["O"]! == true && segueIDToGet == "hostGame" {
                print("Restarting Game")
                let restart = ["X": false, "O": false]
                
                playerCounter = 0
                checkWin = false
                gameBoard =  createBoardFB()
                
                self.ref.child("room").child(codeToGet).child("board").setValue(gameBoard)
                self.ref.child("room").child(codeToGet).child("counter").setValue(playerCounter)
                self.ref.child("room").child(codeToGet).child("restart").updateChildValues(restart)
                
                setupViewMode(buttons: boardButtonsArr)
                playAgainButtonOutlet.isHidden = true
            }
            
            if restart["X"]! == true && restart["O"]! == true && segueIDToGet == "joinGame" {
                checkWin = false
                setupViewMode(buttons: boardButtonsArr)
                playAgainButtonOutlet.isHidden = true
            }
            else {
                print("do nothing")
            }
        }
        print(restart)
    }
    
    func awaitingPlayersResponse() {
        
    }
    
}
