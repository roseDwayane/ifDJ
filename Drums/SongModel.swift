//
//  SongModel.swift
//  Drums
//
//  Created by chang on 2019/1/5.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
struct SongModel {
    
    let songImage:String
    let songFile:String
    
    init(songImage:String,songFile:String) {
        self.songImage = songImage
        self.songFile = songFile
    }
}
