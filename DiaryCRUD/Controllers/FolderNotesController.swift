import UIKit

// MARK: EXTENSION NoteDelegate
extension FolderNotesController: NoteDelegate {
    func saveNewNote(title: String, date: Date, text: String) {
        let newNote = CoreDataManager.shared.createNewNote(title: title, date: date, text: text, noteFolder: self.folderData) ///Creates new note to the list and coredata
        notes.append(newNote)
        filteredNotes.append(newNote)
        self.tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .fade)
    }
}

class FolderNotesController: UITableViewController, UISearchBarDelegate {
    
    // MARK: PROPERTIES
    let searchController = UISearchController(searchResultsController: nil)
    
    var folderData: NoteFolder! {
        didSet {
            notes = CoreDataManager.shared.fetchNotes(from: folderData)
            filteredNotes = notes
        }
    }
    
    fileprivate var notes = [Note]()
    fileprivate var filteredNotes = [Note]()
    var cachedText: String = ""
    fileprivate let CELL_ID:String = "CELL_ID"
    
    // MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Folder notes"
        
        setupTableView()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let items: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .organize, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "\(notes.count) Notes", style: .done, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.createNewNote))
        ]
        self.toolbarItems = items
        
        tableView.reloadData()
    }
    
    // MARK: FUNCTIONS
    
    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true /// true
        //searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self ///as! UISearchBarDelegate
    }
    
    @objc fileprivate func createNewNote() {
        let noteDetailController = NoteDetailController()
        
        noteDetailController.delegate = self
        
        navigationController?.pushViewController(noteDetailController, animated: true)
    }
    
    fileprivate func setupTableView() {
        tableView.register(NoteCell.self, forCellReuseIdentifier: CELL_ID)
    }
    
    
    // MARK: SEARCH: FILTERING DATA
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = notes.filter({ (note) -> Bool in
            return note.title?.lowercased().contains(searchText.lowercased()) ?? false
        })
        if searchBar.text!.isEmpty && filteredNotes.isEmpty {
            filteredNotes = notes
        }
        cachedText = searchText
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !cachedText.isEmpty && !filteredNotes.isEmpty {
            searchController.searchBar.text = cachedText
        }
    }
    
} /// End of main class

// MARK: EXTENSION - TableView Data Source
extension FolderNotesController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            print("trying to delete item at indexpath", indexPath)
            
            // MARK: DELETING
            let targetRow = indexPath.row
            
            if CoreDataManager.shared.deleteNote(note: self.notes[targetRow]) {
                self.notes.remove(at: targetRow)
                self.filteredNotes.remove(at: targetRow)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } /// Deletes from Core Data
        }
        actions.append(deleteAction)
        return actions
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredNotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! NoteCell ///Casting =>  as! NoteCell  to custom cell
        
        let noteForRow = self.filteredNotes[indexPath.row]
        cell.noteData = noteForRow
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    ///Push content to NoteDetailController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteDetailController = NoteDetailController()
        let noteForRow = self.filteredNotes[indexPath.row]
        noteDetailController.noteData = noteForRow
        
        navigationController?.pushViewController(noteDetailController, animated: true)
    }
    
}
