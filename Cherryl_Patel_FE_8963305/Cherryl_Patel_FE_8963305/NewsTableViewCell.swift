
import UIKit

class NewsTableViewCell: UITableViewCell {
    
    
    static let identifier = "NewsTableViewCell"
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var news: UILabel!
    
    @IBOutlet weak var source: UILabel!
    
    @IBOutlet weak var author: UILabel!
    
    public func configure(title: String?, description: String?, source: String?, author: String?) {
        if let title = title {
            self.title.text = title
        }
        if let description = description {
            self.news.text = description
        }
        if let source = source {
            self.source.text = source
        }
        if let author = author {
            self.author.text = author
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
