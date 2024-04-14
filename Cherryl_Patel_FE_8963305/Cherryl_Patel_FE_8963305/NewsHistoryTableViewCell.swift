
import UIKit

class NewsHistoryTableViewCell: UITableViewCell {



    @IBOutlet weak var sceneType: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var dataFrom: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var discription: UITextView!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var author: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
