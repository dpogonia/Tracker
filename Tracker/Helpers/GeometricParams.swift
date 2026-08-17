import UIKit

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat

    var paddingWidth: CGFloat {
        leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
