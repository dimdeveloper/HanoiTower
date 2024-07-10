//
//  ContentView.swift
//  HanoiTower
//
//  Created by DimMac on 29.05.2024.
//

import SwiftUI

struct ViewConstants {
    static let vStackPadding: CGFloat = 10.0
    static let hStackSpacing: CGFloat = 15.0
    static let thikness: CGFloat = 20.0
    static let buttonsHStackHeight: CGFloat = 100.0
}

struct ContentView: View {
    
    @StateObject private var towerViewModel = TowerViewModel()
    @State var stepperValue: Int = 0
    @State var disksControlDisabled: Bool = false

    var body: some View {
        
        ZStack(alignment: .bottom) {
            Color.blue.ignoresSafeArea()
            
            VStack(spacing: 0) {

                Text("Max number of disks is 5")
                    .foregroundColor(.white)
                    .padding(.vertical, 50)
                
                HStack(spacing: ViewConstants.hStackSpacing) {
                    ForEach(0...2, id: \.self) { _ in
                        TowerView()
                    }
                }
                
                HStack(spacing: ViewConstants.hStackSpacing) {
                   
                    StepperView(stepperValue: $stepperValue, viewModel: towerViewModel, isDisabled: $disksControlDisabled)
                    
                    VStack(spacing: 10) {
                        Button("Start") {
                            disksControlDisabled = true
                            towerViewModel.movesCalculation(numberOfDisks: towerViewModel.disks.count, source: .firstTower, dest: .thirdTower, temp: .secondTower, numberOfDisk: 0)
                            animate()
                        }
                        .padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .disabled(disksControlDisabled || towerViewModel.disks.count < 1)
                        
                        Button("Clear") {
                            clearValues()
                        }
                        .padding(8)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                        .disabled(towerViewModel.thirdTowerDisksCount != towerViewModel.disks.count)
                    }
                    .foregroundColor(.accentColor)
                }
                .frame(width: nil, height: ViewConstants.buttonsHStackHeight)
            }
            .padding(.horizontal, ViewConstants.vStackPadding)
            
            // disks position
            ForEach(towerViewModel.disks) { disk in
                RoundedRectangle(cornerRadius: 10)
                    .fill(disk.color)
                    .frame(width: disk.size.width, height: disk.size.height)
                    .position(x: disk.position.x, y: disk.position.y)
                
            }
        }
        .onAppear() {
            // calculate main properties for ViewModel
            calcVMprop()
        }
    }
    
    func calcVMprop() {
        let screenBounds = UIScreen.main.bounds
        let ScreenWidth = screenBounds.width
        let ScreenHeight = screenBounds.height
        let window = UIApplication.shared.connectedScenes.flatMap {($0 as? UIWindowScene)?.windows ?? []}.last {$0.isKeyWindow}
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
        // calculating Y offset for base of tower
        let yPoint = ScreenHeight - topPadding - bottomPadding - ViewConstants.buttonsHStackHeight - ViewConstants.thikness/2 - ViewConstants.thikness

        let widthOfTowerBase = (ScreenWidth - ViewConstants.vStackPadding * 2 - 40)/3
        // calculating X offset for base of tower
        let xPoint = widthOfTowerBase/2 + ViewConstants.vStackPadding
        let towerOneOrigin = CGPoint(x: xPoint, y: yPoint)
    
        loadVMInitStatte(baseWidth: widthOfTowerBase, baseOrigin: towerOneOrigin)
    }
    
    func loadVMInitStatte(baseWidth: CGFloat, baseOrigin: CGPoint){
        towerViewModel.loadInitialState(widthOfTowerBase: baseWidth, towerOneOrigin: baseOrigin)
    }
    
    func clearValues() {
        towerViewModel.disks.removeAll()
        towerViewModel.moves.removeAll()
        towerViewModel.clearTowerDisks()
        disksControlDisabled = false
        stepperValue = 0
        calcVMprop()
    }
    
    func animate() {
        guard towerViewModel.moves.count >= 1 else {return}
        
        let move = towerViewModel.moves.removeFirst()
        let animationDuration = 0.3/Double((towerViewModel.disks.count)) + 0.05
        withAnimation(.easeInOut(duration: animationDuration)) {
            towerViewModel.firstMove(move: move)
        } completion: {
            withAnimation(.easeInOut(duration: animationDuration)) {
                towerViewModel.secondMove(move: move)
            } completion: {
                withAnimation(.easeInOut(duration: animationDuration)) {
                    towerViewModel.thirdMove(move: move)
                } completion: {
                    animate()
                }
            }
        }
    }
}

struct StepperView: View {
    
    @Binding var stepperValue: Int
    @ObservedObject var viewModel: TowerViewModel
    @Binding var isDisabled: Bool
    
    var body: some View {
        Stepper("Disks count: \(stepperValue)") {
            if stepperValue < 5 {
                viewModel.newDisk()
                stepperValue += 1
            }
        } onDecrement: {
            if stepperValue > 0 {
                viewModel.removeDisk()
                stepperValue -= 1
            }
        }
        .disabled(isDisabled)
        .accentColor(.white)
        .foregroundColor(.white)
    }
}

struct TowerView: View {
    var body: some View {
        VStack(spacing: -5) {
            VRectangleView()
            HRectangleView()

        }
    }
}

struct HRectangleView: View {
    let height = ViewConstants.thikness
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.gray)
            .frame(width: nil, height: height)
    }
}

struct VRectangleView: View {
    var width = ViewConstants.thikness
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.red)
            .frame(width: width, height: 100)
    }
}

#Preview {
    ContentView()
}
