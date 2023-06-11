import UIKit

protocol FormCellDelegate: AnyObject {
    func didPressButton(inFormCell formCell: UITableViewCell)
    func valueDidChange(inFormCell formCell: UITableViewCell)
}
