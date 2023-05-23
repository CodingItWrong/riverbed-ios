//

import UIKit

class RiverbedSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        show(.primary) // start in board list on phone
        // TODO: do not animate
    }

}
