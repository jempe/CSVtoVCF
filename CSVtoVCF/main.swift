//
//  main.swift
//  CSVtoVCF
//
//  Created by Kastro on 21/2/23.
//

import Foundation


let arguments = CommandLine.arguments

guard arguments.count == 2 else {
    print("Usage: \(arguments[0]) INPUT_VCF_FILE")
    exit(1)
}

let csvFilePath = arguments[1]

let fileManager = FileManager.default

if !fileManager.fileExists(atPath: csvFilePath) {
    print("File not found: \(csvFilePath)")
    exit(1)
}

let vcfFilePath = csvFilePath.replacingOccurrences(of: ".csv", with: ".vcf")

//check if vcf file exists
if fileManager.fileExists(atPath: vcfFilePath) {
    print("Error: VCF file \(vcfFilePath) already exists")
    exit(1)
}

// Read the CSV file into a string
guard let csvString = try? String(contentsOfFile: csvFilePath) else {
    print("Error reading CSV file")
    exit(1)
}

// Split the CSV string into rows
let csvRows = csvString.components(separatedBy: .newlines)

// Create an empty string to store the VCF data
var vcfString = ""

// Iterate over each CSV row and generate the corresponding VCF data
for row in csvRows {
    let rowValues = row.components(separatedBy: ",")
    if rowValues.count > 1 {
        let name = rowValues[0]

        // create array with name words
        let nameWords = name.components(separatedBy: " ")

        // limit each word to 3 characters
        let nameWordsLimit = nameWords.map { String($0.prefix(3)) }

        // join the words
        let nameShort = nameWordsLimit.joined(separator: "")

        let phone = rowValues[1]

        var otherPhones = ""

        for i in 2...4 {
            if rowValues.count > i {
                let newPhone = rowValues[i]
                if newPhone.rangeOfCharacter(from: .decimalDigits) != nil {
                    otherPhones += "TEL;TYPE=CELL:\(newPhone)\n"
                }
            }
        }

        // if phone contains numbers add to vcf
        if phone.rangeOfCharacter(from: .decimalDigits) != nil {
            vcfString += "BEGIN:VCARD\n"
            vcfString += "VERSION:3.0\n"
            vcfString += "N:\(nameShort);;\n"
            vcfString += "FN:\(nameShort)\n"
            vcfString += "TEL;TYPE=CELL:\(phone)\n"
            vcfString += otherPhones
            vcfString += "END:VCARD\n"
        }
    }
}

// Write the VCF data to the output file
do {
    try vcfString.write(toFile: vcfFilePath, atomically: true, encoding: .utf8)
    print("Conversion complete")
} catch {
    print("Error writing VCF file")
    exit(1)
}

