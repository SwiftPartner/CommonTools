//
//  ExtensionTools.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/18.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public extension Data {
    var isJSON: Bool {
        return JSONSerialization.isValidJSONObject(self)
    }
    // Data以MB为单位计算大小
    var countInMB: Double {
        return Double(count) / 1024.0 / 1024.0
    }
}

public extension String {

}

public extension UIScreen {
    var width: CGFloat { bounds.size.width }
    var height: CGFloat { bounds.size.height }
}

public extension UIView {
    var width: CGFloat { bounds.size.width }
    var height: CGFloat { bounds.size.height }
    var size: CGSize { bounds.size }

    func makeCorner(radius: CGFloat, borderColor: UIColor? = nil, borderWidth: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        layer.masksToBounds = true
    }

    func makeShadow(color: UIColor = .gray, offset: CGSize = CGSize(width: 0, height: 3), opacity: Float = 0.3, radius: CGFloat = 2, path: CGPath? = nil) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        if let path = path {
            layer.shadowPath = path
        }
    }
}

public extension UIImage {
    var width: CGFloat { size.width }
    var height: CGFloat { size.height }

    func fixedOrientation() -> UIImage? {

        guard imageOrientation != UIImage.Orientation.up else {
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        default:
            return self
        }
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        default:
            return self
        }
        ctx.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }


    /// 限制图片的宽高
    /// - Parameter maxWidth: 输出的图片的最大宽度，默认不限制
    /// - Parameter maxHeight: 输出图片的最大高度，默认不限制
    func limitImageSize(inWidth maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> UIImage? {
        guard let image = fixedOrientation() else { return nil }
        if image.width < maxWidth, image.height < maxHeight { return self }
        var aspectScale: CGFloat = 0
        if image.width > maxWidth {
            aspectScale = maxWidth / image.width
        }
        if image.height > maxHeight {
            let heightScale = maxHeight / image.height
            aspectScale = max(aspectScale, heightScale)
        }
        let aspectWidth = image.width * aspectScale
        let aspectHeight = image.height * aspectScale
        UIGraphicsBeginImageContext(CGSize(width: aspectWidth, height: aspectHeight))
        draw(in: CGRect(x: 0, y: 0, width: aspectWidth, height: aspectHeight))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }

    /// 限制图片的宽高和大小
    /// - Parameter maxWidth: 最大宽度（默认不限制）
    /// - Parameter maxHeight: 最大高度（默认不限制）
    /// - Parameter dataCount: 图片占用最大空间
    func limitImageSize(inWidth maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude, dataCount: Int) -> Data? {
        let image = limitImageSize(inWidth: maxWidth, maxHeight: maxHeight)
        func scalleImage(compressionQuality: CGFloat) -> Data? {
            print("新的压缩比\(compressionQuality)")
            guard let imageData = image?.jpegData(compressionQuality: compressionQuality) else { return nil }
            print("压缩后的图片大小\(imageData.count)")
            if imageData.count < dataCount || compressionQuality <= 0 {
                return imageData
            }
            return scalleImage(compressionQuality: compressionQuality - 0.1)
        }
        return scalleImage(compressionQuality: 1)
    }

    /// 异步压缩图片
    /// - Parameter maxWidth: 最大宽度（默认不限制）
    /// - Parameter maxHeight: 最大高度（默认不限制）
    /// - Parameter dataCount: 图片占用最大空间
    /// - Parameter completion: 回调
    func limitImageSizeAsync(inWidth maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude, dataCount: Int, completion: ((Data?) -> Void)?) {
        DispatchQueue.global().async {
            let data = self.limitImageSize(inWidth: maxWidth, maxHeight: maxHeight, dataCount: dataCount)
            completion?(data)
        }
    }

    /// 限制图片的大小
    /// - Parameter dataSize: 限制大小
    /// - Parameter file: 文件路径
    class func limitImageDataSize(_ dataSize: Int, from file: URL) -> UIImage? {
        guard let image = UIImage(contentsOfFile: file.path), let dataCount = image.pngData()?.count else { return nil }
        if dataCount <= dataSize { return image }
        let scale = CGFloat(dataSize) / CGFloat(dataCount)
        return image.scaleImage(scale: scale)
    }

    /// 按照比例缩放图片的宽高
    /// - Parameter scale: 缩放比
    func scaleImage(scale: CGFloat) -> UIImage? {
        let aspectWidth = width * scale
        let aspectHeight = height * scale
        UIGraphicsBeginImageContext(CGSize(width: aspectWidth, height: aspectHeight))
        draw(in: CGRect(x: 0, y: 0, width: aspectWidth, height: aspectHeight))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
}

public extension FileManager {
    /// 获取文件大小，以byte为单位；
    /// - Parameter fileUrl: 文件路径
    class func fileSizeInBytes(fileUrl: URL?) -> Int? {
        guard let fileUrl = fileUrl else {
            return nil
        }
        do {
            let atts = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
            if let fileSize = atts[.size] as? Int {
                return fileSize
            }
        } catch (let error) {
            Log.i("文件属性获取失败\(error)")
        }
        return nil
    }


    /// 获取文件大小，以MB为单位；
    /// - Parameter fileUrl: 文件路径
    class func fileSizeInMB(fileUrl: URL?) -> Double? {
        guard let bytes = fileSizeInBytes(fileUrl: fileUrl) else {
            return nil
        }
        return Double(bytes) / 1024.0 / 1024.0
    }

    class func createFileAsync(atPath path: String, contents: Data?, attributes: [FileAttributeKey: Any]?, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let result = FileManager.default.createFile(atPath: path, contents: contents, attributes: attributes)
            completion(result)
        }
    }
}


public extension URL {
    
}
