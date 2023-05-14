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

// Extensions for the platform image types (NSImage, UIImage)

import Foundation
import CoreGraphics

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Export

public extension PlatformImage {
	/// Return the image data in the required format
	/// - Parameter type: The format type to export (with options)
	/// - Returns: The formatted data
	@inlinable func imageData(for type: ImageExportType) throws -> Data {
		guard let image = self.cgImage else {
			throw ImageReadWriteError.cannotCreateCGImage
		}
		return try image.imageData(for: type)
	}
}

public extension PlatformImage {
	struct ImageRepresentation {
		@usableFromInline let owner: PlatformImage
		fileprivate init(_ owner: PlatformImage) {
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

	/// Returns a representation object which can export image types
	var representation: ImageRepresentation { ImageRepresentation(self) }
}
