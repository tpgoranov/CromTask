//
//  ParserTest.swift
//  ParserTest
//
//  Created by Todor Goranov on 06/11/2022.
//

import XCTest
import Foundation

class ParserTest: XCTestCase {
    var testParser: Parser?
    override func setUpWithError() throws {
        testParser = Parser()
        try testParser?.readTimeArgumentIfExists(arguments: ["","18:10"])
    }

    
    func testValidation() throws {
        
        XCTAssertThrowsError( try testParser?.readTimeArgumentIfExists(arguments: ["","24:10"])) { error in
            XCTAssertEqual(error as! ParserError, ParserError.InvalidHours)
        }
        
        XCTAssertThrowsError( try testParser?.readTimeArgumentIfExists(arguments: ["","23:61"])) { error in
            XCTAssertEqual(error as! ParserError, ParserError.InvalidMinutes)
        }
        
        XCTAssertThrowsError( try testParser?.parseLine(line: "30 /bin/run_me_daily")) { error in
            XCTAssertEqual(error as! ParserError, ParserError.WrongNumberOfParameters)
        }
        
        XCTAssertThrowsError( try testParser?.parseLine(line: "30 34 /bin/run_me_daily")) { error in
            XCTAssertEqual(error as! ParserError, ParserError.InvalidHours)
        }
        
        XCTAssertThrowsError( try testParser?.parseLine(line: "78 23 /bin/run_me_daily")) { error in
            XCTAssertEqual(error as! ParserError, ParserError.InvalidMinutes)
        }
    }
    
    func testExactTime() throws {
        XCTAssertEqual(try testParser?.parseLine(line: "30 1 /bin/run_me_daily"), "01:30 tomorrow - /bin/run_me_daily")
        XCTAssertEqual(try testParser?.parseLine(line: "00 00 /bin/run_me_daily"), "00:00 tomorrow - /bin/run_me_daily")
        XCTAssertEqual(try testParser?.parseLine(line: "3 1 /bin/run_me_daily"), "01:03 tomorrow - /bin/run_me_daily")
        XCTAssertEqual(try testParser?.parseLine(line: "10 18 /bin/run_me_daily"), "18:10 today - /bin/run_me_daily")
        XCTAssertEqual(try testParser?.parseLine(line: "10 19 /bin/run_me_daily"), "19:10 today - /bin/run_me_daily")
        XCTAssertEqual(try testParser?.parseLine(line: "59 23 /bin/run_me_daily"), "23:59 today - /bin/run_me_daily")
    }
    
    func testEveryHour() throws {
        XCTAssertEqual(try testParser?.parseLine(line: "45 * /bin/run_me_hourly"), "18:45 today - /bin/run_me_hourly")
        XCTAssertEqual(try testParser?.parseLine(line: "10 * /bin/run_me_hourly"), "18:10 today - /bin/run_me_hourly")
        XCTAssertEqual(try testParser?.parseLine(line: "5 * /bin/run_me_hourly"), "19:05 today - /bin/run_me_hourly")
        XCTAssertEqual(try testParser?.parseLine(line: "5 * /bin/run_me_hourly"), "19:05 today - /bin/run_me_hourly")
        
        try testParser?.readTimeArgumentIfExists(arguments: ["","23:56"])
        XCTAssertEqual(try testParser?.parseLine(line: "5 * /bin/run_me_hourly"), "00:05 tomorrow - /bin/run_me_hourly")
        XCTAssertEqual(try testParser?.parseLine(line: "00 * /bin/run_me_hourly"), "00:00 tomorrow - /bin/run_me_hourly")
        
        try testParser?.readTimeArgumentIfExists(arguments: ["","0:0"])
        XCTAssertEqual(try testParser?.parseLine(line: "0 * /bin/run_me_hourly"), "00:00 today - /bin/run_me_hourly")
    }
   
    func testEveryMinute() throws {
        XCTAssertEqual(try testParser?.parseLine(line: "* 10 /bin/run_me_every_minute"), "10:00 tomorrow - /bin/run_me_every_minute")
        XCTAssertEqual(try testParser?.parseLine(line: "* 9 /bin/run_me_every_minute"), "09:00 tomorrow - /bin/run_me_every_minute")
        XCTAssertEqual(try testParser?.parseLine(line: "* 19 /bin/run_me_every_minute"), "19:00 today - /bin/run_me_every_minute")
        XCTAssertEqual(try testParser?.parseLine(line: "* 0 /bin/run_me_every_minute"), "00:00 tomorrow - /bin/run_me_every_minute")
    }
    
    func testEveryMinuteEveryHour() throws {
        XCTAssertEqual(try testParser?.parseLine(line: "* * /bin/run_me_every_minute"), "18:10 today - /bin/run_me_every_minute")
        
        try testParser?.readTimeArgumentIfExists(arguments: ["","23:59"])

        XCTAssertEqual(try testParser?.parseLine(line: "* * /bin/run_me_every_minute"), "23:59 today - /bin/run_me_every_minute")
    }
}
