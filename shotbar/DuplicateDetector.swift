import Foundation
import CoreGraphics
import Vision

/// Protocol for detecting duplicate images.
protocol DuplicateDetecting {
    /// Resets the internal state (e.g., clears the previous image reference).
    func reset()

    /// Checks if the provided image is a duplicate of the previously processed image.
    /// - Parameter image: The new image to check.
    /// - Returns: `true` if the image is considered a duplicate, `false` otherwise.
    func isDuplicate(_ image: CGImage) async -> Bool

    /// Sets the sensitivity threshold for duplicate detection.
    /// - Parameter value: A value typically between 0.0 and 1.0. Lower values mean stricter matching.
    func setThreshold(_ value: Double)
}

/// A duplicate detector that uses the Vision framework's Feature Print to detect similarities.
/// It ignores minor differences (like a clock ticking) based on the configured threshold.
class VisionDuplicateDetector: DuplicateDetecting {
    private var lastObservation: VNFeaturePrintObservation?

    /// The distance threshold. If the distance between two images is less than this value,
    /// they are considered duplicates.
    /// 0.0 means identical. A higher value (e.g., 0.1) allows for some variation.
    private var threshold: Double = 0.05 // Default starting value

    func reset() {
        lastObservation = nil
    }

    func setThreshold(_ value: Double) {
        self.threshold = value
    }

    func isDuplicate(_ image: CGImage) async -> Bool {
        return await withCheckedContinuation { continuation in
            let request = VNGenerateImageFeaturePrintRequest { [weak self] request, error in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }

                if let error = error {
                    print("VisionDuplicateDetector error: \(error)")
                    continuation.resume(returning: false)
                    return
                }

                guard let observation = request.results?.first as? VNFeaturePrintObservation else {
                    continuation.resume(returning: false)
                    return
                }

                // If we don't have a previous image, this is not a duplicate.
                // We just store the current one.
                guard let lastObservation = self.lastObservation else {
                    self.lastObservation = observation
                    continuation.resume(returning: false)
                    return
                }

                do {
                    var distance: Float = 0
                    try observation.computeDistance(&distance, to: lastObservation)

                    // Update the last observation to the current one for the next comparison
                    // (This is a design choice: do we compare against the *first* of a sequence or the *previous*?
                    // Usually "previous" to detect when the screen stops changing.)
                    self.lastObservation = observation

                    // Check if distance is within the threshold
                    // distance is a Float, threshold is Double
                    let isDup = Double(distance) <= self.threshold
                    if isDup {
                        print("Duplicate detected. Distance: \(distance), Threshold: \(self.threshold)")
                    } else {
                        // print("Not a duplicate. Distance: \(distance)")
                    }

                    continuation.resume(returning: isDup)
                } catch {
                    print("VisionDuplicateDetector distance computation error: \(error)")
                    continuation.resume(returning: false)
                }
            }

            // Prefer .fast or .balanced. .accurate might be too slow for real-time loop?
            // But we are taking screenshots with 1s interval, so .accurate is probably fine and better for "ignoring clocks".
            // Actually, revision1 is the default. Let's stick to defaults or explicit revision.
            request.revision = VNGenerateImageFeaturePrintRequestRevision1

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("VisionDuplicateDetector handler error: \(error)")
                continuation.resume(returning: false)
            }
        }
    }
}
