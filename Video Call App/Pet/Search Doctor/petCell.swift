//
//  petCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 06/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class petCell: UITableViewCell {

    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
