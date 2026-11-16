import Foundation

enum TerminationSignals {
    /// Exits cleanly on SIGTERM (sent by `launchctl bootout`), SIGINT and SIGHUP.
    /// Keep the returned sources alive for as long as the handlers should run.
    static func install() -> [DispatchSourceSignal] {
        [SIGTERM, SIGINT, SIGHUP].map { signalNumber in
            signal(signalNumber, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: signalNumber, queue: .main)
            source.setEventHandler {
                Log.info("Received signal \(signalNumber); removing the virtual display")
                exit(EXIT_SUCCESS)
            }
            source.resume()
            return source
        }
    }
}
