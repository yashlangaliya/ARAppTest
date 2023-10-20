//
//  Helpers.swift
//  ARApp
//
//  Created by yash-mac on 18/10/23.
//
import AVFoundation
import Foundation
import UIKit
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String {
    func getURLForFile() -> URL? {
        var url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        url.append(component: self)
        return url.checkFileExist() ? url : nil
    }
}

extension URL {
    func getVideoDuration ()-> String {
        let asset = AVAsset(url: self)
        let duration = asset.duration
        let durationTime = Int(CMTimeGetSeconds(duration))
        let minutes = durationTime / 60
        let seconds = durationTime % 60
        return minutes > 0 || seconds > 0 ? String(format: "%02d:%02d", minutes, seconds) : "00:00"
    }
    
    func checkFileExist() -> Bool {
            let path = self.path
            if (FileManager.default.fileExists(atPath: path))   {
                print("FILE AVAILABLE")
                return true
            }else        {
                print("FILE NOT AVAILABLE")
                return false;
            }
    }
    
    func getVideoThumbnail(cellSize: CGSize,completion: @escaping ((_ images: UIImage, _ completed: Bool)->Void)) {
        let asset = AVAsset(url: self) //2
        
        let imageGenerator = AVAssetImageGenerator(asset: asset) //3
        imageGenerator.requestedTimeToleranceBefore = .indefinite
        imageGenerator.requestedTimeToleranceAfter = .indefinite
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = cellSize
        let duration = asset.duration
        let seconds = CMTimeGetSeconds(duration)
        let addition = seconds / 15
        var number = 1.0

        var times = [NSValue]()
        times.append(NSValue(time: CMTimeMake(value: Int64(number), timescale: 1)))
        while number < seconds {
            number += addition
            times.append(NSValue(time: CMTimeMake(value: Int64(number), timescale: 1)))
        }

        struct Formatter {
            static let formatter: DateFormatter = {
                let result = DateFormatter()
                result.dateStyle = .short
                return result
            }()
        }
        var count = 0
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, cgImage, actualImageTime, status, error) in

            let seconds = CMTimeGetSeconds(requestedTime)
            let date = Date(timeIntervalSinceNow: seconds)
            let time = Formatter.formatter.string(from: date)

            switch status {
            case .succeeded: do {
                    if let image = cgImage {
                        let img = UIImage(cgImage: image)
                        count += 1
                        completion(img, times.count - 1 == count)
                    }
                    else {
                        print("Failed to generate a valid thumbnail for time: \(time)")
                    }
                }

            default:
                print("thumbnail generation failed")
                
            }
        }
        
    }
}
