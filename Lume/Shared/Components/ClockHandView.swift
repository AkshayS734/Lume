//  Akshay Shukla
//  ClockHandView.swift
//  Lume
//
//  Reusable analog clock hand drawn with SwiftUI Canvas.
//  All analog themes share this component for consistency and performance.
//

import SwiftUI

// MARK: - ClockHandView

/// A single clock hand rendered as a Path inside a Canvas.
/// Origin is at the view center; the hand points in `angle` direction.
///
/// Parameters:
///  - angle:  Direction the hand points (0° = 3 o'clock; subtract 90° for 12 o'clock origin)
///  - length: Length of the hand from center to tip, in points
///  - width:  Stroke width (tip tapers to half this value)
///  - color:  Fill/stroke color
///  - tail:   Optional counter-weight length behind center (default 0)
struct ClockHandView: View {

    let angle: Angle
    let length: CGFloat
    let width: CGFloat
    let color: Color
    var tail: CGFloat = 0
    var shadow: Bool = false

    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let rad = angle.radians

            let tip = CGPoint(
                x: center.x + cos(rad) * length,
                y: center.y + sin(rad) * length
            )
            let tailPt = CGPoint(
                x: center.x - cos(rad) * tail,
                y: center.y - sin(rad) * tail
            )

            // Perpendicular offset for tapered hand shape
            let perpRad = rad + .pi / 2
            let halfW = width / 2
            let halfWTip = max(halfW * 0.3, 0.5)

            var path = Path()
            path.move(to: CGPoint(
                x: tailPt.x + cos(perpRad) * halfW,
                y: tailPt.y + sin(perpRad) * halfW
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(perpRad) * halfW,
                y: center.y + sin(perpRad) * halfW
            ))
            path.addLine(to: CGPoint(
                x: tip.x + cos(perpRad) * halfWTip,
                y: tip.y + sin(perpRad) * halfWTip
            ))
            path.addLine(to: CGPoint(
                x: tip.x - cos(perpRad) * halfWTip,
                y: tip.y - sin(perpRad) * halfWTip
            ))
            path.addLine(to: CGPoint(
                x: center.x - cos(perpRad) * halfW,
                y: center.y - sin(perpRad) * halfW
            ))
            path.addLine(to: CGPoint(
                x: tailPt.x - cos(perpRad) * halfW,
                y: tailPt.y - sin(perpRad) * halfW
            ))
            path.closeSubpath()

            if shadow {
                ctx.addFilter(.shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 2))
            }

            ctx.fill(path, with: .color(color))
        }
    }
}

// MARK: - BatonHandView

/// Swiss/luxury style baton hand — thick rectangular shape with rounded caps.
struct BatonHandView: View {
    let angle: Angle
    let length: CGFloat
    let width: CGFloat
    let color: Color
    var tail: CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let rad = angle.radians
            let perpRad = rad + .pi / 2
            let halfW = width / 2

            let tip = CGPoint(
                x: center.x + cos(rad) * length,
                y: center.y + sin(rad) * length
            )
            let tailPt = CGPoint(
                x: center.x - cos(rad) * tail,
                y: center.y - sin(rad) * tail
            )

            var path = Path()
            path.move(to: CGPoint(x: tailPt.x + cos(perpRad) * halfW,
                                  y: tailPt.y + sin(perpRad) * halfW))
            path.addLine(to: CGPoint(x: tip.x + cos(perpRad) * halfW,
                                     y: tip.y + sin(perpRad) * halfW))
            path.addLine(to: CGPoint(x: tip.x - cos(perpRad) * halfW,
                                     y: tip.y - sin(perpRad) * halfW))
            path.addLine(to: CGPoint(x: tailPt.x - cos(perpRad) * halfW,
                                     y: tailPt.y - sin(perpRad) * halfW))
            path.closeSubpath()

            ctx.fill(path, with: .color(color))
        }
    }
}
