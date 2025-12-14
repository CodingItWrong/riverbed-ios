import UIKit

class CustomShareViewController: UIViewController {
    
    private let attachmentHandler = AttachmentHandler()
    private let webhookStore = WebhookStore()
    
    @IBOutlet private(set) var urlField: UITextView!
    @IBOutlet private(set) var titleField: UITextView!
    @IBOutlet private(set) var saveButton: UIButton!
    @IBOutlet private(set) var cancelButton: UIButton!
    @IBOutlet private(set) var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.view.tintColor = ColorTheme.defaultUIColor
            
            let fields: [UIView] = [self.urlField, self.titleField]
            fields.forEach { (field) in
                if #unavailable(iOS 26) {
                    field.layer.cornerRadius = 5
                }
                field.layer.borderWidth = 1
                field.layer.borderColor = UIColor.separator.cgColor
            }
            
            if #available(iOS 26, *) {
                self.saveButton.configuration = .prominentGlass()
                self.saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
                
                self.cancelButton.configuration = .glass()
                self.cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            }
            
            self.prepopulateTextFields()
        }
    }
                
    @IBAction func save() {
        guard let url = urlField.text,
              let title = titleField.text else {
            fatalError("unreachable")
        }
        
        let bodyDict = ["url": url, "title": title]
        
        saveButton.isEnabled = false
        
        webhookStore.postWebhook(bodyDict: bodyDict) { result in
            switch result {
            case .success:
                self.alert(
                    message: "Link saved.",
                    completion: self.done)
            case .failure(let error):
                self.saveButton.isEnabled = true
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
        loadingIndicator.startAnimating()
//        loadingIndicator.isHidden = false
//        print("showed loading indicator")

        guard let context = extensionContext,
              let items = context.inputItems as? [NSExtensionItem],
              let item = items.first,
              let attachments = item.attachments else {
            alert(message: "An error occurred: URL not found", completion: self.done)
            return
        }
        
        attachmentHandler.getURL(attachments: attachments) { [self] result in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
//                self.loadingIndicator.isHidden = true
//                print("hid loading indicator")
                
                switch result {
                case .success(let sharedURL):
                    self.urlField.text = sharedURL.absoluteString
                    self.titleField.text = "" // not pre-setting title currently
                case .failure(let error):
                    self.alert(
                        message: "An error occurred: \(error.localizedDescription)",
                        completion: self.done)
                }
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
