//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        guard builder.system == .main else { return }
        
        let newSceneMenu = builder.menu(for: .newScene)
        builder.remove(menu: .newScene)

        let newCardCommand = UIKeyCommand(title: "New Card",
                                          action: #selector(BoardViewController.addCard(_:)),
                                          input: "n",
                                          modifierFlags: [.command])
        var fileMenuCommands = [newCardCommand]
        if let newSceneCommand = newSceneMenu?.children.first as? UIKeyCommand,
            let action = newSceneCommand.action,
            let input = newSceneCommand.input {
            let myNewSceneCommand = UIKeyCommand(title: newSceneCommand.title,
                                                 action: action,
                                                 input: input,
                                                 modifierFlags: newSceneCommand.modifierFlags.union(.shift))
            fileMenuCommands.append(myNewSceneCommand)
        }
        let additionalFileCommandsMenu = UIMenu(options: .displayInline, children: fileMenuCommands)
        builder.insertChild(additionalFileCommandsMenu, atStartOfMenu: .file)

        let deleteCardCommand = UIKeyCommand(title: "Delete Card",
                                             action: #selector(CardViewController.deleteCard(_:)),
                                             input: UIKeyCommand.inputDelete,
                                             modifierFlags: .command)
        let additionalEditCommandsMenu = UIMenu(options: .displayInline, children: [deleteCardCommand])
        builder.insertChild(additionalEditCommandsMenu, atEndOfMenu: .edit)

        let refreshCommand = UIKeyCommand(title: "Refresh Board",
                                          action: #selector(BoardViewController.refreshBoardData(_:)),
                                          input: "r",
                                          modifierFlags: .command)
        let additionalViewCommandsMenu = UIMenu(options: .displayInline, children: [refreshCommand])
        builder.insertChild(additionalViewCommandsMenu, atEndOfMenu: .view)

        let closeModalCommand = UIKeyCommand(title: "Close Card",
                                             action: #selector(CardViewController.dismissVC(_:)),
                                             input: UIKeyCommand.inputEscape)
        let additionalWindowCommandsMenu = UIMenu(options: .displayInline, children: [closeModalCommand])
        builder.insertChild(additionalWindowCommandsMenu, atEndOfMenu: .window)
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
