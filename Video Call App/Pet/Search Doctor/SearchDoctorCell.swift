//
//  SearchDoctorCell.swift
//  Video Call App
//
//  Created by IOS MAC5 on 02/02/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import UIKit

class SearchDoctorCell: UITableViewCell {

    @IBOutlet weak var doctorDetails: UIButton!
    @IBOutlet weak var chatNowButton: UIButton!
    @IBOutlet weak var doctorDescription: UILabel!
    @IBOutlet weak var doctorSpecialization: UILabel!
    @IBOutlet weak var doctorExpreiance: UILabel!
    @IBOutlet weak var doctorAddress: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var doctorImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
