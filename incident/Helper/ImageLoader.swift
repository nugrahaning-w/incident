import UIKit

// Cache Management
final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func load(url: URL, targetSize: CGSize? = nil, completion: @escaping (UIImage?) -> Void) {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            if let size = targetSize {
                DispatchQueue.global(qos: .userInitiated).async {
                    let scaled = cached.scaled(to: size)
                    DispatchQueue.main.async { completion(scaled) }
                }
            } else {
                completion(cached)
            }
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(image, forKey: key)

            if let size = targetSize {
                DispatchQueue.global(qos: .userInitiated).async {
                    let scaled = image.scaled(to: size)
                    DispatchQueue.main.async { completion(scaled) }
                }
            } else {
                DispatchQueue.main.async { completion(image) }
            }
        }.resume()
    }
}
