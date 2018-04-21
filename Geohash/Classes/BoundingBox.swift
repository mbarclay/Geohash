//
//  BoundingBox.swift
//  Geohash
//
//  Created by Malcolm Barclay on 11/04/2018.
//  Copyright © 2018 Malcolm Barclay. All rights reserved.
//

import Foundation

public struct BoundingBox {
    let hash: String
    
    let north: Double // top latitude
    let west: Double // left longitude    
    let south: Double // bottom latitude
    let east: Double // right longitude
    
    var point: (latitude: Double, longitude: Double) {
        let latitude = (self.north + self.south) / 2
        let longitude = (self.east + self.west) / 2
        return (latitude: latitude, longitude: longitude)
    }
    
    var size: (latitude: Double, longitude: Double) {
        let latitude = north - south
        let longitude = east - west
        return (latitude: latitude, longitude: longitude)
    }
}
