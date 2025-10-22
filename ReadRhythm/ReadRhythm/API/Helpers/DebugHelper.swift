//
//  DebugHelper.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation

#if DEBUG
/// Misst die Zeitdifferenz in Millisekunden (z. B. für Logs).
func durationMillis(since start: DispatchTime) -> Int {
    let end = DispatchTime.now()
    let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
    return Int(nanos / 1_000_000)
}
#endif
