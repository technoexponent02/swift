//
//  BlockedCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 05/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class BlockedCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var unblock: UIButton!
    @IBOutlet weak var specialization: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
