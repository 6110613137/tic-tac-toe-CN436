//
//  ContentView.swift
//  Tic Tac Toe
//
//  Created by Kunatip Satsomnuk on 28/8/2564 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameBoardDisabled = false
    @State private var alertItem: AlertItem?
    @State private var isHumanFirst = true
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns : [GridItem(), GridItem(), GridItem()]) {
                ForEach(0..<9) { i in
                    ZStack {
                        Color.yellow
                            .opacity(0.5)
                            .frame(width: blockSize(), height: blockSize())
                        
                        Image(systemName: moves[i]?.mark ?? "xmark.circle")
                            .resizable()
                            .frame(width: markSize(), height: markSize())
                            .foregroundColor(.black)
                            .opacity(moves[i] == nil ? 0 : 1)
                            .animation(moves[i] == nil ? nil : .spring())
                    }
                    .onTapGesture {
                        if isBlockOccipied(in: moves, forIndex: i) { return }
                        
                        moves[i] = Move(player: .human, boardIndex: i)
                        
                        if checkWinCondition(for: .human, in: moves) {
                            isHumanFirst.toggle()
                            alertItem = AlertContext.humanWin
                            return
                        }
                        
                        if checkDrawCondition(in: moves) {
                            isHumanFirst.toggle()
                            alertItem = AlertContext.draw
                            return
                        }
                        
                        isGameBoardDisabled.toggle()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let computerPosition = determineComputerMove(in: moves)
                            
                            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                            isGameBoardDisabled.toggle()
                            
                            if checkWinCondition(for: .computer, in: moves) {
                                isHumanFirst.toggle()
                                alertItem = AlertContext.computerWin
                                return
                            }
                            
                            if checkDrawCondition(in: moves) {
                                isHumanFirst.toggle()
                                alertItem = AlertContext.draw
                                return
                            }
                        }
                    }
                }
            }
            .padding()
            .disabled(isGameBoardDisabled)
            .navigationTitle("Tic Tac Toe")
            .alert(item: $alertItem) { alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text(alertItem.buttonTitle), action: resetGame))
            }
        }
    }
    
    func checkWinCondition(for player : Player, in moves : [Move?]) -> Bool {
        let winPatterns: Array<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPosition = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            if pattern.isSubset(of: playerPosition){
                return true
            }
        }
        
        return false
    }
    
    func checkDrawCondition(in moves: [Move?]) -> Bool {
        moves.compactMap{ $0 }.count == 9
    }
    
    func determineComputerMove(in moves: [Move?]) -> Int {
        let winPatterns: Array<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        // If AI can win, then win
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let computerPosition = Set(computerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let winPosition = pattern.subtracting(computerPosition)
            if winPatterns.count == 1 {
                if !isBlockOccipied(in: moves, forIndex: winPosition.first!) {
                    return winPosition.first!
                }
            }
        }
        // If AI cant win, then block player
        let humanMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        let humanPosition = Set(humanMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let blockPosition = pattern.subtracting(humanPosition)
            if blockPosition.count == 1 {
                if !isBlockOccipied(in: moves, forIndex: blockPosition.first!) {
                    return blockPosition.first!
                }
            }
        }
        // if AI cant block, then take middle block and do not take only middle block first when start first
        let middleBlock = 4
        if (!isBlockOccipied(in: moves, forIndex: middleBlock)) && (!isAllBlockEmpty(in: moves)) {
            return middleBlock
        }
        // If AI cant take middle block, then take randomly
        var movePosition = Int.random(in: 0..<9)
        
        while isBlockOccipied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
    
    func isBlockOccipied(in moves: [Move?], forIndex index: Int) -> Bool {
        moves[index] != nil
    }
    
    func isAllBlockEmpty(in moves: [Move?]) -> Bool {
        moves.compactMap{ $0 }.count == 0
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        //If AI start first
        if !isHumanFirst {
            
            isGameBoardDisabled.toggle()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let computerPosition = determineComputerMove(in: moves)
                
                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                isGameBoardDisabled.toggle()
            }
        }
    }
    
    func blockSize() -> CGFloat {
        UIScreen.main.bounds.width / 3 - 15
    }
    
    func markSize() -> CGFloat {
        blockSize() / 1.5
    }
    
    init() {
        UIView.appearance().isMultipleTouchEnabled = false
        UIView.appearance().isExclusiveTouch = true
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player : Player
    let boardIndex : Int
    
    var mark : String {
        player == .human ? "xmark" : "circle"
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let buttonTitle: String
}

struct AlertContext {
    static let humanWin = AlertItem(title: "You Win!", message: "Wow! you're so smart", buttonTitle: "Retry")
    static let draw = AlertItem(title: "You Draw!", message: "That was close!", buttonTitle: "Retry")
    static let computerWin = AlertItem(title: "You Lost!", message: "Better luck next time", buttonTitle: "Retry")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
