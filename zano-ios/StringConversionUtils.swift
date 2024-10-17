//
//  StringConversionUtils.swift
//  zano-ios
//
//  Created by Jumpei Katayama on 2024/10/11.
//

import Foundation
internal import CxxStdlib

class StringConversionUtils {
    
    // Existing methods
    static func convertUnsafeRawPointerToStdString(rawPointer: UnsafeRawPointer) -> CxxStdlib.std.string {
        let cStringPointer = rawPointer.assumingMemoryBound(to: CChar.self)
        let swiftString = String(cString: cStringPointer)
        return CxxStdlib.std.string(swiftString)
    }

    static func swiftStringToStdString(with string: String) -> UnsafeMutableRawPointer {
        let cString = string.cString(using: .utf8)!
        let rawPointer = UnsafeMutableRawPointer.allocate(byteCount: cString.count, alignment: MemoryLayout<CChar>.alignment)
        _ = rawPointer.copyMemory(from: cString, byteCount: cString.count)
        return rawPointer
    }

    static func deallocate(rawPointer: UnsafeMutableRawPointer) {
        rawPointer.deallocate() // Memory cleanup
    }
    
    // New method that combines both steps
    static func swiftStringToCppString(_ string: String) -> CxxStdlib.std.string {
        let rawPointer = swiftStringToStdString(with: string)
        let cppString = convertUnsafeRawPointerToStdString(rawPointer: rawPointer)
        deallocate(rawPointer: rawPointer) // Clean up memory
        return cppString
    }
}


