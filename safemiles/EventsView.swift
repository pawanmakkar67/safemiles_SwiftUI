import SwiftUI

struct EventsView: View {
    @ObservedObject var viewModel: LogsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Graph
                LogbookGraphView(segments: viewModel.dutySegments)
                    .frame(height: 140)
                    .padding()
                    .background(AppColors.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                
                // Events List
                LazyVStack(spacing: 0) {
                    if let events = viewModel.currentLog?.events {
                        ForEach(events.indices, id: \.self) { index in
                            EventRow(event: events[index], logDate: viewModel.selectedDate)
                            Divider()
                        }
                    } else {
                        Text("No events for this day")
                            .foregroundColor(AppColors.textGray)
                            .padding()
                    }
                }
                .background(AppColors.white)
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppColors.background)
    }
}

struct LogbookGraphView: View {
    let segments: [DutySegment]
    
    // Constants matching the user's UIKit design
    private let statuses: [DutyStatus] = [.off, .sleeper, .driving, .on]
    private let leftMargin: CGFloat = 20
    private let rightMargin: CGFloat = 25
    private let topMargin: CGFloat = 25
    private let bottomMargin: CGFloat = 10
    
    var body: some View {
        Canvas { context, size in
            let effectiveWidth = size.width - leftMargin - rightMargin
            let effectiveHeight = size.height - topMargin - bottomMargin
            
            let rowHeight = effectiveHeight / CGFloat(statuses.count)
            let hourWidth = effectiveWidth / 24.0
            let bottomY = topMargin + CGFloat(statuses.count) * rowHeight
            
            // 🎨 Colors (Matching UIKit)
            let gridColor = AppColors.grayOpacity30
            let tickColor = AppColors.textGray
            let segmentColor = AppColors.buttonActive
            let textColor = AppColors.textBlack
            
            // Fonts (approximate UIFont replacement)
            let labelFont = Font.system(size: 10, weight: .bold) // Keep specific size for graph
            let rightLabelFont = Font.system(size: 10)
            let timeFont = Font.system(size: 10, weight: .bold)
            
            // === Rows + Left Labels ===
            for (i, status) in statuses.enumerated() {
                let y = topMargin + CGFloat(i) * rowHeight
                
                // Row Separator
                var path = Path()
                path.move(to: CGPoint(x: leftMargin, y: y))
                path.addLine(to: CGPoint(x: size.width - rightMargin, y: y))
                context.stroke(path, with: .color(gridColor), lineWidth: 1)
                
                // Status Label
                let labelText = Text(status.rawValue.uppercased())
                    .font(labelFont)
                    .foregroundColor(textColor)
                
                // Draw text roughly centered in the row, to the left
                // Calculating rough Y center: y + rowHeight/2
                let textPoint = CGPoint(x: leftMargin - 15, y: y + rowHeight / 2) // Approximate centering
                context.draw(labelText, at: textPoint)
            }
            
            // Bottom Line
            var bottomPath = Path()
            bottomPath.move(to: CGPoint(x: leftMargin, y: bottomY))
            bottomPath.addLine(to: CGPoint(x: size.width - rightMargin, y: bottomY))
            context.stroke(bottomPath, with: .color(gridColor), lineWidth: 1)
            
            // === Right-Side Labels (Placeholders as per user code) ===
            let rightLabels = ["19:00", "00:00", "00:00", "05:00"] // Demo data
            for (i, labelStr) in rightLabels.enumerated() {
                 let y = topMargin + CGFloat(i) * rowHeight + rowHeight / 2
                 let labelText = Text(labelStr)
                    .font(rightLabelFont)
                    .foregroundColor(textColor)
                 context.draw(labelText, at: CGPoint(x: size.width - rightMargin + 20, y: y))
            }
            
            // === Vertical Hour Lines + Quarter Ticks + Top Labels ===
            for h in 0...24 {
                let x = leftMargin + CGFloat(h) * hourWidth
                
                // Hour Grid Line
                var hourPath = Path()
                hourPath.move(to: CGPoint(x: x, y: topMargin))
                hourPath.addLine(to: CGPoint(x: x, y: bottomY))
                context.stroke(hourPath, with: .color(gridColor), lineWidth: 1)
                
                // Quarter Ticks
                if h < 24 {
                    for q in 1...3 {
                        let qx = x + CGFloat(q) * (hourWidth / 4)
                        let tickLength: CGFloat = q == 2 ? 10 : 6
                        
                        for i in 0..<statuses.count {
                            let rowBottom = topMargin + CGFloat(i + 1) * rowHeight
                            var tickPath = Path()
                            tickPath.move(to: CGPoint(x: qx, y: rowBottom))
                            tickPath.addLine(to: CGPoint(x: qx, y: rowBottom - tickLength))
                            context.stroke(tickPath, with: .color(tickColor), lineWidth: 0.8)
                        }
                    }
                }
                
                // Hour Label (Top)
                let labelStr: String
                switch h {
                case 0: labelStr = "M"
                case 12: labelStr = "N"
                case 24: labelStr = "M"
                case 1...11: labelStr = "\(h)"
                case 13...23: labelStr = "\(h - 12)"
                default: labelStr = ""
                }
                
                if !labelStr.isEmpty {
                    let labelText = Text(labelStr)
                        .font(timeFont)
                        .foregroundColor(textColor)
                    context.draw(labelText, at: CGPoint(x: x, y: topMargin - 10))
                }
            }
            
            // === Duty Segments (Lines) ===
            var previousEndPoint: CGPoint?
            
            for seg in segments {
                guard let rowIndex = statuses.firstIndex(of: seg.status) else { continue }
                
                let y = topMargin + CGFloat(rowIndex) * rowHeight + rowHeight / 2
                let startX = leftMargin + CGFloat(seg.startHour) * hourWidth
                let endX = leftMargin + CGFloat(seg.endHour) * hourWidth
                
                let startPoint = CGPoint(x: startX, y: y)
                let endPoint = CGPoint(x: endX, y: y)
                
                // Horizontal Segment
                var segPath = Path()
                segPath.move(to: startPoint)
                segPath.addLine(to: endPoint)
                
                var strokeStyle = StrokeStyle(lineWidth: 3, lineCap: .butt)
                if seg.isDotted {
                    strokeStyle.dash = [3, 3]
                }
                
                context.stroke(segPath, with: .color(segmentColor), style: strokeStyle)
                
                // Vertical Connector (Solid)
                if let previousEnd = previousEndPoint {
                    var connPath = Path()
                    connPath.move(to: previousEnd)
                    connPath.addLine(to: startPoint)
                    // Always solid for connectors
                    context.stroke(connPath, with: .color(segmentColor), lineWidth: 3)
                }
                
                previousEndPoint = endPoint
            }
        }
    }
}

struct EventRow: View {
    let event: Events
    let logDate: Date
    
    var body: some View {
        HStack {
            // Status Indicator
            Rectangle()
                .fill(getStatusColor(event.code))
                .frame(width: 4)
                .padding(.vertical, 8)
            
            // Code & Time
            VStack(alignment: .leading, spacing: 4) {
                Text(getDisplayCode(event.code))
                    .font(AppFonts.bodyText)
                    .foregroundColor(getStatusColor(event.code))
                
                Text(formatTime(event.eventdatetime))
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
            }
            
            Spacer()
            
            // Location
            if let loc = event.location_notes {
                Text(loc)
                    .font(AppFonts.captionText)
                    .foregroundColor(AppColors.textGray)
                    .lineLimit(1)
            }
            
            // Duration
//            if let dur = event.time_diff {
                 // Format duration logic if needed
//            }
            
            // Edit Icon
            Image(systemName: "pencil")
                .foregroundColor(AppColors.textGray)
        }
        .padding()
    }
    
    func getStatusColor(_ code: String?) -> Color {
        switch code {
        case "d", "driving": return AppColors.statusGreen
        case "on", "login": return AppColors.buttonActive
        case "sb": return AppColors.orange
        default: return AppColors.textGray
        }
    }
    
    func getDisplayCode(_ code: String?) -> String {
        switch code {
        case "d": return "Drive"
        case "sb": return "Sleeper"
        case "on": return "ON"
        case "off": return "OFF"
        default: return code?.uppercased() ?? "-"
        }
    }
    
    func formatTime(_ dateStr: String?) -> String {
        guard let dateStr = dateStr else { return "" }
         let formatter = ISO8601DateFormatter()
         formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
         
         if let date = formatter.date(from: dateStr) ?? ISO8601DateFormatter().date(from: dateStr) {
             let displayFormatter = DateFormatter()
             displayFormatter.dateFormat = "hh:mm a zzz"
             return displayFormatter.string(from: date)
         }
         return dateStr
    }
}
