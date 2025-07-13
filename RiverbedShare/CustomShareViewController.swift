import UIKit

class CustomShareViewController: UIViewController {
    
    private let attachmentHandler = AttachmentHandler()
    private let webhookStore = WebhookStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CustomShareViewController viewDidLoad()")
        
        guard let context = extensionContext,
            let items = context.inputItems as? [NSExtensionItem],
            let item = items.first,
            let attachments = item.attachments else {
                alert(message: "An error occurred: URL not found", completion: self.done)
                return
        }

        attachmentHandler.getURL(attachments: attachments) { [self] result in
            switch result {
            case .success(let sharedURL):
                let bodyDict = [
                    "url": sharedURL.absoluteString,
//                    "title": self.contentText // TODO: prompt user
                    ]
                
                // TEMP: jump straight to posting webhook, without prompting user for title
                webhookStore.postWebhook(bodyDict: bodyDict) { result in
                    switch result {
                    case .success:
                        self.alert(
                            message: "Link saved.",
                            completion: self.done)
                    case .failure(let error):
                        self.alert(
                            message: error.localizedDescription,
                            completion: self.done)
                    }
                }
            case .failure(let error):
                self.alert(
                    message: "An error occurred: \(error.localizedDescription)",
                    completion: self.done)
            }
        }
    }
    
    private func alert(message: String, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    private func done() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
