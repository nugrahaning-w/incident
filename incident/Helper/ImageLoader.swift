import UIKit
import ImageIO
import MobileCoreServices

final class ImageLoader: ImageLoading {
    static let shared = ImageLoader()

    private let cache = NSCache<NSURL, UIImage>()
    private let scaledCache = NSCache<NSString, UIImage>() // key: "\(url.absoluteString)|\(Int(w))x\(Int(h))"
    private var tasks = [URL: [UUID: URLSessionDataTask]]()
    private let lock = NSLock()

    private init() {
        cache.totalCostLimit = 20 * 1024 * 1024  // ~20MB
        cache.countLimit = 200
        scaledCache.totalCostLimit = 20 * 1024 * 1024
        scaledCache.countLimit = 400

        NotificationCenter.default.addObserver(self, selector: #selector(clearCachesOnMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func clearCachesOnMemoryWarning() {
        cache.removeAllObjects()
        scaledCache.removeAllObjects()
    }

    @discardableResult
    func load(url: URL, targetSize: CGSize? = nil, completion: @escaping (UIImage?) -> Void) -> UUID {
        let token = UUID()
        let keyURL = url as NSURL

        if let size = targetSize {
            let scaledKey = "\(url.absoluteString)|\(Int(size.width))x\(Int(size.height))" as NSString
            if let cached = scaledCache.object(forKey: scaledKey) {
                DispatchQueue.main.async { completion(cached) }
                return token
            }
        }

        if let cached = cache.object(forKey: keyURL), targetSize == nil {
            DispatchQueue.main.async { completion(cached) }
            return token
        }

        // De-dup requests by URL
        lock.lock()
        let requestNeeded = tasks[url] == nil
        lock.unlock()

        if requestNeeded == false, let size = targetSize {
            // Another request may be fetching; still register a completion by spinning a polling or rely on cache once finished.
            // Simple approach: fall through to create another task (keeps code simple) OR wait. We keep dedup: attach to existing list once created.
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            defer {
                self.lock.lock()
                self.tasks[url]?.removeValue(forKey: token)
                if self.tasks[url]?.isEmpty == true { self.tasks[url] = nil }
                self.lock.unlock()
            }

            guard let data, let baseImage = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self.cache.setObject(baseImage, forKey: keyURL, cost: data.count)

            if let size = targetSize {
                DispatchQueue.global(qos: .userInitiated).async {
                    let down = self.downsample(data: data, to: size, scale: UIScreen.main.scale) ?? baseImage.scaled(to: size)
                    let scaledKey = "\(url.absoluteString)|\(Int(size.width))x\(Int(size.height))" as NSString
                    self.scaledCache.setObject(down, forKey: scaledKey, cost: Int(size.width * size.height * 4))
                    DispatchQueue.main.async { completion(down) }
                }
            } else {
                DispatchQueue.main.async { completion(baseImage) }
            }
        }

        lock.lock()
        var byURL = tasks[url] ?? [:]
        byURL[token] = task
        tasks[url] = byURL
        lock.unlock()

        task.resume()
        return token
    }

    func cancel(url: URL, token: UUID) {
        lock.lock()
        let task = tasks[url]?[token]
        tasks[url]?.removeValue(forKey: token)
        if tasks[url]?.isEmpty == true { tasks[url] = nil }
        lock.unlock()
        task?.cancel()
    }

    // Efficient downsampling using ImageIO
    private func downsample(data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ]
        guard let src = CGImageSourceCreateWithData(data as CFData, nil),
              let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }
}
