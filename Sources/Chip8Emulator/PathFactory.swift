//
//  PathFactory.swift
//  CHIP8WatchOS WatchKit Extension
//
//  Created by Ryan Grey on 12/02/2021.
//

import Foundation
import CoreGraphics

public struct PathFactory {
    public static func from(
        screen: Chip8Screen,
        containerSize: CGSize,
        isYReversed: Bool
    ) -> CGPath {
        let path = CGMutablePath()

        let viewWidth = containerSize.width
        let viewHeight = containerSize.height
        let pixelWidth = (viewWidth / CGFloat(screen.size.width)).floorTo(nearest: 0.5)
        let pixelHeight = (viewHeight / CGFloat(screen.size.height)).floorTo(nearest: 0.5)
        let pixelSize = CGSize(width: pixelWidth, height: pixelHeight)

        let xRemainder = viewWidth - (pixelWidth * CGFloat(screen.size.width))
        let yRemainder = viewHeight - (pixelHeight * CGFloat(screen.size.height))
        let xStart = (xRemainder / 2).floorTo(nearest: 0.5)
        let yStart = (yRemainder / 2).floorTo(nearest: 0.5)

        let xRange = 0..<screen.size.width
        let yRange = 0..<screen.size.height
        for x in xRange {
            for y in yRange {
                let pixelAddress = y * screen.size.width + x
                guard screen.pixels[pixelAddress] == 1 else {
                    // skip if we're not meant to draw pixel
                    continue
                }

                let xCoord = xStart + (CGFloat(x) * pixelSize.width)
                let rawYCoord = yStart + (CGFloat(y) * pixelSize.height)
                let yCoord = isYReversed
                    ? viewHeight - rawYCoord
                    : rawYCoord
                let origin = CGPoint(x: xCoord, y: yCoord)
                let frame = CGRect(origin: origin, size: pixelSize)
                path.addRect(frame)
            }
        }
        return path
    }
}

extension CGFloat {
    func floorTo(nearest decimal: CGFloat) -> CGFloat {
        let modified = self / decimal
        let floored = floor(modified)
        let final = floored * decimal
        return final
    }
}
