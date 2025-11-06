// MARK: - Debug Helper / Debug-Helfer
// Stellt Laufzeitmessung für Netzwerk-Logs bereit / Provides runtime measurement for network logs.

import Foundation

#if DEBUG
/// Misst Zeitdifferenzen in Millisekunden / Measures time deltas in milliseconds.
func durationMillis(since start: DispatchTime) -> Int {
    let end = DispatchTime.now()
    let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
    return Int(nanos / 1_000_000)
}
#endif
