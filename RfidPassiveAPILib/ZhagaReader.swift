//
//  ZhagaReader.swift
//  RfidPassiveAPILib
//
//  Created by moouser on 17/08/21.
//  Copyright © 2021 Tertium. All rights reserved.
//

import Foundation

public class ZhagaReader
{
    ///
    /// BLE security level 1 (no security).
    ///
    let BLE_NO_SECURITY: Int = 0x00
    
    ///
    /// Legacy BLE security level 2.
    ///
    let BLE_LEGACY_LEVEL_2_SECURITY: Int = 0x01
    
    ///
    ///LESC BLE security level 2.
    ///
    let BLE_LESC_LEVEL_2_SECURITY: Int = 0x02
    
    ///
    ///Not reset BLE configuration.
    ///
    let BLE_CONFIGURATION_UNCHANGED: Int = 0x00
    
    ///
    ///Reset to default BLE configuration.
    ///
    let BLE_DEFAULT_CONFIGURATION: Int = 0x01
    
    ///
    ///Reset to default BLE configuration excluding device name.
    ///
    let BLE_DEFAULT_CONFIGURATION_EXCLUDING_NAME: Int = 0x02
    
    ///
    ///LED color RED
    ///
    public let LED_RED: Int = 0x01
    
    ///
    ///LED color GREEN
    ///
    public let LED_GREEN: Int = 0x02
    
    ///
    ///LED color BLUE
    ///
    public let LED_BLUE: Int = 0x04
    
    ///
    ///LED color CYAN
    ///
    public let LED_CYAN: Int = 0x08
    
    ///
    ///LED color MAGENTA
    ///
    public let LED_MAGENTA: Int = 0x10
    
    ///
    ///LED color YELLOW
    ///
    public let LED_YELLOW: Int = 0x20
    
    ///
    ///LED color WHITE
    ///
    public let LED_WHITE: Int = 0x40
    
    ///
    ///Reader device activated button #1
    ///
    public let ACTIVE_BUTTON_1: Int = 0x01
    
    ///
    ///Reader device activated button #2
    ///
    public let ACTIVE_BUTTON_2: Int = 0x02
    
    ///
    ///Reader device activated button #3
    ///
    public let ACTIVE_BUTTON_3: Int = 0x04
    
    ///
    ///Reader device activated button #4
    ///
    public let ACTIVE_BUTTON_4: Int = 0x08
    
    ///
    ///Reader device activated button #5
    ///
    public let ACTIVE_BUTTON_5: Int = 0x10
    
    ///
    ///Reader device activated button #6
    ///
    public let ACTIVE_BUTTON_6: Int = 0x20
    
    ///
    ///Reader device activated button #7
    ///
    public let ACTIVE_BUTTON_7: Int = 0x40
    
    ///
    ///Reader device activated button #8
    ///
    public let ACTIVE_BUTTON_8: Int = 0x80
}
