import UIKit

protocol NoteDelegate {
    func saveNewNote(title: String, date: Date, text: String, img: Data)
}

class NoteDetailController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: PROPERTIES
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, YYYY hh:mm"
        return dateFormatter
    }()
    
    var noteData: Note! {
        didSet {
            textView.text = noteData.title
            dateLabel.text = dateFormatter.string(from: noteData.date ?? Date())
            descriptionTextView.text = noteData.text
            imageView.image = noteData.img
        }
    }
    
    var delegate: NoteDelegate?
   // let image = UIImage(data)
    
    // MARK: PROPERTIES UI
    fileprivate var textView: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Add your notes"
        textField.isEditable = true
        textField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return textField
    }()
    
    fileprivate var descriptionTextView: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "Add your additional text here"
        textField.isEditable = true
        textField.textColor = .black
        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        textField.isSelectable = true
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    fileprivate lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        label.text = dateFormatter.string(from: Date())
        label.textAlignment = .center
        return label
    }()
    
    /// Imageview
    fileprivate lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = .lightGray
        imgView.layer.cornerRadius = 8
        imgView.frame.size.width = 375
        imgView.frame.size.height = 240
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        imgView.frame.origin = CGPoint(x: 20, y: 520)
        //imgView.center = self.view.center
        return imgView
    }()
    
    
    // MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.layer.cornerRadius = 12
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        view.backgroundColor = .white
        setupUI()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveImage))
        imageView.layer.cornerRadius = 8
        //imageView.image = UIImage(data)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.noteData == nil {
            delegate?.saveNewNote(title: textView.text, date: Date(), text: descriptionTextView.text, img: imageView.Data)
        } else {
            // update our note here
            guard let newText = self.textView.text else {
                return
            }
            /// Updates Description text
            guard let newDescription = self.descriptionTextView.text else {
                return
            }
            CoreDataManager.shared.saveUpdatedNote(note: self.noteData, newText: newText, newDescription: newDescription, newImage: newImage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraButtonPressed))
        ]
        
        self.toolbarItems = items
    }
    
    // MARK: FUNCTIONS
    @objc func saveImage() {
        print("SaveButtonPressedStarts")
        if let imageData = imageView.image?.pngData() {
            CoreDataManager.shared.saveImage(data: imageData)
        }
        print("SaveButtonPressedEnds")
    }
    
    
    // MARK: IMAGE FUNCTIONS
    @objc func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        imageView.image = userPickedImage

        picker.dismiss(animated: true)
    }
    
    // MARK: UI
    fileprivate func setupUI() {
        view.addSubview(dateLabel)
        view.addSubview(textView)
        view.addSubview(descriptionTextView)
        view.addSubview(imageView)
        
        dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -640).isActive = true
        
        descriptionTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 280).isActive = true
        descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -440).isActive = true
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 400).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -160).isActive = true
    }
    
}
