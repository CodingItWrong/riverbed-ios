import UIKit

extension UITableView {
    // if cell is not found, register it from the XIB with the same name
    func dequeueOrRegisterReusableCell(withIdentifier identifier: String) -> UITableViewCell {
        // the signature without indexPath seems to be the one that allows an optional
        if let cell = dequeueReusableCell(withIdentifier: identifier) {
            return cell
        }

        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        guard let cell = dequeueReusableCell(withIdentifier: identifier)
        else { preconditionFailure("Could not dequeue cell after registering: \(identifier)") }
        return cell
    }
}
