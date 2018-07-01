//
//  Ultilities.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/26/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation
import SystemConfiguration
import Device

class Ultilities {
    static func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    static func makeDistanceValue(_ ip4: CGFloat, _ ip5: CGFloat, _ ip6: CGFloat, _ ip6plus: CGFloat, _ ipad: CGFloat) -> CGFloat {
        switch Device.size() {
        case .screen3_5Inch:
            return ip4
        case .screen4Inch:
            return ip5
        case .screen4_7Inch:
            return ip6
        case .screen5_5Inch:
            return ip6plus
        case .screen5_8Inch:
            return ip6
        default:
            return ipad
        }
    }
}
