//
//  Parity.swift
//  Geohash
//
//  Created by Malcolm Barclay on 11/04/2018.
//  Copyright © 2018 Malcolm Barclay. All rights reserved.
//

import Foundation

public enum Parity {
    case even, odd
}

internal prefix func ! (parity: Parity) -> Parity {
    return parity == .even ? .odd : .even
}
