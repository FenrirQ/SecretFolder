//
//  ShareAppController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/27/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

extension SettingsTableViewController {
    func shareApp() {
        let mailSubject = "Xem ứng dụng Lưu ảnh và dữ liệu bí mật này nhé!"
        let message = "Hello,\nỨng dụng Secret Files - Lưu ảnh và dữ liệu bí mật, có nhiều tính năng hữu ích, giúp tạo và bảo mật dữ liệu ảnh/videos, ghi chú, danh bạ và lịch sử trình duyệt web. An toàn và không lo bị rò rỉ thông tin. Download tại đây nhé!\n\(Constant.appLink)"
        share(items: [message], subject: mailSubject)
    }
}
