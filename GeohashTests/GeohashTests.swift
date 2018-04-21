//
//  GeohashTests.swift
//  GeohashTests
//
//  Created by Malcolm Barclay on 11/04/2018.
//  Copyright © 2018 Malcolm Barclay. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Geohash

class GeohashTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNeigbour() {
        let geohash = Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: 51.510706, longitude: -0.0669724), precision: 6)
        print(geohash)
        
        let neighbours = Geohash.neighbors(geohash)
        print(neighbours as Any)
    }
        
    // - MARK: encode
    func testEncode() {
        // geohash.org
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: -25.383, longitude: -49.266), precision: 8), "6gkzwgjt")
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: -25.382708, longitude: -49.265506), precision: 12), "6gkzwgjzn820")
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: -25.427, longitude: -49.315), precision: 8), "6gkzmg1u")
        
        // Geohash Tool
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: -31.953, longitude: 115.857), precision: 8), "qd66hrhk")
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: 38.89710201881826, longitude: -77.03669792041183), precision: 12), "dqcjqcp84c6e")
        
        // Narrow samples.
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: 42.6, longitude: -5.6), precision: 5), "ezs42")
    }
    
    func testEncodeDefaultPrecision() {
        // Narrow samples.
        XCTAssertEqual(Geohash.encode(coordinate: CLLocationCoordinate2D(latitude: 42.6, longitude: -5.6), precision: 5), "ezs42")
        // XCTAssertEqual(Geohash.encode(latitude: 0, longitude: 0), "s000") // => "s0000" :( hopefully will be resovled by #Issue:1
    }
    
    // - MARK: decode
    /// Testing latitude & longitude decode correctness, with epsilon precision.
    func aDecodeUnitTest(_ hash: String, _ expectedLatitude: Double, _ expectedLongitude: Double) {
        do {
            let (latitude, longitude) = try Geohash.decode(hash)
            XCTAssertEqual(latitude, expectedLatitude, accuracy: Double(Float.ulpOfOne))
            XCTAssertEqual(longitude, expectedLongitude, accuracy: Double(Float.ulpOfOne))
        } catch {
            XCTFail("Failed to decode hash: \(hash)")
        }
    }
    
    func testDecode() {
        aDecodeUnitTest("ezs42", 42.60498046875, -5.60302734375)
        aDecodeUnitTest("spey61y", 43.296432495117, 5.3702545166016)
    }
    
    func testDecodeInvalidHash() {
        do {
            _ = try Geohash.decode("spey61~*")
        } catch {
            let myError = error as? GeohashError
            XCTAssert(myError != nil)
        }
    }
    
    // - MARK: neighbors
    func testNeighbors() {
        // Bugrashov, Tel Aviv, Israel
        XCTAssertEqual(["sv8wrqfq", "sv8wrqfw", "sv8wrqft", "sv8wrqfs", "sv8wrqfk", "sv8wrqfh", "sv8wrqfj", "sv8wrqfn"], Geohash.neighbors("sv8wrqfm"))
        // Meridian Gardens
        XCTAssertEqual(["gcpvpbpbp", "u10j00000", "u10hbpbpb", "u10hbpbp8", "gcpuzzzzx", "gcpuzzzzw", "gcpuzzzzy", "gcpvpbpbn"], Geohash.neighbors("gcpuzzzzz"))
        // Overkills are fun!
        XCTAssertEqual(["cbsuv7ztq4345234323d", "cbsuv7ztq4345234323f", "cbsuv7ztq4345234323c", "cbsuv7ztq4345234323b", "cbsuv7ztq43452343238", "cbsuv7ztq43452343232", "cbsuv7ztq43452343233", "cbsuv7ztq43452343236"], Geohash.neighbors("cbsuv7ztq43452343239"))
        // France
        XCTAssertEqual(["u001", "u003", "u002", "spbr", "spbp", "ezzz", "gbpb", "gbpc"], Geohash.neighbors("u000"))
    }
    
}
