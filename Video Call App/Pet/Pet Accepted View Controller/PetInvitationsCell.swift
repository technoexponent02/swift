//
//  PetInvitationsCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 07/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class PetInvitationsCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDetails: UILabel!
    @IBOutlet weak var acceptButtonClick: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
