import Foundation
import ZIPFoundation

/// Demo-only ZIP helper. The caller runs file I/O off the main thread.
@objc(RWLogArchive)
public final class RWLogArchive: NSObject {
    @objc(createArchiveAtPath:fromDirectory:error:)
    public static func createArchive(atPath path: String, fromDirectory directory: String) throws {
        try FileManager.default.zipItem(
            at: URL(fileURLWithPath: directory, isDirectory: true),
            to: URL(fileURLWithPath: path),
            shouldKeepParent: false,
            compressionMethod: .deflate
        )
    }
}
