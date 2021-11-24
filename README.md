# SmartChess

## Motivation

In my household, I am the only individual who enjoys playing Chess. Chess is an extremely strategic game that is completely void of luck, unlike Backgammon, Monopoly, etc. When playing Chess online, the feel of the game is completely different, although I can see all of the pieces clearly, I find myself missing things more often, and overall my level of play is far worse. I decided to solve this problem by building a Chessboard that would both attract the attention of my family and allow me to play alone on a physical board. 

## Overview

SmartChess is an electronic Chessboard that utilizes an integrated circuit to recognize where pieces are located on the board, and then sends that information to an accompanying app that can give the user a visualization of the board. The app can give hints, can record games, enforces move legality, and is currently in development to allow the user to play against an AI.

 <img src="https://github.com/sohayon123/SmartChess/blob/master/Pictures/IMG_8273.jpg?raw=true" width="45%" height="45%"> <img src="https://github.com/sohayon123/SmartChess/blob/master/Pictures/IMG_8272.jpg?raw=true" width="45%" height="45%">


## Circuit Design Process

Before designing the physical board, the internal circuit was created. An 8x8 matrix of reed switches was soldered together to create the logic circuit for piece detection. This circuit was connected to the digital IO of an Arduino microcontroller, the rows connected as inputs and the columns as outputs. The Bluetooth module and other miscellaneous components were then soldered to the Arduino as well. Arduino C code was then created to allow the Chessboard to function as intended as a Bluetooth peripheral to an iOS app (Swift).

 <img src="https://github.com/sohayon123/SmartChess/blob/master/Pictures/matrix.jpeg?raw=true" width="45%" height="45%"> <img src="https://github.com/sohayon123/SmartChess/blob/master/Pictures/IMG_8186.jpg?raw=true" width="45%" height="45%">
 
 
## Mechanical Process

The board was built from scratch; the frame was built from walnut wood, and the board itself from a combination of walnut and maple. It was designed in such a way that the components of the circuit could be removed if need be. The board had to be made from quarter inch wood in order to allow magnetic fields to be detected by the reed switches beneath it.

After completing the woodworking of the actual board, custom pieces were also built, and magnets were integrated into the bottom of each piece.

## Mobile App

After building the hardware, the next step was to build an app that could make use of the data provided by the logic circuit of the Chessboard. An iPhone app was written in Swift with the purpose of connecting with this Chessboard and receiving the board’s state via Bluetooth. With the information that the app receives via Bluetooth it is able to check move legality and prohibit certain moves (changing an LED on the board), to provide hints to a user, and to record games.

 <img src="https://github.com/sohayon123/SmartChess/blob/master/Pictures/App1.png?raw=true" width="45%" height="45%"> <img src="https://github.com/sohayon123/SmartChess/blob/master/Pictures/App2.png?raw=true" width="45%" height="45%">

### In this repository you will find pictures, code, CAD files and renderings. If you have any questions, please let me know.
