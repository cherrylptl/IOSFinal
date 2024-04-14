
import UIKit

class WeatherTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sceneType: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var dataFrom: UILabel!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    
    @IBOutlet weak var temp: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var wind: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
