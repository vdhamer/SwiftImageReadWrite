//
//  Copyright © 2023 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import CoreGraphics
import ImageIO

public extension CGImage {
	/// Return the image data in the required format
	/// - Parameters:
	///   - type: The format type to export (with options)
	///   - otherOptions: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
	/// - Returns: The formatted data, or nil on error
	func imageData(for type: ImageExportType, otherOptions: [String: Any]? = nil) throws -> Data {
		switch type {
		case .png(scale: let scale, excludeGPSData: let excludeGPSData):
			return try self.dataRepresentation(
				type: type.type,
				dpi: scale * 72.0,
				excludeGPSData: excludeGPSData,
				otherOptions: otherOptions
			)
		case .gif:
			return try self.dataRepresentation(
				type: type.type,
				dpi: 72.0,
				otherOptions: otherOptions
			)
		case .jpg(scale: let scale, compression: let compression, excludeGPSData: let excludeGPSData):
			return try self.dataRepresentation(
				type: type.type,
				dpi: scale * 72.0,
				compression: compression,
				excludeGPSData: excludeGPSData,
				otherOptions: otherOptions
			)
		case .tiff(scale: let scale, compression: let compression, excludeGPSData: let excludeGPSData):
			return try self.dataRepresentation(
				type: type.type,
				dpi: scale * 72.0,
				compression: compression,
				excludeGPSData: excludeGPSData,
				otherOptions: otherOptions
			)
		case .pdf(size: let size):
			return try self.pdfRepresentation(size: size)
		}
	}
}

// MARK: - Conveniences

public extension CGImage {
	struct ImageRepresentation {
		@usableFromInline let owner: CGImage
		fileprivate init(_ owner: CGImage) {
			self.owner = owner
		}

		/// Create a png representation of the image
		/// - Parameters:
		///   - dpi: The image's dpi
		///   - excludeGPSData: Strip any gps data
		/// - Returns: image data
		@inlinable func png(dpi: CGFloat, excludeGPSData: Bool = false) throws -> Data {
			try owner.imageData(for: .png(scale: dpi / 72.0, excludeGPSData: excludeGPSData))
		}

		/// Create a png representation of the image
		/// - Parameters:
		///   - scale: The image's scale value
		///   - excludeGPSData: Strip any gps data
		/// - Returns: image data
		@inlinable func png(scale: CGFloat = 1, excludeGPSData: Bool = false) throws -> Data {
			try owner.imageData(for: .png(scale: scale, excludeGPSData: excludeGPSData))
		}

		/// Create a jpeg representation of the image
		/// - Parameters:
		///   - dpi: The image's dpi
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		///   - excludeGPSData: Strip any gps data
		/// - Returns: image data
		@inlinable func jpeg(dpi: CGFloat, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
			try owner.imageData(for: .jpg(scale: dpi / 72.0, compression: compression, excludeGPSData: excludeGPSData))
		}

		/// Create a jpeg representation of the image
		/// - Parameters:
		///   - scale: The image's scale value
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		///   - excludeGPSData: Strip any gps data
		/// - Returns: image data
		@inlinable func jpeg(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
			try owner.imageData(for: .jpg(scale: scale, compression: compression, excludeGPSData: excludeGPSData))
		}

		/// Create a tiff representation of the image
		/// - Parameters:
		///   - dpi: The image's dpi
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		///   - excludeGPSData: Strip any gps data
		/// - Returns: image data
		@inlinable func tiff(dpi: CGFloat, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
			try owner.imageData(for: .tiff(scale: dpi / 72.0, compression: compression, excludeGPSData: excludeGPSData))
		}

		/// Create a tiff representation of the image
		/// - Parameters:
		///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
		///   - compression: The compression level to apply (clamped to 0 ... 1)
		///   - excludeGPSData: Strip any gps data
		/// - Returns: image data
		@inlinable func tiff(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
			try owner.imageData(for: .tiff(scale: scale, compression: compression, excludeGPSData: excludeGPSData))
		}

		/// Create a gif representation of the image
		/// - Returns: image data
		@inlinable func gif() throws -> Data {
			try owner.imageData(for: .gif)
		}

		/// Generate a PDF representation of this image
		/// - Parameter size: The output size in pixels
		/// - Returns: PDF data
		@inlinable func pdf(size: CGSize) throws -> Data {
			try owner.imageData(for: .pdf(size: size))
		}
	}

	var representation: ImageRepresentation { ImageRepresentation(self) }
}

// MARK: - PDF representation

public extension CGImage {
	/// Generate a PDF representation of this image
	/// - Parameter size: The output size in pixels
	/// - Returns: PDF data
	func pdfRepresentation(size: CGSize) throws -> Data {
		try UsingSinglePagePDFContext(size: size) { context, rect in
			context.draw(self, in: CGRect(origin: .zero, size: size))
		}
	}
}

// MARK: - Data representation

internal extension CGImage {
	func dataRepresentation(
		type: CFString,
		dpi: CGFloat,
		compression: CGFloat? = nil,
		excludeGPSData: Bool = false,
		otherOptions: [String: Any]? = nil
	) throws -> Data {
		// Make sure that the DPI level is at least somewhat sane
		if dpi <= 0 {
			throw ImageReadWriteError.invalidDPI
		}

		var options: [CFString: Any] = [
			kCGImagePropertyPixelWidth: self.width,
			kCGImagePropertyPixelHeight: self.height,
			kCGImagePropertyDPIWidth: dpi,
			kCGImagePropertyDPIHeight: dpi,
		]

		if let compression = compression {
			options[kCGImageDestinationLossyCompressionQuality] = min(1, max(0, compression))
		}

		if excludeGPSData == true {
			options[kCGImageMetadataShouldExcludeGPS] = true
		}

		// Add in the user's customizations
		otherOptions?.forEach { options[$0.0 as CFString] = $0.1 }

		guard
			let mutableData = CFDataCreateMutable(nil, 0),
			let destination = CGImageDestinationCreateWithData(mutableData, type, 1, nil)
		else {
			throw ImageReadWriteError.cannotCreateDestination
		}

		CGImageDestinationAddImage(destination, self, options as CFDictionary)
		CGImageDestinationFinalize(destination)

		return mutableData as Data
	}
}
