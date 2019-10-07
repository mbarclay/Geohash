//
//  Geohash.swift
//  Geohash
//
//  Created by Malcolm Barclay on 11/04/2018.
//  Based on work by Maxim Veksler on 5/4/15.
//  Based on work by David Troy https://github.com/davetroy/geohash-js/blob/master/geohash.js
//
//  (c) 2018 Malcolm Barclay.
//  Distributed under the MIT License
//

import Foundation
import CoreLocation

enum GeohashError: Error {
    case runtimeError(String)
}

// - MARK: Public

public struct Geohash {
    
    public static func encode(coordinate: CLLocationCoordinate2D, precision: Int) -> String {
        return boundingBoxFor(coordinate: coordinate, precision: precision).hash
    }
    
    public static func decode(_ hash: String) throws -> (latitude: Double, longitude: Double) {
        // ensure the hash uses valid characters
        for character in hash {
            if decimalToBase32Map.firstIndex(of: character) == nil {
                throw GeohashError.runtimeError("Invalid character in geohash code")
            }
        }
        
        return boundingBoxFor(hash: hash).point
    }
    
    public static func neighbors(_ hash: String) -> [String] {
        // neighbor precision *must* be them same as center'ed bounding box.
        let precision = hash.count
        let box = boundingBoxFor(hash: hash)
        let n = neighbor(boundingBox: box, direction: .north, precision: precision) // n
        let s = neighbor(boundingBox: box, direction: .south, precision: precision) // s
        let e = neighbor(boundingBox: box, direction: .east, precision: precision)  // e
        let w = neighbor(boundingBox: box, direction: .west, precision: precision)  // w
        let ne = neighbor(boundingBox: n, direction: .east, precision: precision)   // ne
        let nw = neighbor(boundingBox: n, direction: .west, precision: precision)   // nw
        let se = neighbor(boundingBox: s, direction: .east, precision: precision)   // se
        let sw = neighbor(boundingBox: s, direction: .west, precision: precision)   // sw
        
        // in clockwise order
        return [n.hash, ne.hash, e.hash, se.hash, s.hash, sw.hash, w.hash, nw.hash]
    }
    
}

// - MARK: Private

private extension Geohash {
    
    static let decimalToBase32Map = Array("0123456789bcdefghjkmnpqrstuvwxyz")
    static let base32BitflowInit: UInt8 = 0b10000
    
    static func boundingBoxFor(coordinate: CLLocationCoordinate2D, precision: Int) -> BoundingBox {
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)
        
        // to be generated result.
        var geohash = String()
        
        // Loop helpers
        var parity = Parity.even
        var base32char = 0
        var bit = base32BitflowInit
        
        repeat {
            switch parity {
            case .even:
                let mid = (lon.0 + lon.1) / 2
                if coordinate.longitude >= mid {
                    base32char |= Int(bit)
                    lon.0 = mid
                } else {
                    lon.1 = mid
                }
            case .odd:
                let mid = (lat.0 + lat.1) / 2
                if coordinate.latitude >= mid {
                    base32char |= Int(bit)
                    lat.0 = mid
                } else {
                    lat.1 = mid
                }
            }
            
            // flip parity and shift to next bit
            parity = !parity
            bit >>= 1
            
            if bit == 0b00000 {
                geohash += String(decimalToBase32Map[base32char])
                bit = base32BitflowInit // set next character round
                base32char = 0
            }
            
        } while geohash.count < precision
        
        return BoundingBox(hash: geohash, north: lat.1, west: lon.0, south: lat.0, east: lon.1)
    }
    
    static func boundingBoxFor(hash: String) -> BoundingBox {
        var parity = Parity.even
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)
        
        for character in hash {
            let bitmap = decimalToBase32Map.firstIndex(of: character)!
            var mask = Int(base32BitflowInit)
            while mask != 0 {
                switch parity {
                case .even:
                    if bitmap & mask != 0 {
                        lon.0 = (lon.0 + lon.1) / 2
                    } else {
                        lon.1 = (lon.0 + lon.1) / 2
                    }
                case .odd:
                    if bitmap & mask != 0 {
                        lat.0 = (lat.0 + lat.1) / 2
                    } else {
                        lat.1 = (lat.0 + lat.1) / 2
                    }
                }
                parity = !parity
                mask >>= 1
            }
        }
        
        return BoundingBox(hash: hash, north: lat.1, west: lon.0, south: lat.0, east: lon.1)
    }
    
    static func neighbor(boundingBox: BoundingBox, direction: Bearing, precision: Int) -> BoundingBox {
        switch direction {
        case .north:
            let newLatitude = boundingBox.point.latitude + boundingBox.size.latitude // North is upper in the latitude scale
            return boundingBoxFor(coordinate: CLLocationCoordinate2D(latitude: newLatitude, longitude: boundingBox.point.longitude), precision: precision)
        case .south:
            let newLatitude = boundingBox.point.latitude - boundingBox.size.latitude // South is lower in the latitude scale
            return boundingBoxFor(coordinate: CLLocationCoordinate2D(latitude: newLatitude, longitude: boundingBox.point.longitude), precision: precision)
        case .east:
            let newLongitude = boundingBox.point.longitude + boundingBox.size.longitude // East is bigger in the longitude scale
            return boundingBoxFor(coordinate: CLLocationCoordinate2D(latitude: boundingBox.point.latitude, longitude: newLongitude), precision: precision)
        case .west:
            let newLongitude = boundingBox.point.longitude - boundingBox.size.longitude // West is lower in the longitude scale
            return boundingBoxFor(coordinate: CLLocationCoordinate2D(latitude: boundingBox.point.latitude, longitude: newLongitude), precision: precision)
        }
    }
    
}
