//
//  GamePageViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 4/5/21.
//

import UIKit

class GamePageViewController: UIViewController {
    var playerCounter = 0
    var gameBoard = [Int:String]()
    
    var buttonsArr = [UIButton]()
    var boardButtonsArr = [UIButton]()

    var checkWin = false
    let maxMoves = 8
    
    var winStr = " "
    
    let players = [
        "0" : "X",
        "1" : "O"
    ]
    
    var playerXWins = 0
    var PlayerOWins = 0
    
    // X and O Button Outlets
    @IBOutlet weak var button0Outlet: UIButton!
    @IBOutlet weak var button1Outlet: UIButton!
    @IBOutlet weak var button2Outlet: UIButton!
    @IBOutlet weak var button3Outlet: UIButton!
    @IBOutlet weak var button4Outlet: UIButton!
    @IBOutlet weak var button5Outlet: UIButton!
    @IBOutlet weak var button6Outlet: UIButton!
    @IBOutlet weak var button7Outlet: UIButton!
    @IBOutlet weak var button8Outlet: UIButton!
    
    // Other Button Outlets
    @IBOutlet weak var playAgainButtonOutlet: UIButton!
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
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

        gameBoard = createBoard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        case 0...8:
            self.placeMove(player: playerCounter % 2, index: sender.tag)
        case 9:
            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
        case 11:
            self.dismiss(animated: true, completion: nil)
        default:
            print("Do Nothing")
            break
        }
    }
    
    func placeMove(player: Int, index: Int) {
        if isMoveValid(board: gameBoard, index: index) {
            gameBoard[index] = players["\(player)"]!
            
//            checkWin = checkWin(board: &gameBoard, checkWin: &checkWin, playerCounter: &playerCounter, buttons: boardButtonsArr)
            
            boardButtonsArr[index].setTitle("\(players["\(player)"]!)", for: .normal)
            
            playerCounter += 1
            
            checkWin = checkWin(board: &gameBoard, checkWin: &checkWin, playerCounter: &playerCounter, buttons: boardButtonsArr)
            
            print("\(gameBoard), player : \(player), button index : \(index), move counter: \(playerCounter)")
        }
        
        else {
            displayAlert(title: "Move Invalid!", message: "Please Try Another Move!")
        }
    }
}
