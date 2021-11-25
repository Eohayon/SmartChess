# SmartChess

## Motivation

In my household, I am the only individual who enjoys playing Chess. Chess is an extremely strategic game that is completely void of luck, unlike many other boardgames. When playing Chess online, the feel of the game is completely different. Although I can see all of the pieces clearly, I find myself missing things more often, and overall my level of play is far worse. I have also asked many individuals why they do not play chess, and the answer I most often recieve is that it is too intimidating and the rules are easy to forget. I decided to solve these issues by creating a smart Chessboard that would allow physical play against a computer player, and make the game more intuitive for those that find chess intimidating.
## Overview

SmartChess is a Bluetooth enabled, smart Chessboard. SmartChess utilizes an integrated circuit to recognize where there are pieces on the board. That information is sent to the accompanying app, which provides the user with a live view of the board. The app can give hints, recommend moves, and enforces legal moves. Development of a mode allowing play against an AI is in progress.

 <img src="https://github.com/Eohayon/SmartChess/blob/main/Pictures/45DEG.jpg" width="45%" height="45%"> <img src="https://github.com/Eohayon/SmartChess/blob/main/Pictures/TOP.jpg" width="45%" height="45%">


## Circuit Design Process

Before building the board and frame, the internal circuit was created. An 8x8 matrix of reed switches was soldered together, creating a logic circuit to detect magnetic pieces. This circuit, along with the Bluetooth module, and various other components, were soldered to the Arduino. C code was written for the Chessboard to function properly as a Bluetooth peripheral for the iOS app.

 <img src="https://github.com/Eohayon/SmartChess/blob/main/Pictures/MATRIX.jpeg" width="45%" height="45%"> <img src="https://github.com/Eohayon/SmartChess/blob/main/Pictures/ARDUINO.jpg" width="45%" height="45%">
 
 
## Mechanical Process

The entire board was handcrafted. The frame was built from walnut wood, and the board was built from a combination of walnut and maple. The board was made from 1/4” wood to allow the pieces to be detected by the reed matrix beneath it. The frame was designed in a way that allows for easy disassembly and repair. The pieces were designed to be recognizable, yet modern and refreshing. Each piece was fully handmade.

## Mobile App

After building the board, I had to create an app that would make use of the raw data, and be intuitive for users. An iPhone app was written in Swift. The app connects the user to the board and receives the state of the board when a move is made. The app checks legality of moves, provides the user with hints, and records games for future reference. The app also allows the user to play against a computer player. The AI generates enemy moves using Stockfish (an open source chess engine). The enemy moves are displayed on the app and the player then moves the piece. This will allow players to play single player chess on a physical chessboard.

 <img src="https://github.com/Eohayon/SmartChess/blob/main/Pictures/APP1.png" width="45%" height="45%"> <img src="https://github.com/Eohayon/SmartChess/blob/main/Pictures/APP2.png" width="45%" height="45%">

### In this repository you will find pictures, code, CAD files and renderings. If you have any questions, please let me know.
