//
//  DBManager.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/9/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class DBManager: NSObject {
    static let shared: DBManager = DBManager()
    let dbFileName = "database.sqlite"
    var pathToDB: String!
    var db: FMDatabase!
    
    private override init() {
        super.init()
        pathToDB = Constant.docDirectory.appending("/\(dbFileName)")
        print(pathToDB)
    }
    
    func createDatabase() {
        var isCreated = false
        if !FileManager.default.fileExists(atPath: pathToDB) {
            db = FMDatabase(path: pathToDB)
            if db != nil {
                if db.open() {
                    AppService.shared.createDirectories()
                    isCreated = createFolderTable() && createMediasTable() && createNotesTable() && createContactsTable()
                    if !isCreated {
                        print("Could not create database")
                    }
                }
            } else {
                print("Could not open database")
            }
        }
    }
    
    func openDatabase() -> Bool {
        if db == nil {
            if FileManager.default.fileExists(atPath: pathToDB) {
                db = FMDatabase(path: pathToDB)
            }
        }
        if db != nil {
            if db.open() {
                return true
            }
        }
        return false
    }
    
    func closeDatabse() {
        if openDatabase() {
            db.close()
        }
    }
    
    private func createFolderTable() -> Bool {
        do {
            try db.executeUpdate(String.createFoldersTableQuery, values: nil)
            insertFirstFolder()
            return true
        } catch {
            print("Coulde not create folders table")
            print(error.localizedDescription)
        }
        return false
    }
    
    private func createMediasTable() -> Bool {
        do {
            try db.executeUpdate(String.createMediasTableQuery, values: nil)
            return true
        } catch {
            print("Could not create medias table")
            print(error.localizedDescription)
        }
        return false
    }
    
    private func createNotesTable() -> Bool {
        do {
            try db.executeUpdate(String.createNotesTableQuery, values: nil)
            insertFirstNote()
            return true
        } catch {
            print("Could not create notes table")
            print(error.localizedDescription)
        }
        return false
    }
    
    private func createContactsTable() -> Bool {
        do {
            try db.executeUpdate(String.createContactsTableQuery, values: nil)
            return true
        } catch {
            print("Could not create contacts table")
            print(error.localizedDescription)
        }
        return false
    }
    
    private func insertFirstFolder() {
        let firstFolderName = "Saved Items"
        let query = "insert into folders (\(String.field_name)) values ('\(firstFolderName)');"
        if !db.executeStatements(query) {
            print("Failed to insert initial data into database")
            print(db.lastError(), db.lastErrorMessage())
        }
    }
    
    private func insertFirstNote() {
        let firstNoteName = "Draft"
        let content = "Hello!"
        NoteService.shared.addNote(title: firstNoteName, content: content, date: "") { (_) in}
    }
    
    func printError(message: String) {
        print(message)
        print(db.lastErrorMessage())
        print(db.lastError())
    }
}
