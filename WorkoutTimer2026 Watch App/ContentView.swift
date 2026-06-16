//
//  ContentView.swift
//  WorkoutTimer2026 Watch App
//
//  Created by Douglas Jasper on 2026-06-15.
//

import SwiftUI
import UserNotifications
import WatchKit

struct ContentView: View {
    
    @StateObject private var timerManager = TimerManager()
    private let lastPresetKey = "lastSelectedPresetIndex"
    private let lastCustomTimeKey = "lastCustomTimeSeconds"
    
    // Presets
    let presets: [TimeInterval] = [60, 5*60, 10*60, 20*60, 30*60]
    let presetLabels: [String] = ["1m", "5m", "10m", "20m", "30m"]
    
    // track selected preset index
    @State private var selectedPresetIndex: Int = {
        let saved = UserDefaults.standard.object(forKey: "lastSelectedPresetIndex") as? Int
        return saved ?? 1
    }()
    
    // Custom timer
    @State private var ShowingCustomTimeSheet = false
    @State private var customMinutes: Int = 1
    @State private var customSeconds: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            // MARK: - Segmented Pills + Custom
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Preset pills
                    ForEach(0..<presetLabels.count, id: \.self) {
                        idx in
                        Button(action: {
                            withAnimation {
                                selectedPresetIndex = idx
                                timerManager.setDuration(presets[idx])
                                UserDefaults.standard.set(idx, forKey: "lastPresetKey")
                            }
                        }) {
                            Text(presetLabels[idx])
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .frame(minWidth: 44)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(segmentBackground(for: idx))
                                .clipShape(Capsule())
                                
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Custom pill
                    Button(action: {
                        // Load last custom time if exists
                        let lastCustom = UserDefaults.standard.integer(forKey: "lastCustomTimeKey")
                        customMinutes = lastCustom / 60
                        customSeconds = lastCustom % 60
                        selectedPresetIndex = presets.count //mark custom selected
                        ShowingCustomTimeSheet = true
                    }) {
                        Text("Custom")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .frame(minWidth: 44)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(selectedPresetIndex >= presets.count ? Color.accentColor : Color.clear)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().strokeBorder(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 6)
            }
            
            // MARK: - Timer display
            Text(timerManager.formattedRemaining())
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                
            // MARK: - Progress ring
            ProgressView(value: timerManager.progress)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.15)
                .frame(width: 70, height: 70)
            
            // MARK: - Controls
            HStack(spacing: 10) {
                Button(action: {
                    timerManager.toggle()
                }) {
                    Label(timerManager.isRunning ? "Pause" : "Start",
                          systemImage: timerManager.isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    timerManager.reset()
                }) {
                    Label("Reset",
                          systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        
        
    }
}

#Preview {
    ContentView()
}
