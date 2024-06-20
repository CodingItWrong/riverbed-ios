//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        print("scene:willConnectTo:options:")
        // Use this method to optionally configure and attach the UIWindow `window`
        // to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new
        // (see `application:configurationForConnectingSceneSession` instead).

        print("session.stateRestorationActivity: \(String(describing: session.stateRestorationActivity))")

//        guard let boardListVC = leftNavController.viewControllers.first as? BoardListViewController
//        else { fatalError("Expected a BoardListViewController") }
        guard let boardListVC = leftNavController.viewControllers.first as? BoardListCollectionViewController
        else { fatalError("Expected a BoardListCollectionViewController") }
        guard let boardVC = rightNavController.viewControllers.first as? BoardViewController
        else { fatalError("Expected a BoardViewController") }

        let keychainStore = KeychainStore()
        let userDefaults = UserDefaults.standard
        let sessionSource = DeviceStorageSessionSource(keychainStore: keychainStore, userDefaults: userDefaults)
        let boardStore = BoardStore(sessionSource: sessionSource)

        boardListVC.tokenSource = sessionSource
        boardListVC.tokenStore = ApiTokenStore(sessionSource: sessionSource) // NOTE: tokenSource is unused here
        boardListVC.userStore = UserStore(sessionSource: sessionSource)
        boardListVC.boardStore = boardStore
        boardListVC.delegate = boardVC

        boardVC.boardStore = boardStore
        boardVC.cardStore = CardStore(sessionSource: sessionSource)
        boardVC.columnStore = ColumnStore(sessionSource: sessionSource)
        boardVC.elementStore = ElementStore(sessionSource: sessionSource)
        boardVC.delegate = boardListVC
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded
        // (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("sceneWillEnterForeground")

        guard let boardVC = rightNavController.viewControllers.first as? BoardViewController
        else { return } // dunno why this returns the wrong VC on iPhone on boot

        boardVC.configureForForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print("sceneDidEnterBackground")
    }

    // MARK: - private helpers

    var splitVC: UISplitViewController {
        guard let splitVC = window?.rootViewController as? UISplitViewController
        else { fatalError("Expected a UISplitViewController") }
        return splitVC
    }

    var leftNavController: UINavigationController {
        guard let leftNavController = splitVC.viewControllers.first as? UINavigationController
        else { fatalError("Expected a UINavigationController") }
        return leftNavController
    }

    var rightNavController: UINavigationController {
        guard let rightNavController = splitVC.viewControllers.last as? UINavigationController
        else { fatalError("Expected a UINavigationController") }
        return rightNavController
    }

}
