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
        if cpuModeSegmentedControlOutlet.selectedSegmentIndex == 0 {
            selectedMode = 0
            print("Easy - Selected Index: \(selectedMode)")

            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)

        }
        else {
            selectedMode = 1
            print("Easy - Selected Index: \(selectedMode)")

            resetGame(board: &gameBoard, buttons: boardButtonsArr, checkWin: &checkWin, playerCounter: &playerCounter)
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

            timer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [self] (timer) in
                cpuMove(board: &gameBoard, counter: playerCounter % 2, mode: selectedMode)
            }

//            enableButtons(buttons: buttonsArr)

            printGameDetails(board: gameBoard, player: player, counter: playerCounter, index: index)

            timer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [self] (timer) in
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
    func hardModeSelectMissingKeys(prevIndex: Int, b: [Int:String]) -> Int {
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

    func cpuMove(board: inout [Int:String], counter: Int, mode: Int) {
        var move = 0

        if counter % 2 == 1 {
            if mode == 0  {
                move = selectFromMissingKeys(d: board)
            }
            else {
                move = hardModeSelectMissingKeys(prevIndex: userPrevIndex, b: board)
                print(move)
            }
            
            if move >= 0 && move <= 8 {
                board[move] = "O"

                boardButtonsArr[move].setTitle(("O"), for: .normal)

                playerCounter += 1
            }

        }
    }
}
