import UIKit

class NoteCell: UITableViewCell {
    
    var noteData: Note! {
        didSet {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            
            noteTitle.text = noteData.title
            dateLabel.text = dateFormatter.string(from: noteData.date ?? Date())
            descriptionTextView.text = noteData.text
            
        }
    }
    
    /// Note title
    fileprivate var noteTitle: UILabel = {
        let label = UILabel()
        label.text = "Places to take photos"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    /// Date label
    fileprivate var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "4/6/2019"
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        return label
    }()
        
    /// Preview label
    fileprivate var descriptionTextView: UILabel = {
        let label = UILabel()
        label.text = "The note text will go here for note preview..."
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = UIColor.gray.withAlphaComponent(0.8)
        return label
    }()
    
    /// horizontal stack view
    fileprivate lazy var horizontalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [dateLabel, descriptionTextView, UIView()])
        s.axis = .horizontal
        s.spacing = 10
        s.alignment = .leading
        return s
    }()
    
    /// vertical stack view
    fileprivate lazy var verticalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [noteTitle, horizontalStackView])
        s.axis = .vertical
        s.spacing = 4
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        //contentView.backgroundColor = .cyan
        contentView.addSubview(verticalStackView)
        verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     
}


