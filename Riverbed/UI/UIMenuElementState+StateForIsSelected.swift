import UIKit

extension UIMenuElement.State {
    static func stateFor(isSelected: Bool) -> UIMenuElement.State {
        isSelected ? .on : .off
    }
}
