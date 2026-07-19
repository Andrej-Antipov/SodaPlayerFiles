//
//  Helper.swift
//  SodaPlayerOpener
//
//  Created by Андрей Антипов on 20.07.2026.
//

import Foundation 

func dprint(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName)] \(function) (line \(line)): \(message)")
    #endif
}

