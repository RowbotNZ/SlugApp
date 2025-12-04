//
//  SlugsView.swift
//  SlugApp
//
//  Created by Rowan Livingstone on 03/12/2025.
//

import SwiftUI

struct SlugsView: View {
    var body: some View {
        GeometryReader { geometryProxy in
            ZStack(alignment: .center) {
                ForEach(viewModel.viewState.slugs) { slug in
                    SlugView(
                        color: slug.isReproducing ? .red : .brown,
                        maxX: geometryProxy.size.width,
                        maxY: geometryProxy.size.height
                    )
                    .transition(.blurReplace.animation(.snappy))
                    .onTapGesture {
                        slug.onTap()
                    }
                }
            }
        }
        .padding()
        .navigationTitle(viewModel.viewState.title)
        .task { await viewModel.run() }
    }

    @State
    var viewModel: SlugsViewModel
}

extension SlugsView {
    struct SlugView: View {
        var body: some View {
            let color = color.opacity(.random(in: 0.75...1))
            Image("slug")
                .resizable()
                .frame(width: slugDimension, height: slugDimension)
                .foregroundStyle(color)
                .rotation3DEffect(isReversed ? .radians(.pi) : .zero, axis: (0, 1, 0))
                .offset(x: offset.x, y: offset.y)
                .task {
                    while !Task.isCancelled {
                        var offset = self.offset

                        for _ in 0..<2 {
                            switch Int.random(in: 0...4) {
                            case 0: /// Up
                                offset.y -= 20
                            case 1: /// Down
                                offset.y += 20
                            case 2: /// Left
                                offset.x -= 20
                            case 3: /// Right
                                offset.x += 20
                            default:
                                break
                            }
                        }

                        /// Clamp offset to min and max values.
                        offset.x = max(0, min(offset.x, maxX))
                        offset.y = max(0, min(offset.y, maxY))

                        if (offset.x - self.offset.x) < 0 {
                            if !isReversed {
                                withAnimation(.snappy) {
                                    isReversed = true
                                }
                            }
                        } else if isReversed {
                            withAnimation(.snappy) {
                                isReversed = false
                            }
                        }

                        self.offset = offset

                        try? await Task.sleep(nanoseconds: .random(in: 500_000_000...1_000_000_000))
                    }
                }
                .animation(.easeOut, value: color)
                .animation(.bouncy, value: offset)
        }

        let color: Color

        let maxX: CGFloat

        let maxY: CGFloat

        private let slugDimension: CGFloat = 50

        @State
        private var offset: CGPoint

        @State
        private var isReversed: Bool = .random()

        init(
            color: Color,
            maxX: CGFloat,
            maxY: CGFloat
        ) {
            self.color = color
            self.maxX = maxX - slugDimension
            self.maxY = maxY - slugDimension
            self.offset = CGPoint(
                x: .random(in: 0...maxX),
                y: .random(in: 0...maxY)
            )
        }
    }
}

#Preview {
    SlugsView(viewModel: SlugsViewModel())
}
