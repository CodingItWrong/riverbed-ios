import UIKit

protocol FormCellDelegate: AnyObject {
    func valueDidChange(inFormCell formCell: UITableViewCell)
}
