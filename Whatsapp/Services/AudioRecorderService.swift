//
//  AudioRecorderService.swift
//  Whatsapp
//
//  Created by iCommunity app on 29/08/2024.
//

import Foundation
import AVFoundation
import Combine

/// Recording Voice Messages.
/// Storing Message URL.
final class AudioRecorderService {
    
    private var audioRecorder: AVAudioRecorder?
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    private var startTime: Date?
    private var timer: AnyCancellable?
    
    deinit {
        tearDown()
        print("AudioRecorderService: has beed deinitialized")
    }
    
    func startRecording() {
        /// Setup Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
            print("AudioRecorderService: Successfully setup audio session")
        } catch {
            print("AudioRecorderService: failed to setup AVAudioSession \(error)")
        }
        
        /// Setup audio directory, where do wanna store the voice message? URL
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = Date().toString(dateFormat: "dd-MM-yyyy 'at' HH:mm:ss") + ".m4a"
        let audioFileURL = documentPath.appendingPathComponent(audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try .init(url: audioFileURL, settings: settings)
            audioRecorder?.record()
            isRecording = true
            startTime = Date()
            startTimer()
            print("AudioRecorderService: Successfully setup AVAudioRecorder")
        } catch {
            print("AudioRecorderService: failed to setup AVAudioRecorder \(error)")
        }
    }
    
    @discardableResult
    func stopRecording() async -> (audioURL: URL?, audioDuration: TimeInterval)? {
        guard isRecording else { return nil }
        let audioDuration = elapsedTime
        audioRecorder?.stop()
        isRecording = false
        timer?.cancel()
        elapsedTime = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            guard let audioURL = audioRecorder?.url else { return nil }
            return (audioURL, audioDuration)
        } catch {
            print("AudioRecorderService: failed to teardown AVAudioSession \(error)")
            return nil
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startTime = self?.startTime else { return }
                self?.elapsedTime = Date().timeIntervalSince(startTime)
                print("AudioRecorderService: elapsedTime: \(self?.elapsedTime ?? 0.0)")
            }
    }
    
    func tearDown() {
        Task {
            if isRecording { await stopRecording() }
            do {
                let fileManager = FileManager.default
                let folder = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let folderContents = try fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                deleteRecordings(for: folderContents)
                print("AudioRecorderService: was successfully teared down.")
            } catch {
                print("AudioRecorderService: failed to tearDown recorder files \(error)")
            }
        }
    }
    
    private func deleteRecordings(for urls: [URL]) {
        for url in urls {
            deleteRecording(at: url)
        }
    }
    
    func deleteRecording(at fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("AudioRecorderService: recorded file deleted successfully at \(fileURL).")
        } catch {
            print("AudioRecorderService: failed to delete recorded file \(error)")
        }
    }
}
