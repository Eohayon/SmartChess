//
//  ViewController.swift
//  Chess
//
//  Created by Ethan Ohayon on 2020-08-04.
//  Copyright © 2020 Ethan Ohayon. All rights reserved.
//

import UIKit
import CoreBluetooth


let PAWN = 1
let ROOK = 2
let KNIGHT = 3
let BISHOP = 4
let QUEEN = 5
let KING = 6

class ViewController: UIViewController {

    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var recordsButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var boardView: BoardView!
    
    let boardStateCBUUID = CBUUID(string: "FFE1")
    
    var boardStates = [[[Int]]]()
    
    private var manager = BTManager.shared
    private var chessEngine = ChessEngine()
    private var firstStateCorrect = true
    private var wasFlipped = false
    private var attackBegan = false
    private var initialState = [[2,3,4,5,6,4,3,2],
                                [1,1,1,1,1,1,1,1],
                                [0,0,0,0,0,0,0,0],
                                [0,0,0,0,0,0,0,0],
                                [0,0,0,0,0,0,0,0],
                                [0,0,0,0,0,0,0,0],
                                [-1,-1,-1,-1,-1,-1,-1,-1],
                                [-2,-3,-4,-5,-6,-4,-3,-2]]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        manager.setPeripheralDelegate(self)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
}

extension ViewController {
        
    @IBAction func confirmPressed(sender: UIButton) {
        if (manager.getCharacteristic() != nil) {
            manager.sendMessage(SEND_BOARD_STATE_CODE, manager.getCharacteristic()!, .withoutResponse)
        }
    }
    
    @IBAction func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
    if gesture.direction == UISwipeGestureRecognizer.Direction.right {
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController!.view.layer.add(transition, forKey: nil)
        let writeView : HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! HomeViewController
        self.navigationController?.pushViewController(writeView, animated: false)
        boardStates = [[[Int]]]()
        }
    }
    
    func updateBoard(state: [[Int]]) {
        chessEngine.updateGame(state, boardStates)
        boardView.pieces = chessEngine.pieces
        boardView.setNeedsDisplay()
    }
    
    func inferBoardState(rawState: [[Int]]) -> [[Int]] {
        var inferredState = [[Int]]()
        var rawState = rawState
        var movedPieces = [Piece]()
        let isWhiteTurn = (boardStates.count % 2 == 1)
        
        if wasFlipped {
            rawState = inferSides(movedPiece: Piece(value: 1, X1: 0, Y1: 0, X2: 0, Y2: 0), inferred: rawState)
        }
        
        if boardStates.count == 0 {
            inferredState = inferInitialState(state: rawState)
            if firstStateCorrect == false {
                updateBoard(state: inferredState)
                inferredState = []
            }
        } else {
            inferredState = rawState
            let previousState = boardStates[boardStates.count-1]
            
            //pieces disappeared
            for i in (0...7) {
                for j in 0...7 {
                    
                    if (rawState[i][j] != 0) {
                        inferredState[i][j] = previousState[i][j]
                    }
                    
                    if (rawState[i][j] == 0 && previousState[i][j] != 0) {
                        movedPieces.append(Piece(value: previousState[i][j], X1: j, Y1: i, X2: 0, Y2: 0))
                    }
                }
            }
            
            var disappearedNum = movedPieces.count
                        
            var movesNum = 0
            //pieces appeared
            for i in (0...7) {
                for j in 0...7 {
                    
                    if (rawState[i][j] != 0) {
                        inferredState[i][j] = previousState[i][j]
                    }
                    
                    if (rawState[i][j] != 0 && previousState[i][j] == 0) {
                        movedPieces[movesNum].X2 = j
                        movedPieces[movesNum].Y2 = i
                        inferredState[i][j] = movedPieces[movesNum].value
                        movesNum = movesNum + 1
                    }
                }
            }
            
            disappearedNum = disappearedNum - movesNum
            
            if (attackBegan) {
                
            }
                   
            if (disappearedNum == 2) {
                updateBoard(state: inferredState)
                attackBegan = true
                return [[4]]
            }
            
            if movedPieces.count > 2 {
                return [[1]]
            }
            
            if boardStates.count == 1 && movedPieces.count != 0 {
                inferredState = inferSides(movedPiece: movedPieces[0], inferred: inferredState)
            }
            
            if inferredState == previousState {
                return [[3]]
            }
            
            if (isMoveAllowed(state: inferredState, piece: movedPieces[0], isWhiteTurn: isWhiteTurn) == false) || (disappearedNum != 0) {
                return [[1]]
            }
            
            if !isWhiteTurn && movedPieces[movedPieces.count-1].value < 0 && boardStates.count != 1 {
                return [[2]]
            } else if isWhiteTurn && movedPieces[movedPieces.count-1].value > 0 && boardStates.count != 1 {
                return [[2]]
            }
        }
        return inferredState
    }
    
    fileprivate func isLegalPawnMove(_ state: [[Int]], _ piece: Piece, _ deltaX: Int, _ deltaY: Int) -> Bool {
        
        var path = [Int]()
                        
        for i in 0...7 {
            path.append(boardStates[boardStates.count-1][i][piece.X1])
        }

        switch deltaY {
        case -2:
            if path[piece.Y1 - 1] != 0 {
                return false
            }
        case 2:
            if path[piece.Y1 + 1] != 0 {
                return false
            }
        default:
            break
        }
        
        if deltaX != 0 {
            return false
        }
        
        if (piece.value > 0 && deltaY < 0) {

            return false
        }
        
        if (piece.value < 0 && deltaY > 0) {

            return false
        }
        
        if (abs(deltaY) == 1) {
            return true
        } else if abs(deltaY) == 2 && (piece.Y1 == 1 || piece.Y1 == 6) {
            return true
        }
        return false
    }
    
    fileprivate func isLegalRookMove(_ piece: Piece, _ deltaX: Int, _ deltaY: Int) -> Bool {
        
        if deltaX == 0 && deltaY != 0 {
            for i in 1...abs(deltaY)-1 {
                if (boardStates[boardStates.count-1][piece.Y1 + (deltaY > 0 ? i : -i)][piece.X1] != 0) {
                    return false
                }
            }
            return true
        } else if deltaX != 0 && deltaY == 0 {
             for i in 1...abs(deltaX)-1 {
               if (boardStates[boardStates.count-1][piece.Y1][piece.X1 + (deltaX > 0 ? i : -i)] != 0) {
                   return false
               }
           }
           return true
        } else {
            return false
        }
    }
    
    fileprivate func isLegalKnightMove(_ piece: Piece, _ deltaX: Int, _ deltaY: Int) -> (Bool) {
        if (abs(deltaX) == 1 && abs(deltaY) == 2) {
            return true
        } else if (abs(deltaX) == 2 && abs(deltaY) == 1) {
            return true
        }
        
        return false
    }
    
    fileprivate func isLegalBishopMove(_ piece: Piece, _ deltaX: Int, _ deltaY: Int) -> Bool {
        if abs(deltaX) == abs(deltaY) {
            for i in 1...abs(deltaY)-1 {
                if (boardStates[boardStates.count-1][piece.Y1 + (deltaY > 0 ? i : -i)][piece.X1 + (deltaX > 0 ? i : -i)] != 0) {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isLegalQueenMove(_ piece: Piece, _ deltaX: Int, _ deltaY: Int) -> (Bool) {
        return (isLegalBishopMove(piece, deltaX, deltaY) || isLegalRookMove(piece, deltaX, deltaY))
    }
    
    fileprivate func isLegalKingMove(_ piece: Piece, _ deltaX: Int, _ deltaY: Int) -> Bool {
        if (deltaX > 1 || deltaY > 1) {
            return false
        }
        
        if (deltaX == 0 || deltaY == 0) {
            return true
        } else if (abs(deltaX) == abs(deltaY)) {
            return true
        }
        
        return false
    }
    
    func isMoveAllowed(state: [[Int]], piece: Piece, isWhiteTurn: Bool) -> Bool {
        
        let deltaX = piece.X2 - piece.X1
        let deltaY = piece.Y2 - piece.Y1
        
        
        if (piece.X2 == 0 && piece.Y2 == 0 && ((piece.value > 0 && isWhiteTurn) || (piece.value < 0 && !isWhiteTurn))) {
            return true
        }
        
        switch abs(piece.value) {
        case PAWN:
            return isLegalPawnMove(state, piece, deltaX, deltaY)
        case ROOK:
            return isLegalRookMove(piece, deltaX, deltaY)
        case KNIGHT:
            return isLegalKnightMove(piece, deltaX, deltaY)
        case BISHOP:
            return isLegalBishopMove(piece, deltaX, deltaY)
        case QUEEN:
            return isLegalQueenMove(piece, deltaX, deltaY)
        case KING:
            return isLegalKingMove(piece, deltaX, deltaY)
        default:
            break
        }
        return true
    }
    
    func inferInitialState(state: [[Int]]) -> [[Int]] {
        var inferredState = state
        
        for i in 1...8 {
            for j in 1...8 {
                if state[i-1][j-1] != 1 && (i <= 2 || i >= 7) {
                    errorText.text = ("Adjust Missing Piece")
                    firstStateCorrect = false
                } else {
                    switch (i, j) {
                    case (1,1), (1,8):
                    inferredState[i-1][j-1] = ROOK
                    case (1,2), (1,7):
                    inferredState[i-1][j-1] = KNIGHT
                    case (1,3), (1,6):
                    inferredState[i-1][j-1] = BISHOP
                    case (1,4):
                    inferredState[i-1][j-1] = QUEEN
                    case (1,5):
                    inferredState[i-1][j-1] = KING
                    case (7, 1), (7, 2), (7, 3), (7, 4), (7, 5), (7, 6), (7, 7), (7, 8):
                    inferredState[i-1][j-1] = -PAWN
                    case (8,1), (8,8):
                    inferredState[i-1][j-1] = -ROOK
                    case (8,2), (8,7):
                    inferredState[i-1][j-1] = -KNIGHT
                    case (8,3), (8,6):
                    inferredState[i-1][j-1] = -BISHOP
                    case (8,4):
                    inferredState[i-1][j-1] = -QUEEN
                    case (8,5):
                    inferredState[i-1][j-1] = -KING
                    default:
                    break
                    }
                }
            }
        }
        
        if inferredState == initialState {
            firstStateCorrect = true
            errorText.text = ("White make a move")
        }
        return inferredState
    }
    
    func inferSides(movedPiece: Piece, inferred: [[Int]]) -> [[Int]] {
        var arr = inferred
    
        if (movedPiece.value >= 0) {
            wasFlipped = true
            
            arr = arr.reduce([],{ [$1] + $0 })
            
            for i in 0...7 {
                arr[i] = (arr[i].reduce([],{ [$1] + $0 }))
            }
            
            for i in 0...7 {
                for j in 0...7 {
                    arr[i][j] = -arr[i][j]
                    
                    if (boardStates.count == 1) {
                        switch (arr[i][j]) {
                        case QUEEN:
                            arr[i][j] = KING
                        case KING:
                            arr[i][j] = QUEEN
                        case -QUEEN:
                            arr[i][j] = -KING
                        case -KING:
                            arr[i][j] = -QUEEN
                        default:
                            break
                        }
                    }
                }
            }
        }
        return arr
    }
}

extension ViewController: CBPeripheralDelegate, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
              case .unknown:
                print("central.state is .unknown")
              case .resetting:
                print("central.state is .resetting")
              case .unsupported:
                print("central.state is .unsupported")
              case .unauthorized:
                print("central.state is .unauthorized")
              case .poweredOff:
                print("central.state is .poweredOff")
              case .poweredOn:
                print("central.state is .poweredOn")
                manager.scan()
            @unknown default:
                break
        }
    }
    
//onDevicesDiscovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any],rssi RSSI: NSNumber) {
        if peripheral.name == "SmartChess" {
            print("\nDevice Name: ", peripheral.name!)
            print("UUID", peripheral.identifier)
            manager.setPeripheral(peripheral)
            manager.setPeripheralDelegate(self)
            manager.stopScan()
            manager.connect()
        }
    }
        
//onConnect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
                
        print("\nDevice Connected\n")
        manager.discoverServices(nil)
    }
    
//onDisconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        manager.connect()
    }
    
//onCharacteristicsDiscovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }

        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
//onPropertiesDiscovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            manager.setCharacteristic(characteristic)
            if characteristic.properties.contains(.read) {
                print("\n\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify\n")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

// OnMessageReceived
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Message Recieved")
        switch characteristic.uuid {
            case boardStateCBUUID:
            let characteristicData = characteristic.value
            let byteArray = [UInt8](characteristicData!)
            var boardState = [[Int]]()
                
            for byte in byteArray {

                if byteArray.count > 6 {
                    let num = (String(byte, radix: 2))
                    let arr = num.utf8.map{Int(($0 as UInt8)) - 48}

                    boardState.append(arr)
                }
            }

            if boardState.count == 8 {
                for i in 0...7 {
                    if boardState[i].count < 8 {
                        for _ in 0...(7 - boardState[i].count) {
                            boardState[i].insert(0, at: 0)
                        }
                    }
                }
                
                let inferred = inferBoardState(rawState: boardState)
                
                switch inferred {
                case []:
                    peripheral.writeValue(ERROR_CODE, for: characteristic, type: .withoutResponse)
                    errorText.text = ("ERROR")
                case [[1]]:
                    peripheral.writeValue(ERROR_CODE, for: characteristic, type: .withoutResponse)
                    errorText.text = ("ERROR: Illegal move")
                case [[2]]:
                    peripheral.writeValue(ERROR_CODE, for: characteristic, type: .withoutResponse)
                    errorText.text = ("ERROR: Not your turn")
                case [[3]]:
                    peripheral.writeValue(ERROR_CODE, for: characteristic, type: .withoutResponse)
                    errorText.text = ("ERROR: Player must make a move")
                case [[4]]:
                    peripheral.writeValue(GOOD_MOVE_CODE, for: characteristic, type: .withoutResponse)
                    errorText.text = ("Place the attacking piece")
                default:
                    boardStates.append(inferred)
                    peripheral.writeValue(GOOD_MOVE_CODE, for: characteristic, type: .withoutResponse)
                    updateBoard(state: inferred)
                    if (boardStates.count > 1) {
                        switch boardStates.count % 2 {
                        case 0:
                            errorText.text = ("Black make a move")
                        default:
                            errorText.text = ("White make a move")
                        }
                    }
                }
            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
}

struct Piece {
    var value: Int
    var X1: Int
    var Y1: Int
    var X2: Int
    var Y2: Int
}
