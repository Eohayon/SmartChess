//
//  BoardView.swift
//  Chess
//
//  Created by Ethan Ohayon on 2020-08-10.
//  Copyright © 2020 Ethan Ohayon. All rights reserved.
//

import Foundation
import UIKit

class BoardView: UIView {
    
    var pieces = Set<ChessPiece>()

    override func draw(_ rect: CGRect) {
        drawBoard()
        drawPieces()
    }
    
    func drawBoard() {
        
        for i in 0...7 {
            for j in 0...3 {
                let y = (CGFloat)(i) * 41.25

                var lightX: CGFloat
                var darkX: CGFloat

                if i % 2 == 0 {
                    darkX = 41.25 + (CGFloat)(j) * 82.5
                    lightX = (CGFloat)(j) * 82.5
                } else {
                    darkX = (CGFloat)(j) * 82.5
                    lightX = 41.25 + (CGFloat)(j) * 82.5
                }
                
                drawLight(x: lightX, y: y)
                drawDark(x: darkX, y: y)

            }
        }
    }
    
    func drawPieces() {
        for piece in pieces {
            let pieceImage = UIImage(named: piece.img)
            pieceImage?.draw(in: CGRect(x: Double(piece.col) * 41.25, y: Double(piece.row) * 41.25, width: 41.25, height: 41.25))
        }
    }
    
    func drawLight(x: CGFloat, y: CGFloat) {
        let path = UIBezierPath(rect: CGRect(x: x, y: y, width: 41.25, height: 41.25))
        UIColor(red: 202/255, green: 164/255, blue: 114/255, alpha: 1).setFill()
        path.fill()
    }
    func drawDark(x: CGFloat, y: CGFloat) {
        let path = UIBezierPath(rect: CGRect(x: x, y: y, width: 41.25, height: 41.25))
        UIColor(red: 93/255, green: 67/255, blue: 44/255, alpha: 1).setFill()
        path.fill()
    }
    
}
