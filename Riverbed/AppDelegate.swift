//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

// Menu builder
extension AppDelegate {
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        guard builder.system == .main else { return }
        
        buildFileMenu(with: builder)
        buildViewMenu(with: builder)
        buildBoardMenu(with: builder)
        buildCardMenu(with: builder)
    }
    
    private func buildFileMenu(with builder: UIMenuBuilder) {
        let newSceneMenu = builder.menu(for: .newScene)
        builder.remove(menu: .newScene)

        let newWindowCommand = newSceneMenu?.children.first as? UIKeyCommand
        
        let newBoardCommand = UICommand(title: "New Board",
                                        image: UIImage(systemName: "plus.square"),
                                        action: #selector(RiverbedSplitViewController.newBoard(_:)))
                
        let newCardCommand = UIKeyCommand(title: "New Card",
                                          image: newWindowCommand?.image ?? UIImage(systemName: "plus.square"),
                                          action: #selector(BoardViewController.addCard(_:)),
                                          input: "n",
                                          modifierFlags: [.command])
        var topFileMenuCommands = [newBoardCommand, newCardCommand]
        if let newWindowCommand = newWindowCommand,
            let action = newWindowCommand.action,
            let input = newWindowCommand.input {
            let myNewWindowCommand = UIKeyCommand(title: newWindowCommand.title,
                                                  image: newWindowCommand.image,
                                                  action: action,
                                                  input: input,
                                                  modifierFlags: newWindowCommand.modifierFlags.union(.shift))
            topFileMenuCommands.append(myNewWindowCommand)
        }
        let topFileCommandsMenu = UIMenu(options: .displayInline, children: topFileMenuCommands)
        builder.insertChild(topFileCommandsMenu, atStartOfMenu: .file)
        
        let signOutCommand = UICommand(title: "Sign Out",
                                       image: UIImage(systemName: "person.crop.circle.badge.xmark"),
                                       action: #selector(RiverbedSplitViewController.signOut))
        let bottomFileCommandsMenu = UIMenu(options: .displayInline, children: [signOutCommand])
        builder.insertChild(bottomFileCommandsMenu, atEndOfMenu: .file)
    }
    
    private func buildViewMenu(with builder: UIMenuBuilder) {
        let reloadBoardsCommand = UIKeyCommand(title: "Reload Boards",
                                               image: UIImage(systemName: "arrow.clockwise"),
                                               action: #selector(RiverbedSplitViewController.reloadBoards(_:)),
                                               input: "r",
                                               modifierFlags: [.command, .shift])
        
        let additionalViewCommandsMenu = UIMenu(options: .displayInline, children: [reloadBoardsCommand])
        builder.insertChild(additionalViewCommandsMenu, atEndOfMenu: .view)
    }
    
    private func buildBoardMenu(with builder: UIMenuBuilder) {
        let boardMenu = UIMenu(title: "Board", children: [
            UIKeyCommand(title: "Reload Board",
                         image: UIImage(systemName: "arrow.clockwise"),
                         action: #selector(BoardViewController.refreshBoardData(_:)),
                         input: "r",
                         modifierFlags: .command),
            UICommand(title: "Board Settings",
                      image: UIImage(systemName: "gear"),
                      action: #selector(BoardViewController.editBoard)),
            UICommand(title: "New Column",
                      image: UIImage(systemName: "plus.square"),
                      action: #selector(BoardViewController.addColumn(_:))),
            UIMenu(options:.displayInline, children: [
                UICommand(title: "Delete Board",
                          image: UIImage(systemName: "trash"),
                          action: #selector(BoardViewController.deleteBoard))
            ])
        ])
        
        builder.insertSibling(boardMenu, beforeMenu: .window)
    }
    
    private func buildCardMenu(with builder: UIMenuBuilder) {
        let cardMenu = UIMenu(title: "Card", children: [
            UICommand(title: "Configure Fields",
                         image: UIImage(systemName: "wrench"),
                         action: #selector(CardViewController.beginEditing(_:))),
            UIKeyCommand(title: "Close Card",
                         image: UIImage(systemName: "xmark"),
                         action: #selector(CardViewController.dismissVC(_:)),
                         input: UIKeyCommand.inputEscape),
            UIMenu(options: .displayInline, children: [
                UICommand(title: "New Field",
                          image: UIImage(systemName: "plus.square"),
                          action: #selector(CardViewController.addField(_:))),
                UICommand(title: "New Button",
                          image: UIImage(systemName: "plus.square"),
                          action: #selector(CardViewController.addButton(_:))),
                UICommand(title: "New Button Menu",
                          image: UIImage(systemName: "plus.square"),
                          action: #selector(CardViewController.addButtonMenu(_:))),
            ]),
            UIKeyCommand(title: "Delete Card",
                         image: UIImage(systemName: "trash"),
                         action: #selector(CardViewController.deleteCard(_:)),
                         input: UIKeyCommand.inputDelete,
                         modifierFlags: .command)
        ])
        
        builder.insertSibling(cardMenu, beforeMenu: .window)
    }
    
//    private func buildWindowMenu(with builder: UIMenuBuilder) {
//        let additionalWindowCommandsMenu = UIMenu(options: .displayInline, children: [closeModalCommand])
//        builder.insertChild(additionalWindowCommandsMenu, atEndOfMenu: .window)
//    }
    
}
