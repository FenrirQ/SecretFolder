//
//  StringConstant.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/9/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

extension String {
    static var createFoldersTableQuery: String {
        return "create table folders (id integer primary key autoincrement not null, name text not null, size real not null default 0, amount integer not null default 0, ordinal integer not null default 0)"
    }
    
    static var createMediasTableQuery: String {
        return "create table medias (id integer primary key autoincrement not null, folder_id integer not null, name text not null, size real not null, encrypted_path text not null, encrypted_thumb_path text not null, creation_date text not null, duration integer not null default 0)"
    }
    
    static var createNotesTableQuery: String {
        return "create table notes (id integer primary key autoincrement not null, name text not null, size real not null default 0, creation_date text not null default '', encrypted_path text not null default '', title text not null default '')"
    }
    
    static var createContactsTableQuery: String {
        return "create table contacts (id integer primary key autoincrement not null, name text not null, encrypted_path text not null default '')"
    }
    
    static var selectImagesFromFolderQuery: String {
        return "select * from images where images.folder_id = folders.id;"
    }
    
    static var field_id: String {return "id"}
    static var field_name: String {return "name"}
    static var field_size: String {return "size"}
    static var field_amount: String {return "amount"}
    static var field_ordinal: String {return "ordinal"}
    
    static var field_media_of_folder_id: String {return "folder_id"}
    static var field_encryptedPath: String {return "encrypted_path"}
    static var field_creation_date: String {return "creation_date"}
    static var field_decryptedPath: String {return "decryped_path"}
    static var field_encrypted_thumbPath: String {return "encrypted_thumb_path"}
    static var field_duration: String {return "duration"}
    
    static var field_content: String {return "content"}
    static var field_title: String {return "title"}
    
    /* key for UserDefault */
    static var kModeCollectionView: String {return "ModeCollectionView"}        /* key collection view at folder detail controlelr */
    static var kEncryptPassword: String {return "123456"}               /* encrypt pass */
    static var kLockType: String {return "kLockType"}                   /* lock type for lock screen */
    static var kPassCode: String {return "kPassCode"}                   /* pass code for pass lock type and combination lock type */
    static var kDotPass: String {return "kDotPass"}                     /* pass code for dot lock type */
    static var kIsUnlock: String {return "kIsUnlock"}                   /* true if unlocked */
    static var kNotFirstTime: String {return "kNotFirstTime"}           /* false if it's first time run app */
    static var kIsTerminated: String {return "kIsTerminated"}           /* true if app terminated */
    static var kInAppPurchaseProUpgrade: String {return "kInAppPurchaseProUpgrade"}     /* true if app purchased */
    static var kIndexOfTabbarItem: String {return "kIndexOfTabbarItem"}         /* save previous index tabbar item for more apps */
    static var kReadyForShowFullAd: String {return "kReadyForShowFullAd"}
    static var kNeverDeleteMedia: String {return "kNeverDeleteMedia"}
    
    static var chooseFromLibrary: String {return "Choose from your Library"}
    static var takeFromCamera: String {return "Take from Camera"}
    static var ok: String {return "OK"}
    static var cancel: String {return "Cancel"}
    static var edit: String {return "Edit"}
    static var delete: String {return "Delete"}
    static var save: String {return "Save"}
    static var confirmName: String {return "Please fill name and content boxes!"}
    static var errorMess: String {return "Sorry, We have an error"}
    static var saveMediaSuccess: String {return "Saved successfully!"}
    static var deleteSuccess: String {return "Delete successfully!"}
    static var moveSuccess: String {return "Move successfully!"}
    static var urlIncorrect: String {return "Your URL is incorrect!"}
    static var setPassCodeSuccess: String {return "Set passcode successfully!"}
    static var createFolderSuccess: String {return "Create folder successfully!"}
    static var editFolderSuccess: String {return "Edit folder successfully!"}
    static var importContactSuccess: String {return "Import contact successfully!"}
    static var chooseMinItem: String {return "Please choose at least one item!"}
    static var addMediaSuccess: String {return "Add media successfully!"}
    static var phoneNumberEmpty: String {return "Sorry, your phone number is empty"}
    
    static var mediaInfoKey: String {return "media"}
    static var videoPathInfoKey: String {return "videoPath"}
    static var noteInfoKey: String {return "note"}
    static var contentInfoKey: String {return "noteContent"}
    
    static var pickBirthdayMess: String {return "Please pick a birthday"}
}
