//
//  PetAcceptedCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 07/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class PetAcceptedCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var specialization: UILabel!
    @IBOutlet weak var chatPage: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
