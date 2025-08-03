import ActivityKit
import WidgetKit
import SwiftUI

var startTime = Date.now
var endTime = Date.now.addingTimeInterval(200)
var showCountdownItems = true

struct WidgetViewLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 12))
                        Text(context.state.upload)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                        Text(context.state.dwload)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("上传")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(context.state.upload)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("下载")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(context.state.dwload)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "wifi")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                            Text("网络监控")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("实时更新")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 10))
                    Text(context.state.upload)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.green)
                }
            } compactTrailing: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 10))
                    Text(context.state.dwload)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                }
            } minimal: {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 8))
                    Text(context.state.upload)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.cyan)
        }
    }
}
//
//extension LiveActivityAttributes {
//    fileprivate static var preview: LiveActivityAttributes {
//        LiveActivityAttributes(id: "Ficow Shen")
//    }
//}
//
//extension LiveActivityAttributes.ContentState {
//    fileprivate static var smiley: LiveActivityAttributes.ContentState {
//        LiveActivityAttributes.ContentState(text: "😀")
//     }
//     
//     fileprivate static var starEyes: LiveActivityAttributes.ContentState {
//         LiveActivityAttributes.ContentState(text: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: LiveActivityAttributes.preview) {
//   WidgetViewLiveActivity()
//} contentStates: {
//    LiveActivityAttributes.ContentState.smiley
//    LiveActivityAttributes.ContentState.starEyes
//}
