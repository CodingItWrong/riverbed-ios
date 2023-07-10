//

import UIKit

class RiverbedSplitViewController: UISplitViewController,
                                   UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = ColorTheme.defaultUIColor
        delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // show sidebar on iPad
        show(.primary)
    }

    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column)
    -> UISplitViewController.Column {
        // show left VC first on iPhone
        .primary
    }

}
