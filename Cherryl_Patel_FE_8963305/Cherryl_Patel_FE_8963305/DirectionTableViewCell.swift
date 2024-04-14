

import UIKit

class DirectionTableViewCell: UITableViewCell {

    @IBOutlet weak var sceneType: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var dataFrom: UILabel!
    
    
    @IBOutlet weak var startPoint: UILabel!
    
    @IBOutlet weak var endPoint: UILabel!
    
    
    
    @IBOutlet weak var travelMethod: UILabel!
    
    
    @IBOutlet weak var totalDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
