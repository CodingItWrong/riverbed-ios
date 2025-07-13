import UIKit

class CustomShareViewController: UIViewController {
    
    private let attachmentHandler = AttachmentHandler()
    private let webhookStore = WebhookStore()
    
    @IBOutlet private(set) var urlField: UITextField!
    @IBOutlet private(set) var titleField: UITextField!
    @IBOutlet private(set) var saveButton: UIButton!
    @IBOutlet private(set) var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 26, *) {
            saveButton.configuration = .prominentGlass()
            saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            
            cancelButton.configuration = .glass()
            cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        }
        
        prepopulateTextFields()
    }
                
    @IBAction func save() {
        guard let url = urlField.text,
              let title = titleField.text else {
            fatalError("unreachable")
        }
        
        let bodyDict = ["url": url, "title": title]
        
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
    }
    
    @IBAction func cancel() {
        self.done()
    }
    
    // MARK: - helper methods
    
    private func prepopulateTextFields() {
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
                self.urlField.text = sharedURL.absoluteString
                // not pre-setting title currently
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
