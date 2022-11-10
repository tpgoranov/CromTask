//
//  main.swift
//  CromTask
//
//  Created by Todor Goranov on 06/11/2022.
//

import Foundation

do {
    let parser = Parser()
    try parser.readTimeArgumentIfExists(arguments: CommandLine.arguments)
    while let line = readLine() {
        print(try parser.parseLine(line: line))
    }
}catch ParserError.WrongNumberOfParameters {
    print("Invalid number of parameters.")
} catch ParserError.InvalidHours {
    print("Invalid hours Argument.")
} catch ParserError.InvalidMinutes {
    print("Invalid minutes Argument.")
}

enum ParserError: Error {
    case WrongNumberOfParameters
    case InvalidHours
    case InvalidMinutes
}

class Parser {
    var currentTimeHours = 0
    var currentTimeMinutes = 0
    
    init() {
        let date = Date()
        currentTimeMinutes = Calendar.current.component(.hour, from: date)
        currentTimeHours = Calendar.current.component(.minute, from: date)
    }
    
    func readTimeArgumentIfExists(arguments: [String]) throws {
        if arguments.count < 2 {
            return
        }
        
        let timeComponents = arguments[1].components(separatedBy: ":")
        let minArgument = timeComponents[1]
        let hourArgument = timeComponents[0]
        
        currentTimeHours = try hoursToInt(hours: hourArgument)
        currentTimeMinutes = try minutesToInt(minutes: minArgument)
    }
    
    func parseLine(line:String) throws -> String {
        let components = line.components(separatedBy:" ")
        
        guard components.count == 3 else {
            throw ParserError.WrongNumberOfParameters
        }
        
        let minutes = components[0]
        let hours = components[1]
        let fileName = components[2]
        
        let nextRun = try nextRunDescription(hours: hours, minutes: minutes)
        
        return ("\(nextRun) - \(fileName)")
    }
    
    func nextRunDescription(hours: String, minutes: String) throws -> String {
        let minutesInt = try minutesToInt(minutes: minutes)
        let hoursInt = try hoursToInt(hours: hours)

        switch(hours, minutes) {
        case ("*", "*"):
            return everyMinutEveryHour()
        case ("*", _):
            return hourlyNextRunDescription(givenMinutes: minutesInt)
        case (_, "*"):
            return everyMinuteInHourNextRun(givenHours: hoursInt)
        default :
            return onceDailyNextRunDescription(givenHours: hoursInt, givenMinutes: minutesInt)
        }
    }
}

//Validation
extension Parser {
    func hoursToInt(hours: String) throws -> Int {
        if let h = Int(hours),
                  h < 24 && h >= 0 {
            return h
        } else if hours == "*" {
            return 0
        } else {
            throw ParserError.InvalidHours
        }
    }
    
    func minutesToInt(minutes: String) throws -> Int{
       if let m = Int(minutes),
                  m < 60 && m >= 0 {
            return m
        } else if minutes == "*" {
            return 0
        } else {
            throw ParserError.InvalidMinutes
        }
    }
    
    func timeToString(value: Int) -> String{
        if value < 10 {
            return "0\(value)"
        } else {
            return "\(value)"
        }
    }
}

//Determine Next Run
extension Parser {
    func onceDailyNextRunDescription(givenHours: Int, givenMinutes: Int) -> String {
        if givenHours == currentTimeHours && givenMinutes >= currentTimeMinutes
            || givenHours > currentTimeHours {
            return "\(timeToString(value: givenHours)):\(timeToString(value: givenMinutes)) today"
        } else {
            return "\(timeToString(value: givenHours)):\(timeToString(value: givenMinutes)) tomorrow"
        }
    }
    
    func hourlyNextRunDescription(givenMinutes: Int) -> String {
        if currentTimeHours == 23 && givenMinutes < currentTimeMinutes {
            return "00:\(timeToString(value: givenMinutes)) tomorrow"
        } else if givenMinutes >= currentTimeMinutes {
            return "\(timeToString(value: currentTimeHours)):\(timeToString(value: givenMinutes)) today"
        } else {
            //In this case currentTimeHours < 23 && givenMinutes < currentTimeMinutes
            return "\(timeToString(value: currentTimeHours + 1)):\(timeToString(value: givenMinutes)) today"
        }
    }
    
    func everyMinuteInHourNextRun(givenHours: Int) -> String {
        if currentTimeHours > givenHours {
            return "\(timeToString(value: givenHours)):00 tomorrow"
        } else {
            return "\(timeToString(value: givenHours)):00 today"
        }
    }
    
    func everyMinutEveryHour() -> String {
        return "\(timeToString(value: currentTimeHours)):\(timeToString(value: currentTimeMinutes)) today"
    }
}
