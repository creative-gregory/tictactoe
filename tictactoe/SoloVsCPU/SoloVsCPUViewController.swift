//
//  SoloVsCPUViewController.swift
//  tictactoe
//
//  Created by Gregory Hagins II on 4/8/21.
//

import UIKit

class SoloVsCPUViewController: UIViewController {
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
    
    var cpuMove:Int!
    
    var timer:Timer?
    
    var selectedMode = 0
    var userPrevIndex = 0
    
    let defaults = UserDefaults.standard
    
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
    
    @IBOutlet weak var playAgainButtonOutlet: UIButton!
    @IBOutlet weak var backButtonOutlet: UIButton!
    
    @IBOutlet weak var cpuModeSegmentedControlOutlet: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        defaults.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
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
    
    // changes color scheme based on the current viewmode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            print("View Mode Changed")
            
            setupViewMode(buttons: buttonsArr)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cpuModeSegmentedControl(_ sender: Any) {
        switch cpuModeSegmentedControlOutlet.selectedSegmentIndex {
        case 0:
            selectedMode = 0
            print("Easy - Selected Index: \(selectedMode)")
            
            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
            
        case 1:
            selectedMode = 1
            print("Medium - Selected Index: \(selectedMode)")
            
            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
        case 2:
            selectedMode = 2
            print("Hard - Selected Index: \(selectedMode)")
            
            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
        case 3:
            selectedMode = 3
            print("Impossible - Selected Index: \(selectedMode)")
            
            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
        default:
            break
            
        }
        //        if cpuModeSegmentedControlOutlet.selectedSegmentIndex == 0 {
        //            selectedMode = 0
        //            print("Easy - Selected Index: \(selectedMode)")
        //
        //            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
        //
        //        }
        //        else if cpuModeSegmentedControlOutlet.selectedSegmentIndex == 1 {
        //            selectedMode = 1
        //            print("Medium - Selected Index: \(selectedMode)")
        //
        //            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
        //        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func placeMove(player: Int, index: Int) {
        if isMoveValid(board: gameBoard, index: index) && player == 0 {
            userPrevIndex = index
            gameBoard[index] = players["\(player)"]!
            
            boardButtonsArr[index].setTitle("\(players["\(player)"]!)", for: .normal)
            
            checkWin = checkWin(board: &gameBoard, checkWin: &checkWin, playerCounter: &playerCounter, buttons: boardButtonsArr)
            
            playerCounter += 1
        }
        
        printGameDetails(board: gameBoard, player: player, counter: playerCounter, index: index)
        
        print(userPrevIndex)
        
        if checkWin ==  false {
            disableButtons(buttons: boardButtonsArr)
            
            timer =  Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] (timer) in
                checkWin = checkWin(board: &gameBoard, checkWin: &checkWin, playerCounter: &playerCounter, buttons: boardButtonsArr)
            }
            
            timer =  Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] (timer) in
                cpuMove(board: &gameBoard, counter: playerCounter % 2, mode: selectedMode, checkWin: checkWin)
            }
            
            //            enableButtons(buttons: buttonsArr)
            
            printGameDetails(board: gameBoard, player: player, counter: playerCounter, index: index)
            
            timer =  Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] (timer) in
                checkWin = checkWin(board: &gameBoard, checkWin: &checkWin, playerCounter: &playerCounter, buttons: boardButtonsArr)
            }
            
            enableButtons(buttons: boardButtonsArr)
        }
    }
    
    // Might need to add a timer to slow down cpu's move, might skip or override the players move
    func selectFromMissingKeys(d: [Int:String]) -> Int {
        var availableKeys = [Int]()
        var key = 0
        
        for (key, value) in d {
            if value == " " {
                availableKeys.append(key)
            }
        }
        
        if availableKeys.count > 0 {
            key = availableKeys.sorted().randomElement()!
        }
        
        print(availableKeys)
        
        if availableKeys.isEmpty {
            // if no keys are here, exit function
            return -1  // find a better to error handle nil/empty array results
        }
        
        return key
    }
    
    func removeRedundantSetPossiblities(possible: Set<Int>, available: Set<Int>) -> Set<Int> {
        var choices = Set<Int>()
        
        for i in possible {
            if available.contains(i) {
                choices.insert(i)
            }
        }
        
        return choices
    }
    
    // Work on predictive analysis alorithm
    func mediumSelectMissingKeys(prevIndex: Int, b: [Int:String]) -> Int {
        var availableKeys = Set<Int>()
        
        for (k, v) in b {
            if v == " " {
                availableKeys.insert(k)
            }
        }
        
        print(availableKeys)
        
        if availableKeys.count <= 0 {
            return 10
        }
        
        if availableKeys.contains(4) && availableKeys.count > 0 {
            print(availableKeys.contains(4))
            
            return 4
        }
        
        if !availableKeys.contains(4) && availableKeys.count > 0 {
            switch prevIndex {
            case 0:
                var possibleMove:Set = [1, 3]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    // subset does not include any elements if one is not is the subset
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 1:
                var possibleMove:Set = [0, 2]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 2:
                var possibleMove:Set = [1, 5]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 3:
                var possibleMove:Set = [0, 6]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 4:
                var possibleMove:Set = [1, 3, 5, 7]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 5:
                var possibleMove:Set = [2, 8]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 6:
                var possibleMove:Set = [3, 7]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 7:
                var possibleMove:Set = [6, 8]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            case 8:
                var possibleMove:Set = [5, 7]
                possibleMove = removeRedundantSetPossiblities(possible: possibleMove, available: availableKeys)
                
                if possibleMove.count == 0 {
                    print("None of the following moves are available: \(possibleMove)")
                    return availableKeys.randomElement()!
                }
                else {
                    print("All or Some of the following moves are available: \(possibleMove)")
                    return availableKeys.intersection(possibleMove).randomElement()!
                }
            default:
                break
            }
        }
        
        return 10
    }
    
    func cpuMove(board: inout [Int:String], counter: Int, mode: Int, checkWin: Bool) {
        var move = 0
        
        if (counter % 2 == 1) && !checkWin {
            switch mode{
            case 0:
                move = selectFromMissingKeys(d: board)
            case 1:
                move = mediumSelectMissingKeys(prevIndex: userPrevIndex, b: board)
            case 2:
                move = minimaxCPUMove(board: &board)
            case 3:
                print("coming soon")
            default:
                break
            }
            
            if (move >= 0 && move <= 8) && isMoveValid(board: board, index: move) {
                board[move] = "O"
                
                boardButtonsArr[move].setTitle(("O"), for: .normal)
                
                playerCounter += 1
            }
            
        }
    }
    
    func minimaxCPUMove(board: inout [Int:String]) -> Int {
        var bestScore = Int.min
        var bestMove = 0
        
        for i in 0..<9 {
            if isMoveValid(board: board, index: i) {
                board[i] = "O"
                let score = minimax(board: &board, depth: 0, isMaximizing: false, alpha: Int.min, beta: Int.max)
                board[i] = " "
                
                if score > bestScore {
                    bestScore = score
                    bestMove = i
                }
            }
        }
        
        print("BEST MOVE: \(bestMove)")
        return bestMove
    }
    // Add medium and extra hard mode (where x is the cpu or o is cpu and goes first)
    // maybe need to add a parameter to toggle the x or o
    func minimax(board: inout [Int:String], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int) -> Int {
        let scores = [
            "O": 1,
            "X": -1,
            "draw": 0
        ]
        
        let result = checkWinCPU(board: board, depth: depth)
        
        if result != "" {
            return scores[result]!
        }
        
        if isMaximizing {
            var bestScore = Int.min
            
            for i in 0..<9 {
                if isMoveValid(board: board, index: i) {
                    board[i] = "O"
                    let score = minimax(board: &board, depth: depth + 1, isMaximizing: false, alpha: alpha, beta: beta)
                    board[i] = " "
                    
                    bestScore = max(score, bestScore)
                    let alpha = max(bestScore, alpha)
                    
                    if beta <= alpha {
                        break
                    }
                }
            }
            
            return bestScore
        }
        
        else {
            var bestScore = Int.max
            
            for i in 0..<9 {
                if isMoveValid(board: board, index: i) {
                    board[i] = "X"
                    let score = minimax(board: &board, depth: depth + 1, isMaximizing: true, alpha: alpha, beta: beta)
                    board[i] = " "
                    
                    bestScore = min(score, bestScore)
                    
                    let beta = min(beta, bestScore)
                    if beta <= alpha {
                        break
                    }
                }
            }
            
            return bestScore
        }
    }
    
    func checkWinCPU(board: [Int:String], depth: Int) -> String {
        // Horizontal Win
        for i in stride(from: 0, through: 6, by: 3) {
            if board[i] == "X" && board[i + 1] == "X" && board[i + 2] == "X" {
                return "X"
            }
            
            if board[i] == "O" && board[i + 1] == "O" && board[i + 2] == "O" {
                return "O"
            }
        }
        
        //Vertical Win
        for i in stride(from: 0, to: 3, by: 1) {
            if board[i] == "X" && board[i + 3] == "X" && board[i + 6] == "X" {
                return "X"
            }
            
            if board[i] == "O" && board[i + 3] == "O" && board[i + 6] == "O" {
                return "O"
            }
        }
        
        // Left Diagonal
        if board[0] == "X" && board[4] == "X" && board[8] == "X" {
            return "X"
        }
        
        if board[0] == "O" && board[4] == "O" && board[8] == "O" {
            return "O"
        }
        
        // Right Diagonal
        if board[2] == "X" && board[4] == "X" && board[6] == "X" {
            return "X"
        }
        
        if board[2] == "O" && board[4] == "O" && board[6] == "O" {
            return "O"
        }
        
        for i in 0..<9 {
            if board[i] == " " {
                return ""
            }
        }
        
        return "draw"
    }
}
