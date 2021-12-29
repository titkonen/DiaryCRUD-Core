import CoreData

struct CoreDataManager {
    
    // MARK: PROPERTIES
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ViestitApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, err) in
            if let err = err {
                fatalError("Loading of stores failed \(err)")
            }
            
        })
        return container
    }()
    
    // MARK: Create Note folder
    func createNoteFolder(title: String) -> NoteFolder { ///NoteFolder is a Coredata entity name
        let context = persistentContainer.viewContext
        let newNoteFolder = NSEntityDescription.insertNewObject(forEntityName: "NoteFolder", into: context)
        newNoteFolder.setValue(title, forKey: "title")
        
        do {
            try context.save()
            return newNoteFolder as! NoteFolder
        } catch let err {
            print("Failed to save new note folder", err)
          return newNoteFolder as! NoteFolder
        }
    }
    
    // MARK: Fetch noteFolders
    func fetchNoteFolders() -> [NoteFolder] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NoteFolder>(entityName: "NoteFolder")
        
        do {
            let noteFolders = try context.fetch(fetchRequest)
            return noteFolders
        } catch let err {
            print("Failed to fetch note folders",err)
            return []
        }
    }
    
    // MARK:  Delete note folders
    func deleteNoteFolder(noteFolder: NoteFolder) -> Bool {
        let context = persistentContainer.viewContext
        context.delete(noteFolder)
        
        do {
            try context.save()
            return true
        } catch let err {
            print("Error deleting note folders entity instance", err)
            return false
        }
    }
    
    // MARK: NOTE FUNCTIONS
//    // MARK: Create New Note
//    func createNewNote(title: String, date: Date, text: String, noteFolder: NoteFolder) -> Note {
//        let context = persistentContainer.viewContext
//        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
//
//        //newNote.setValue(title, forKey: "title")
//        newNote.title = title
//        newNote.text = text
//        newNote.date = date
//        newNote.noteFolder = noteFolder
//
//        do {
//            try context.save()
//            return newNote
//        } catch let err {
//            print("Failed to save new note", err)
//          return newNote
//        }
//    }
    
    // MARK: Create New Note with image property
    func createNewNote(title: String, date: Date, text: String, img: Data, noteFolder: NoteFolder) -> Note {
        let context = persistentContainer.viewContext
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        
        //newNote.setValue(title, forKey: "title")
        newNote.title = title
        newNote.text = text
        newNote.date = date
        newNote.img = img

        newNote.noteFolder = noteFolder
        
        do {
            try context.save()
            return newNote
        } catch let err {
            print("Failed to save new note", err)
          return newNote
        }
    }
    
    // MARK: Fetch Notes
    func fetchNotes(from noteFolder: NoteFolder) -> [Note] {
        guard let folderNotes = noteFolder.notes?.allObjects as? [Note] else {
            return []
        }
        return folderNotes
    }
    
    // MARK:  Delete notes
    func deleteNote(note: Note) -> Bool {
        let context = persistentContainer.viewContext
        context.delete(note)
        
        do {
            try context.save()
            return true
        } catch let err {
            print("Error deleting note entity instance", err)
            return false
        }
    }
    
    // MARK:  Update notes
    func saveUpdatedNote(note: Note, newText: String, newDescription: String, newImage: Data) {
        let context = persistentContainer.viewContext
        
        note.title = newText
        note.text = newDescription
        note.date = Date()
        note.img = newImage
        
        do {
            try context.save()
        } catch let err {
            print("Failed to update note", err)
        }
    }
    
    // MARK:  Save Image
    func saveImage(data: Data) {
        let context = persistentContainer.viewContext
        
        let imageInstance = Note(context: context)
        imageInstance.img = data
            
        do {
            try context.save()
            print("Image is saved11")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    
    
}
