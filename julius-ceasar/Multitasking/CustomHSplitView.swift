//
//  CustomHSplitView.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 09.05.2021.
//

import SwiftUI

struct CustomHSplitView<Content>: View where Content: View {
    
    private var n: CGFloat
    @State private var proportions: [CGFloat]
    
    var content: Array<Content>
    var minWidth: CGFloat
    
    init(content: Array<Content>, minWidth:CGFloat) {
        assert(content.count >= 2)
        self.content = content
        self.minWidth = minWidth
        self.n = CGFloat(content.count)
        self._proportions = State(initialValue:
                                    Array(repeating: 1 / n,
                                          count: content.count)
        )
    }
    
    func screenWidth(_ proxy: GeometryProxy) -> CGFloat { proxy.size.width - 2 * (n-1)}
    
    func calculateProportions(_ proxy: GeometryProxy,
                              proportion: CGFloat, other: CGFloat,
                              pos: Int) {
        
        proportions[pos] = proportion / screenWidth(proxy)
        proportions[pos+1] = other / screenWidth(proxy)
    }
    
    func getWidth(_ proxy: GeometryProxy, pos: Int, other: Int) -> CGFloat {
        let res = screenWidth(proxy) * proportions[pos]
        if res < minWidth {
            DispatchQueue.global(qos: .userInitiated).async {
                let sum = proportions[pos] + proportions[other]
                proportions[pos] = minWidth / screenWidth(proxy)
                proportions[other] = sum - proportions[pos]
            }
        }
        return res
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
            
                ForEach(0..<(Int(n)-1)) { pos in
                    self.content[pos]
                        .frame(width: getWidth(geo, pos: pos, other: pos+1))
                    
                    HSlideableDivider(getLeftWidth:
                                        { getWidth(geo, pos: pos, other: pos+1) },
                                      getRightWidth:
                                        { getWidth(geo, pos: pos+1, other: pos) },
                                     widthChanged:
                                        { left, right in
                                        calculateProportions(geo, proportion: left,
                                                             other: right,
                                                             pos: pos) },
                                     minLeftWidth: minWidth,
                                     minRightWidth: minWidth)
                }
                
                self.content.last!
                    .frame(width: getWidth(geo, pos: Int(n)-1, other: Int(n)-2))
                
            }
        }
        .frame(minWidth: minWidth * n)
    }
}
