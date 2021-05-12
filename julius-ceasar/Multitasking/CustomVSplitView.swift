//
//  Window1.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 09.05.2021.
//

import SwiftUI

struct CustomVSplitView<Content>: View where Content: View {
    
    private var n: CGFloat
    @State private var proportions: [CGFloat]
    
    var content: Array<Content>
    var minHeight: CGFloat
    
    init(content: Array<Content>, minHeight:CGFloat) {
        self.content = content
        self.minHeight = minHeight
        self.n = CGFloat(content.count)
        self._proportions = State(initialValue:
                                    Array(repeating: 1 / n,
                                          count: content.count)
        )
    }
    
    func screenHeight(_ proxy: GeometryProxy) -> CGFloat { proxy.size.height - 2 * n}
    
    func calculateProportions(_ proxy: GeometryProxy,
                              proportion: CGFloat, other: CGFloat,
                              pos: Int) {
        
        proportions[pos] = proportion / screenHeight(proxy)
        proportions[pos+1] = other / screenHeight(proxy)
    }
    
    func getHeight(_ proxy: GeometryProxy, pos: Int, other: Int) -> CGFloat {
        let res = screenHeight(proxy) * proportions[pos]
        if res < minHeight {
            DispatchQueue.global(qos: .userInitiated).async {
                let sum = proportions[pos] + proportions[other]
                proportions[pos] = minHeight / screenHeight(proxy)
                proportions[other] = sum - proportions[pos]
            }
        }
        return res
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
            
                ForEach(0..<(Int(n)-1)) { pos in
                    self.content[pos]
                        .frame(height: getHeight(geo, pos: pos, other: pos+1))
                    
                    VSlidableDivider(getTopHeight:
                                        { getHeight(geo, pos: pos, other: pos+1) },
                                      getBottomHeight:
                                        { getHeight(geo, pos: pos+1, other: pos) },
                                     heightChanged:
                                        { top, bottom in
                                        calculateProportions(geo, proportion: top,
                                                             other: bottom,
                                                             pos: pos) },
                                     minTopHeight: minHeight,
                                     minBottomHeight: minHeight)
                }
                
                self.content.last!
                    .frame(height: getHeight(geo, pos: Int(n)-1, other: Int(n)-2))
                
            }
        }
        .frame(minHeight: minHeight * n)
    }
}
