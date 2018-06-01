//
//  AcceptedCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 05/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class AcceptedCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoneNo: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
   @IBOutlet weak var chatPage: UIButton!
    @IBOutlet weak var specialization: UILabel!
    @IBOutlet weak var PetDetailsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
