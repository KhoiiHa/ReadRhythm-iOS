
//
//  NetworkStatusMonitor.swift
//  ReadRhythm
//
//  Created by Vu Minh Khoi Ha on 22.10.25.
//

import Foundation
import Network

/// Liefert den aktuellen Netzwerkstatus für ViewModels/Repositories.
/// MVP-freundlich: einfache `isOnline`-Abfrage statt komplexer Publisher-Graphen.
public protocol NetworkStatusProviding: AnyObject {
    /// `true` wenn eine Verbindung besteht (NWPath.status == .satisfied).
    var isOnline: Bool { get }
}

/// Default-Implementierung basierend auf `NWPathMonitor`.
/// Lebenszyklus: Singleton-ähnlich verwendbar (shared) oder injizierbar in VMs.
public final class NetworkStatusMonitor: NetworkStatusProviding {

    public static let shared = NetworkStatusMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkStatusMonitor.queue")
    private var _isOnline: Bool = true

    public var isOnline: Bool {
        // keine Synchronisation nötig: NWPathMonitor liefert Updates seriell auf `queue`,
        // und wir lesen nur bool; Reentrancy hier minimal.
        _isOnline
    }

    /// Optional: zusätzliche Infos (z. B. für Debug-Ausgaben oder Policies)
    public private(set) var isExpensive: Bool = false
    public private(set) var availableInterfaces: [NWInterface.InterfaceType] = []

    // MARK: - Init / Deinit

    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self._isOnline = (path.status == .satisfied)
            self.isExpensive = path.isExpensive
            self.availableInterfaces = path.availableInterfaces.map { $0.type }

            #if DEBUG
            let ifaces = self.availableInterfaces.map { "\($0)" }.joined(separator: ",")
            let status = self._isOnline ? "online" : "offline"
            print("🌐 [NetworkStatus] \(status) · expensive=\(self.isExpensive) · ifaces=[\(ifaces)]")
            #endif
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
