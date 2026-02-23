import SwiftUI

struct ViolationsView: View {
    let violations: [Violation]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Violations")
                    .font(AppFonts.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textBlack).padding(.top,20)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(AppColors.textGray)
                        .font(AppFonts.buttonText)
                }.padding(.top,20)
            }
            .padding()
            .background(AppColors.white)
            
            Divider()
            
            // Violations List
            if violations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(AppFonts.iconLarge)
                        .foregroundColor(AppColors.statusGreen)
                    
                    Text("No violations recorded")
                        .font(AppFonts.bodyText)
                        .foregroundColor(AppColors.textGray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.background)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(violations.indices, id: \.self) { index in
                            ViolationRow(violation: violations[index])
                            
                            if index < violations.count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .background(AppColors.white)
                    .padding(.top, 8)
                }
                .background(AppColors.background)
            }
        }
    }
}

struct ViolationRow: View {
    let violation: Violation
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Warning Icon
            ZStack {
                Circle()
                    .fill(AppColors.statusRed.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "exclamationmark.circle.fill")
                    .font(AppFonts.title2)
                    .foregroundColor(AppColors.statusRed)
            }
            
            // Violation Details
            VStack(alignment: .leading, spacing: 6) {
                Text(violation.violation_type ?? "Unknown Violation")
                    .font(AppFonts.cardTitle)
                    .foregroundColor(AppColors.textBlack)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let notes = violation.violation_notes, !notes.isEmpty {
                    Text(notes)
                        .font(AppFonts.captionText)
                        .foregroundColor(AppColors.textGray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let occurredAt = violation.occurred_at {
                    Text(formatTimestamp(occurredAt))
                        .font(AppFonts.captionText)
                        .foregroundColor(AppColors.textGray.opacity(0.7))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    func formatTimestamp(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = getAppTimeZone()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var date = formatter.date(from: isoString)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: isoString)
        }
        
        guard let validDate = date else { return isoString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.timeZone = getAppTimeZone()
        displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let timeStr = displayFormatter.string(from: validDate)
        let abbr = getAbbreviation(displayFormatter.timeZone)
        return "\(timeStr) \(abbr)"
    }
}
