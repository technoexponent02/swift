//
//  SenderOnlyFileCell.swift
//  VetRedirect
//
//  Created by IOS MAC5 on 01/12/17.
//  Copyright © 2017 Blusyscorp. All rights reserved.
//

import UIKit

class SenderOnlyFileCell: UITableViewCell {

    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var seenImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
