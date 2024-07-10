//
//  DiskModel.swift
//  HanoiTower
//
//  Created by DimMac on 30.05.2024.
//
import SwiftUI

struct DiskModel: Identifiable {
    var id = UUID()
    var size: CGSize
    var color: Color
    var position: CGPoint
}
