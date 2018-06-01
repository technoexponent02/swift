//
//  PetListCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 22/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class PetListCell: UITableViewCell {

    @IBOutlet weak var PetImage: UIImageView!
    @IBOutlet weak var PetName: UILabel!
    @IBOutlet weak var PetDetails: UILabel!
    
    @IBOutlet weak var ColorView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
