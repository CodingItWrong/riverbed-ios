import UIKit

protocol ElementCell: UITableViewCell {
    func update(for element: Element, and card: Card)
}
