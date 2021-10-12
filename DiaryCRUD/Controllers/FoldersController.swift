import UIKit

//let firstFolderNotes = [
//    Note(title: "UITableViews", date: Date(), text: "Tableviews use protocols to receive data"),
//    Note(title: "Collection views", date: Date(), text: "Collection views can be customize to use protocols to receive data"),
//    Note(title: "Flow layouts", date: Date(), text: "Flow layouts can use protocols to receive data")
//]
//
//let secondFolderNotes = [
//    Note(title: "Detail Views", date: Date(), text: "Detail views use protocols to receive data"),
//    Note(title: "Second views", date: Date(), text: "Second views can be customize to use protocols to receive data"),
//]
//
//var noteFolder: [NoteFolder] = [
//    NoteFolder(title: "Course Notes", notes: firstFolderNotes),
//    NoteFolder(title: "Social media", notes: secondFolderNotes),
//]

var noteFolders = [NoteFolder]() /// noteFolders is the instance reference to point at

class FoldersController: UITableViewController {

    // MARK: PROPERTIES
    fileprivate let CELL_ID:String = "CELL_ID"
    
    fileprivate let headerView: UIView = {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let label = UILabel(frame: CGRect(x: 20, y: 15, width: 100, height: 20))
        label.text = "ICLOUD"
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = .darkGray
        headerView.addBorder(toSide: .bottom, withColor: UIColor.lightGray.withAlphaComponent(0.5).cgColor, andThickness: 0.3)
        headerView.addSubview(label)
        return headerView
    }()
    
    // MARK: VIEW CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor.init(rgb: 0x00FFFF)
        navigationItem.title = "Folders"
        
        noteFolders = CoreDataManager.shared.fetchNoteFolders() // Fetching data
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "New Folder", style: .done, target: self, action: #selector(self.handleAddNewFolder))
        ]
        self.toolbarItems = items
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        self.navigationItem.setRightBarButtonItems([editButton], animated: false)
        self.navigationController?.toolbar.tintColor = .primaryColor
        self.navigationController?.navigationBar.tintColor = UIColor.primaryColor
        
        setupTranslucentViews()
        
        self.tableView.reloadData() /// Reloads tableview and counter "how many notes is in every folder"
    }
    

    var textField: UITextField!
    
    // MARK: FUNCTIONS
    @objc fileprivate func handleAddNewFolder() {
        let addAlert = UIAlertController(title: "New Folder", message: "Enter a name for this folder.", preferredStyle: .alert)
        
        present(addAlert, animated: true)
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            addAlert.dismiss(animated: true)
        }))
        
        addAlert.addTextField { (tf) in
            // reference textfield outside of this method
            self.textField = tf
        }
        
        addAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            addAlert.dismiss(animated: true)
            // Insert a new folder with the correct title
            guard let title = self.textField.text else {
                return
            }
            let newFolder = CoreDataManager.shared.createNoteFolder(title: title) ///Creates new folder to the list and coredata
            noteFolders.append(newFolder)
            self.tableView.insertRows(at: [IndexPath(row: noteFolders.count - 1, section: 0)], with: .fade)
        }))
        
    }
    
    
    fileprivate func setupTableView() {
        tableView.register(FolderCell.self, forCellReuseIdentifier: CELL_ID)
        tableView.tableHeaderView = headerView
    }
    
    fileprivate func getImage(withColor color: UIColor, andSize size: CGSize) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        return image
    }
    
    fileprivate func setupTranslucentViews() {
        let toolbar = self.navigationController?.toolbar
        let navigationBar = self.navigationController?.navigationBar
        
        let slightWhite = getImage(withColor: UIColor.white.withAlphaComponent(0.9), andSize: CGSize(width: 30, height: 30))
        toolbar?.setBackgroundImage(slightWhite, forToolbarPosition: .any, barMetrics: .default)
        toolbar?.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        navigationBar?.setBackgroundImage(slightWhite, for: .default)
        navigationBar?.shadowImage = slightWhite
    }

}

// MARK: EXTENSION - TableView Data Source
extension FoldersController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            
            let noteFolder = noteFolders[indexPath.row]
            if CoreDataManager.shared.deleteNoteFolder(noteFolder: noteFolder) {
                noteFolders.remove(at: indexPath.row) /// Remove rows
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteFolders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! FolderCell
        let folderForRow = noteFolders[indexPath.row]
        cell.folderData = folderForRow
        return cell
    }
    
    ///Tablerow height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folderNotesController = FolderNotesController()
        let folderForRowSelected = noteFolders[indexPath.row]
        folderNotesController.folderData = folderForRowSelected
        
        navigationController?.pushViewController(folderNotesController, animated: true)
    }
    
}

//cell.label.text = folderForRow.title
//cell.countLabel.text = String(folderForRow.notes.count)
