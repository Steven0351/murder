import ArgumentParser
import Combine
import Cocoa

final class Murder: ParsableCommand {
  enum Error: Swift.Error, CustomStringConvertible {
    case configFile
    
    var description: String {
      switch self {
      case .configFile:
        return "Unable to parse data from configuration file"
      }
    }
  }
  
  @Option(help: """
  The path to a json file with the following structure:
  {
    "applicationsToKill": [
       "/Applications/KillThis.app",
       "/Applications/KillThat.app"
    ]
  }
  """)
  var configFile = ""
  
  @Option(help: #"""
  Paths to an application to terminate when the screen locks.
  Example: --applications-to-kill /Applications/Visual\ Studio\ Code.app
  """#)
  var applicationsToKill = [String]()
  
  func validate() throws {
    switch (configFile.isEmpty, applicationsToKill.isEmpty) {
    case (true, true):
      throw ValidationError("Must provide --config-file or --applications-to-kill")
    case (false, false):
      throw ValidationError("Must provide only one of --config-file or --applications-to-kill, not both")
    default:
      return
    }
  }
  
  func setApplicationsToKill() throws {
    struct KillEmAll: Decodable {
      let applicationsToKill: [String]
    }
    
    if !configFile.isEmpty {
      guard let fileToData = try String.init(contentsOfFile: configFile).data(using: .utf8)
      else { throw Error.configFile }
      
      let intermediate = try JSONDecoder().decode(KillEmAll.self, from: fileToData)
      print("Setting applications to \(intermediate.applicationsToKill)")
      applicationsToKill = intermediate.applicationsToKill
    }
  }
  
  func run() throws {
    try setApplicationsToKill()
    var bag = Set<AnyCancellable>()
    var activeApplications = [NSRunningApplication]()
    
    NSWorkspace.shared
      .publisher(for: \.runningApplications)
      .map { applications in
        applications
          .filter { [self] in
            guard let path = $0.bundleURL?.path else { return false }
            return applicationsToKill.contains(path)
          }
      }
      .sink { activeApplications = $0 }
      .store(in: &bag)
    
    DistributedNotificationCenter.default()
      .publisher(for: Notification.Name(rawValue: "com.apple.screenIsLocked"))
      .sink { _ in
        print("Locked")
        activeApplications.forEach { $0.terminate() }
      }
      .store(in: &bag)
    
    RunLoop.main.run()
  }
}

Murder.main()
