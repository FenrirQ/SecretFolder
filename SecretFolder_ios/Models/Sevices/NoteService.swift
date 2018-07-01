//
//  NoteService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/24/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

class NoteService {
    static let shared: NoteService = NoteService()
    private init() {}
    private var _notes: [Note]?
    var notes: [Note] {
        get {
            if _notes == nil {
                _notes = loadNotes()
            }
            return _notes!
        }
    }
    
    private func loadNotes() -> [Note] {        /* load all notes */
        var notes: [Note] = []
        if DBManager.shared.openDatabase() {
            let query = "select * from notes"
            do {
                let result = try DBManager.shared.db.executeQuery(query, values: nil)
                while result.next() {
                    let note = Note(id: Int(result.int(forColumn: String.field_id)),
                                    name: result.string(forColumn: String.field_name)!,
                                    title: result.string(forColumn: String.field_title)!,
                                    size: result.double(forColumn: String.field_size),
                                    creationDate: result.string(forColumn: String.field_creation_date)!,
                                    encryptedPath: result.string(forColumn: String.field_encryptedPath)!)
                    notes.append(note)
                }
                result.close()
            } catch {
                print(error.localizedDescription)
            }
//            DBManager.shared.closeDatabse()
        }
        return notes.reversed()
    }
    
    func addNote(title: String, content: String, date: String, completion: @escaping (Bool)->()) {
        var isSuccess = true
        guard let data = content.data(using: .utf8) else {return}
        let now = Date()
        DispatchQueue.global().sync {
            if DBManager.shared.openDatabase() {
                let encryptPath = CryptionService.shared.zipFile(data: data, fileName: "\(now)", encryptType: .note)
                if encryptPath.isEmpty {
                    isSuccess = false
                } else {
                    let query = "insert into notes (\(String.field_name), \(String.field_title), \(String.field_size), \(String.field_creation_date)) values ('\(now)', '\(title)', \(data.count), '\(date)');"
                    if !DBManager.shared.db.executeStatements(query) {
                        isSuccess = false
                        print("failed add notes \(DBManager.shared.db.lastErrorMessage())")
                    }
                }
//                DBManager.shared.closeDatabse()
                DispatchQueue.main.async {
                    completion(isSuccess)
                }
                self._notes = self.loadNotes()
            }
        }
    }
    
    func loadContent(name: String, completion: @escaping (String)->()) {    /* load content of each note */
        var content = ""
        DispatchQueue.global().sync {
            if let data = CryptionService.shared.unzipFile(name: name, encryptedType: .note) {
                content = String(data: data, encoding: .utf8) ?? ""
            }
            DispatchQueue.main.async {
                completion(content)
            }
        }
    }
    
    /* delete old file and create new file when change a note */
    func updateNote(id: Int, name: String, newTitle: String, content: String) {
        DispatchQueue.global().sync {
            guard let data = content.data(using: .utf8) else {return}
            let _ = CryptionService.shared.zipFile(data: data, fileName: name, encryptType: .note)
            let query = "update notes set \(String.field_title) = '\(newTitle)', \(String.field_size) = \(data.count) where \(String.field_id) = \(id);"
            if DBManager.shared.openDatabase() {
                if !DBManager.shared.db.executeStatements(query){
                    print("fail edit note")
                    print(DBManager.shared.db.lastErrorMessage())
                }
            }
            self._notes = self.loadNotes()
//            DBManager.shared.closeDatabse()
        }
    }
    
    func deleteNote(note: Note, completion: (Bool)->()) {       /* delete a note */
        let path = Constant.noteDir.appending("/\(note.name).txt")
        let query = "delete from notes where \(String.field_id) = \(note.id);"
        if DBManager.shared.openDatabase() {
            if !DBManager.shared.db.executeStatements(query) {
                DBManager.shared.printError(message: "Can't delete note")
                completion(false)
                return
                //                DBManager.shared.closeDatabse()
            }
            _notes = loadNotes()
            completion(true)
        }
        DispatchQueue.global().async {
            AppService.shared.deleteFile(at: path)
        }
    }
}

struct Note {
    var id: Int
    var name: String
    var title: String
    var size: Double
    var creationDate: String
    var encryptedPath: String
}
