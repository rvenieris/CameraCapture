//
//  HistogramChannel.swift
//  CameraCapture
//
//  Created by Victor Martins on 25/1/25.
//


enum HistogramChannel: Int, CaseIterable {
    
    case red
    case green
    case blue
    case all
    
    var haveRed: Bool       { self == .red   || self == .all }
    var haveGreen: Bool     { self == .green || self == .all }
    var haveBlue: Bool      { self == .blue  || self == .all }
    
    var redIndex: Double    { haveRed   ? 0.299 : 0 }
    var greenIndex: Double  { haveGreen ? 0.587 : 0 }
    var blueIndex: Double   { haveBlue  ? 0.114 : 0 }
    
    var next: HistogramChannel  {
        HistogramChannel(rawValue: rawValue + 1) ?? .red /*(first)*/
    }
}
