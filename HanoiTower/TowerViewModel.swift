//
//  TowerViewModel.swift
//  HanoiTower
//
//  Created by DimMac on 29.05.2024.
//

import Foundation
import SwiftUI

struct Move {
    var id = UUID()
    var disk: Int
    var sourceTower: Tower
    var destinationTower: Tower
    var temporaryTower: Tower
}

class TowerViewModel: ObservableObject {
    
    @Published var disks: [DiskModel] = []

    var towerOneOrigin: CGPoint? = nil
    var widthOfTowerBase: CGFloat = 0.0
    
    var firstTowerDisksCount = 0
    var secondTowerDisksCount = 0
    var thirdTowerDisksCount = 0
    var firstTowerBaseXOffset: CGFloat = 0
    var secondTowerBaseXOffset: CGFloat = 0
    var thirdTowerBaseXOffset: CGFloat = 0
    var towerTopOffset: CGFloat = 110
    var moves: [Move] = []
    var move: Move?

    func loadInitialState(widthOfTowerBase: CGFloat, towerOneOrigin: CGPoint){
        self.widthOfTowerBase = widthOfTowerBase
        self.towerOneOrigin = towerOneOrigin
        self.firstTowerBaseXOffset = towerOneOrigin.x
        self.secondTowerBaseXOffset = towerOneOrigin.x + ViewConstants.hStackSpacing + widthOfTowerBase + ViewConstants.vStackPadding/2
        self.thirdTowerBaseXOffset = towerOneOrigin.x + ViewConstants.hStackSpacing * 2 + widthOfTowerBase * 2 + ViewConstants.vStackPadding/1.5
    }
    
    func clearTowerDisks() {
        firstTowerDisksCount = 0
        secondTowerDisksCount = 0
        thirdTowerDisksCount = 0
    }
    
    func newDisk() {
        let disksCount = self.disks.count
        
        @discardableResult
        func getColor() -> Color {
           let color = Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
            if disks.count > 0, color == disks[disksCount - 1].color {
                getColor()
            }
            return color
        }
        
        func getsize() -> CGSize {
            let disks = disksCount + 1
            return CGSize(width: (widthOfTowerBase - CGFloat(disks * 10)), height: ViewConstants.thikness)
        }
        
        let position = CGPoint(x: towerOneOrigin?.x ?? 0, y: (towerOneOrigin?.y ?? 0) - CGFloat(disksCount) * ViewConstants.thikness)
        let newDisk = DiskModel(size: getsize(), color: getColor(), position: position)
        
        self.disks.append(newDisk)
        firstTowerDisksCount = disks.count
    }
    
    func removeDisk(){
        disks.removeLast()
    }
    
    func movesCalculation(numberOfDisks: Int, source x: Tower, dest y: Tower, temp z: Tower, numberOfDisk: Int) {
        if (numberOfDisk < numberOfDisks) {
            
            movesCalculation(numberOfDisks: numberOfDisks, source:x, dest:z, temp:y, numberOfDisk: numberOfDisk + 1)
            
            // creates array with all moves
            let move = Move(disk: numberOfDisk, sourceTower: x, destinationTower: y, temporaryTower: z)
            moves.append(move)

            movesCalculation(numberOfDisks: numberOfDisks, source:z, dest:y, temp:x, numberOfDisk: numberOfDisk + 1)
        }
    }
    
    func firstMoveOffset(numberOfDisk: Int, sourceTower: Tower, destinationTower: Tower, temporaryTower: Tower) {
        var fromTowerXOffset: CGFloat
        
        switch sourceTower {
        case .firstTower:
            fromTowerXOffset = firstTowerBaseXOffset
            firstTowerDisksCount -= 1
        case .secondTower:
            fromTowerXOffset = secondTowerBaseXOffset
            secondTowerDisksCount -= 1
        case .thirdTower:
            fromTowerXOffset = thirdTowerBaseXOffset
            thirdTowerDisksCount -= 1
        }
        let originYOffset = towerOneOrigin?.y ?? 0
        firstMovePosition(numberOfDisk: numberOfDisk, position: CGPoint(x: fromTowerXOffset, y: originYOffset - towerTopOffset))
    }
    
    func secondMoveOffset(numberOfDisk: Int, sourceTower: Tower, destinationTower: Tower, temporaryTower: Tower) {
        var toTowerXOffset: CGFloat
        let originYOffset = towerOneOrigin?.y ?? 0
        
        switch destinationTower {
        case .firstTower:
            toTowerXOffset = firstTowerBaseXOffset
        case .secondTower:
            toTowerXOffset = secondTowerBaseXOffset
        case .thirdTower:
            toTowerXOffset = thirdTowerBaseXOffset
        }
        
        secondMovePosition(numberOfDisk: numberOfDisk, position: CGPoint(x: toTowerXOffset, y: originYOffset - towerTopOffset))
    }
    
    func thirdMoveOffset(numberOfDisk: Int, sourceTower: Tower, destinationTower: Tower, temporaryTower: Tower) {
        var toTowerXOffset: CGFloat
        let originYOffset = towerOneOrigin?.y ?? 0
        let disksYOffset: CGFloat

        switch destinationTower {
        case .firstTower:
            toTowerXOffset = firstTowerBaseXOffset
            disksYOffset = CGFloat(firstTowerDisksCount) * ViewConstants.thikness
            firstTowerDisksCount += 1
        case .secondTower:
            toTowerXOffset = secondTowerBaseXOffset
            disksYOffset = CGFloat(secondTowerDisksCount) * ViewConstants.thikness
            secondTowerDisksCount += 1
        case .thirdTower:
            toTowerXOffset = thirdTowerBaseXOffset
            disksYOffset = CGFloat(thirdTowerDisksCount) * ViewConstants.thikness
            thirdTowerDisksCount += 1
        }
        
        thirdMovePosition(numberOfDisk: numberOfDisk, position: CGPoint(x: toTowerXOffset, y: originYOffset - disksYOffset))
    }
    
    func firstMove(move: Move){
        firstMoveOffset(numberOfDisk: move.disk, sourceTower: move.sourceTower, destinationTower: move.destinationTower, temporaryTower: move.temporaryTower)
    }
    
    func secondMove(move: Move){
        secondMoveOffset(numberOfDisk: move.disk, sourceTower: move.sourceTower, destinationTower: move.destinationTower, temporaryTower: move.temporaryTower)
    }
    
    func thirdMove(move: Move){
        thirdMoveOffset(numberOfDisk: move.disk, sourceTower: move.sourceTower, destinationTower: move.destinationTower, temporaryTower: move.temporaryTower)
    }

    func firstMovePosition(numberOfDisk: Int, position: CGPoint) {
        disks[numberOfDisk].position = CGPoint(x: position.x, y: position.y)
    }
    
    func secondMovePosition(numberOfDisk: Int, position: CGPoint){
        disks[numberOfDisk].position = CGPoint(x: position.x, y: position.y)
    }
    
    func thirdMovePosition(numberOfDisk: Int, position: CGPoint){
        disks[numberOfDisk].position = CGPoint(x: position.x, y: position.y)
    }
    
}
