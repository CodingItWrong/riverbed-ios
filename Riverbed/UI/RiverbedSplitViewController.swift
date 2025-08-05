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
    
    @objc func about(_ sender: Any?) {
        boardListVC.showAboutPage()
    }
    
    @objc func userSettings(_ sender: Any?) {
        boardListVC.showUserSettings()
    }
    
    @objc func newBoard(_ sender: Any?) {
        boardListVC.createBoard(sender)
    }
    
    @objc func reloadBoards(_ sender: Any?) {
        boardListVC.loadBoards()
    }
    
    @objc func signOut(_ sender: Any?) {
        boardListVC.signOut()
    }
    
    private var boardListVC: BoardListCollectionViewController {
        let boardListNavVC = viewController(for: .primary) as! UINavigationController
        return boardListNavVC.viewControllers.first as! BoardListCollectionViewController
    }

}
