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
    
    // MARK: - menu commands
    
    @objc func newBoard(_ sender: Any?) {
        let boardListNavVC = viewController(for: .primary) as! UINavigationController
        let boardListVC = boardListNavVC.viewControllers.first as! BoardListCollectionViewController
        boardListVC.createBoard(sender)
    }
    
    @objc func reloadBoards(_ sender: Any?) {
        let boardListNavVC = viewController(for: .primary) as! UINavigationController
        let boardListVC = boardListNavVC.viewControllers.first as! BoardListCollectionViewController
        boardListVC.loadBoards()
    }

}
