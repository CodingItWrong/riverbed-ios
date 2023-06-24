//

import UIKit

class RiverbedSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = ColorTheme.defaultUIColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // go to board list on iPhone without animation
        guard let leftNavController = viewControllers.first as? UINavigationController else {
            preconditionFailure("Couldn't get left nav controller")
        }
        leftNavController.popViewController(animated: false)

        // show sidebar on iPad
        show(.primary)
    }

}
