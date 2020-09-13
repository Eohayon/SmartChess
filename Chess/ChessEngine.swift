//
//  ChessEngine.swift
//  Chess
//
//  Created by Ethan Ohayon on 2020-08-10.
//  Copyright © 2020 Ethan Ohayon. All rights reserved.
//

import Foundation

struct ChessEngine {
    
    var pieces = Set<ChessPiece>()
    let PAWN_BLACK = "Pawn_Black"
    let ROOK_BLACK = "Rook_Black"
    let KNIGHT_BLACK = "Knight_Black"
    let BISHOP_BLACK = "Bishop_Black"
    let QUEEN_BLACK = "Queen_Black"
    let KING_BLACK = "King_Black"
    let PAWN_WHITE = "Pawn_White"
    let ROOK_WHITE = "Rook_White"
    let KNIGHT_WHITE = "Knight_White"
    let BISHOP_WHITE = "Bishop_White"
    let QUEEN_WHITE = "Queen_White"
    let KING_WHITE = "King_White"

    mutating func updateGame (_ state: [[Int]], _ boardStates: [[[Int]]]) {
        pieces.removeAll()
        var state = state
        
        if boardStates.count == 0 {
             for i in 0...7 {
                for j in 0...7 {
                    if i > 1 && i < 6 {
                        state[i][j] = 0
                    }
                }
            }
        }

        
        for i in 0...7 {
            for j in 0...7 {
                if state != [[]] && state != [[1]] && state != [[2]] && state != [[3]] {
                    switch state[i][j] {
                    case PAWN:
                        pieces.insert(ChessPiece(col: j, row: i, img: PAWN_BLACK))
                    case ROOK:
                        pieces.insert(ChessPiece(col: j, row: i, img: ROOK_BLACK))
                    case KNIGHT:
                        pieces.insert(ChessPiece(col: j, row: i, img: KNIGHT_BLACK))
                    case BISHOP:
                        pieces.insert(ChessPiece(col: j, row: i, img: BISHOP_BLACK))
                    case QUEEN:
                        pieces.insert(ChessPiece(col: j, row: i, img: QUEEN_BLACK))
                    case KING:
                        pieces.insert(ChessPiece(col: j, row: i, img: KING_BLACK))
                    case -PAWN:
                        pieces.insert(ChessPiece(col: j, row: i, img: PAWN_WHITE))
                    case -ROOK:
                        pieces.insert(ChessPiece(col: j, row: i, img: ROOK_WHITE))
                    case -KNIGHT:
                        pieces.insert(ChessPiece(col: j, row: i, img: KNIGHT_WHITE))
                    case -BISHOP:
                        pieces.insert(ChessPiece(col: j, row: i, img: BISHOP_WHITE))
                    case -QUEEN:
                        pieces.insert(ChessPiece(col: j, row: i, img: QUEEN_WHITE))
                    case -KING:
                        pieces.insert(ChessPiece(col: j, row: i, img: KING_WHITE))
                    default:
                        break
                    }
                }
            }
        }
    }
}
