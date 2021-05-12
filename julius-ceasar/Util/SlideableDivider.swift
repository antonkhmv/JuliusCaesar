//
//  TestView.swift
//  test2
//
//  Created by Anton Khomyakov on 29.04.2021.
//

import SwiftUI

public struct HSlideableDivider: View {
    var getLeftWidth: () -> CGFloat
    var getRightWidth: () -> CGFloat
    var widthChanged: (_ left: CGFloat, _ right: CGFloat) -> ()
    
    var minLeftWidth: CGFloat = -.infinity
    var maxLeftWidth: CGFloat = .infinity
    
    var minRightWidth: CGFloat = -.infinity
    var maxRightWidth: CGFloat = .infinity
    
    @State private var leftWidthStart: CGFloat?
    
    public var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.1))
            .frame(width: 2)
            .onHover { inside in
                if inside {
                    NSCursor.resizeLeftRight.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: CoordinateSpace.global)
            .onChanged { val in
                
                var leftWidth = getLeftWidth()
                var rightWidth = getRightWidth()
                
                if leftWidthStart == nil {
                    leftWidthStart = leftWidth
                }
                
                let sum = leftWidth + rightWidth
                var newLeftWidth = leftWidthStart! + val.location.x - val.startLocation.x
                
                let lowerBound = max(minLeftWidth, sum - maxRightWidth)
                let upperBound = min(maxLeftWidth, sum - minRightWidth)
                
                if lowerBound <= newLeftWidth && newLeftWidth <= upperBound {
                    NSCursor.pop()
                    NSCursor.resizeLeftRight.push()
                }
                else if (newLeftWidth > upperBound){
                    newLeftWidth = upperBound
                }
                else {
                    newLeftWidth = lowerBound
                }
                
                rightWidth = sum - newLeftWidth
                leftWidth = newLeftWidth
                
                widthChanged(leftWidth, rightWidth)
            }
            .onEnded { val in
                leftWidthStart = nil
                NSCursor.pop()
            }
    }
}  


public struct VSlidableDivider: View {
    var getTopHeight: () -> CGFloat
    var getBottomHeight: () -> CGFloat
    var heightChanged: (_ top: CGFloat, _ bottom: CGFloat) -> ()
    
    var minTopHeight: CGFloat = -.infinity
    var maxTopHeight: CGFloat = .infinity
    
    var minBottomHeight: CGFloat = -.infinity
    var maxBottomHeight: CGFloat = .infinity
    
    @State private var topHeightStart: CGFloat?
    
    
    public var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.1))
            .frame(height: 2)
            .onHover { inside in
                if inside {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
            .gesture(drag)
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: CoordinateSpace.global)
            .onChanged { val in
                
                var topHeight = getTopHeight()
                var bottomHeight = getBottomHeight()
                
                if topHeightStart == nil {
                    topHeightStart = topHeight
                }
                
                let sum = topHeight + bottomHeight
                var newTopHeight = topHeightStart! - val.location.y + val.startLocation.y
                
                let lowerBound = max(minTopHeight, sum - maxBottomHeight)
                let upperBound = min(maxTopHeight, sum - minBottomHeight)
                
                if lowerBound <= newTopHeight && newTopHeight <= upperBound {
                    NSCursor.pop()
                    NSCursor.resizeUpDown.push()
                }
                else if (newTopHeight > upperBound){
                    newTopHeight = upperBound
                }
                else {
                    newTopHeight = lowerBound
                }
                
                bottomHeight = sum - newTopHeight
                topHeight = newTopHeight
                
                heightChanged(topHeight, bottomHeight)
            }
            .onEnded { val in
                topHeightStart = nil
                NSCursor.pop()
            }
    }
}
