//
//  SWRaffle.swift
//  SWRaffle
//
//  Created by Jason on 2020/4/16.
//  Copyright © 2020 UTAS. All rights reserved.
//

import Foundation

public struct SWRaffle {
    var ID:Int32 = -1
    var name:String
    var price:Double
    var stock:Int32
    var maximumNumber:Int32
    var purchaseLimit:Int32
    var description:String
    var wallpaperData:Data
    var isMarginRaffle:Int32
}
