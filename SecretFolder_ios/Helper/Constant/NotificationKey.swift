//
//  NotificationKey.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/26/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

struct NotificationKey {
    /* call back when a locktype change */
    static let checkLockType = NSNotification.Name(rawValue: "checkLockType")
    
    /* set title for navigation bar when swipe page view image detail */
    static let setNaviTitleImage = NSNotification.Name(rawValue: "setNaviTitleImage")
    
    /* send video path to container view */
    static let sendVideoPath = NSNotification.Name(rawValue: "sendVideoPath")
    
    /* set title for navigation bar when swipe page view note detail */
    static let setNaviTitleNote = NSNotification.Name("setNaviTitleNote")
    
    /* send note to update */
    static let updateNote = NSNotification.Name(rawValue: "updateNote")
    
    /* send content of note to container page view */
    static let sendNoteContent = NSNotification.Name(rawValue: "sendNoteContent")
    
    /* tap gesture to hide bar when current media is image */
    static let tapGestureImage = NSNotification.Name(rawValue: "tapGestureImage")
    
    /* when didBecomeActive dismiss Background View */
    static let showAdUnlock = NSNotification.Name(rawValue: "showAdUnlock")
    
    /* when press Done button on edit mode of note container controller */
    static let doneEditNote = NSNotification.Name(rawValue: "doneEditNote")
    
    /* when return keyboard at note title text field */
    static let returnKeyTextFieldNote = NSNotification.Name(rawValue: "returnKeyTextFieldNote")
    
    /* show ad when date picker view disapear */
    static let dateSelectionDidDismiss = NSNotification.Name(rawValue: "DateSelectionDidDismiss")
}
