//
//  ConstantFile.swift
//  Video Call App
//
//  Created by IOS MAC5 on 16/01/18.
//  Copyright © 2018 IOS MAC5. All rights reserved.
//

import Foundation
import SocketIO

var BASE_URL = ""
let Profile_Image_base_url = ""
let pet_Image_base_url = ""
let user_base_url = ""
let manager = SocketManager(socketURL: URL(string: "")!, config: [.log(true), .compress])
let socket = manager.defaultSocket
