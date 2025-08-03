import Foundation
import ActivityKit

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var upload: String
        var dwload: String 
        var pauseTime: Date?
        var endTime: Date?
    }

    // Fixed non-changing properties about your activity go here!
    var id: String
}
