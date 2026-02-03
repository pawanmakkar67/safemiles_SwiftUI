import UIKit

enum TimerMode {
    case countdown   // ticks down to 0
    case counter     // ticks up from 0
}

class FlexibleTimer {
    private var timer: Timer?
    private var endDate: Date?
    private var startDate: Date?
    private var pausedValue: Int?

    var totalSeconds: Int
    private(set) var mode: TimerMode

    private var tickHandler: ((Int) -> Void)?
    private var completion: (() -> Void)?

    init(totalSeconds: Int, mode: TimerMode = .countdown) {
        self.totalSeconds = totalSeconds
        self.mode = mode
    }

    // MARK: - Start (once)
    func start(tick: @escaping (Int) -> Void, completion: (() -> Void)? = nil) {
        self.tickHandler = tick
        self.completion = completion
        startTimer()
    }

    // MARK: - Pause / Resume
    func pause() {
        timer?.invalidate()
        timer = nil

        switch mode {
        case .countdown:
            if let end = endDate {
                pausedValue = max(0, Int(end.timeIntervalSinceNow))
            }
        case .counter:
            if let start = startDate {
                pausedValue = Int(Date().timeIntervalSince(start))
            }
        }

        endDate = nil
        startDate = nil
    }

    func resume() {
        guard let paused = pausedValue else { return }

        if mode == .countdown {
            endDate = Date().addingTimeInterval(TimeInterval(paused))
        } else {
            startDate = Date().addingTimeInterval(-TimeInterval(paused))
        }

        pausedValue = nil
        startTimer()
    }

    // MARK: - Change Mode dynamically
    func changeMode(to newMode: TimerMode, totalSeconds: Int = 0) {
        resetInternal()
        self.mode = newMode
        if totalSeconds > 0 { self.totalSeconds = totalSeconds }
        startTimer() // restart automatically
    }

    // MARK: - Update / Add Time
    func update(seconds: Int) {
    
        if totalSeconds <= 0 {
            self.totalSeconds = seconds
            startTimer() // restart automatically
        }
        else if seconds < 0 {
            self.totalSeconds = 0
        }
        else {
            self.totalSeconds = seconds
        }

        if mode == .countdown {
            endDate = Date().addingTimeInterval(TimeInterval(seconds))
        } else {
            startDate = Date().addingTimeInterval(-TimeInterval(seconds))
        }
    }

    func addTime(seconds: Int) {
        if mode == .countdown, let end = endDate {
            endDate = end.addingTimeInterval(TimeInterval(seconds))
        } else if mode == .counter, let start = startDate {
            startDate = start.addingTimeInterval(-TimeInterval(seconds))
        }
    }

    // MARK: - Reset
    func reset() {
        resetInternal()
        pausedValue = nil
    }

    private func resetInternal() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        startDate = nil
    }

    // MARK: - Timer Internal
    private func startTimer() {
        timer?.invalidate()
        if mode == .countdown {
            endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        } else {
            startDate = Date().addingTimeInterval(-TimeInterval(totalSeconds))
        }

        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(timerFired),
                                     userInfo: nil,
                                     repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        timerFired()
    }

    @objc private func timerFired() {
        switch mode {
        case .countdown:
            guard let end = endDate else { return }
            let remaining = max(0, Int(end.timeIntervalSinceNow))
            tickHandler?(remaining)
            if remaining <= 0 {
                resetInternal()
                completion?()
            }
        case .counter:
            guard let start = startDate else { return }
            let elapsed = Int(Date().timeIntervalSince(start))
            tickHandler?(elapsed)
        }
    }
}
