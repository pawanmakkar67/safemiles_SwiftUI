import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "DVIR" asset catalog image resource.
    static let DVIR = ImageResource(name: "DVIR", bundle: resourceBundle)

    /// The "Home" asset catalog image resource.
    static let home = ImageResource(name: "Home", bundle: resourceBundle)

    /// The "Logs" asset catalog image resource.
    static let logs = ImageResource(name: "Logs", bundle: resourceBundle)

    /// The "Menu" asset catalog image resource.
    static let menu = ImageResource(name: "Menu", bundle: resourceBundle)

    /// The "Rules" asset catalog image resource.
    static let rules = ImageResource(name: "Rules", bundle: resourceBundle)

    /// The "Tick" asset catalog image resource.
    static let tick = ImageResource(name: "Tick", bundle: resourceBundle)

    /// The "Vector" asset catalog image resource.
    static let vector = ImageResource(name: "Vector", bundle: resourceBundle)

    /// The "ble" asset catalog image resource.
    static let ble = ImageResource(name: "ble", bundle: resourceBundle)

    /// The "coDriver" asset catalog image resource.
    static let coDriver = ImageResource(name: "coDriver", bundle: resourceBundle)

    /// The "drive_ic" asset catalog image resource.
    static let driveIc = ImageResource(name: "drive_ic", bundle: resourceBundle)

    /// The "footer_info_card" asset catalog image resource.
    static let footerInfoCard = ImageResource(name: "footer_info_card", bundle: resourceBundle)

    /// The "infoPacket" asset catalog image resource.
    static let infoPacket = ImageResource(name: "infoPacket", bundle: resourceBundle)

    /// The "infoRed" asset catalog image resource.
    static let infoRed = ImageResource(name: "infoRed", bundle: resourceBundle)

    /// The "left" asset catalog image resource.
    static let left = ImageResource(name: "left", bundle: resourceBundle)

    /// The "loginBG" asset catalog image resource.
    static let loginBG = ImageResource(name: "loginBG", bundle: resourceBundle)

    /// The "logout" asset catalog image resource.
    static let logout = ImageResource(name: "logout", bundle: resourceBundle)

    /// The "off_ic" asset catalog image resource.
    static let offIc = ImageResource(name: "off_ic", bundle: resourceBundle)

    /// The "on_ic" asset catalog image resource.
    static let onIc = ImageResource(name: "on_ic", bundle: resourceBundle)

    /// The "pu_ic" asset catalog image resource.
    static let puIc = ImageResource(name: "pu_ic", bundle: resourceBundle)

    /// The "safemile_logo_ic" asset catalog image resource.
    static let safemileLogoIc = ImageResource(name: "safemile_logo_ic", bundle: resourceBundle)

    /// The "safemiles_white" asset catalog image resource.
    static let safemilesWhite = ImageResource(name: "safemiles_white", bundle: resourceBundle)

    /// The "sb_ic" asset catalog image resource.
    static let sbIc = ImageResource(name: "sb_ic", bundle: resourceBundle)

    /// The "selectVehicle" asset catalog image resource.
    static let selectVehicle = ImageResource(name: "selectVehicle", bundle: resourceBundle)

    /// The "selectVehicle 1" asset catalog image resource.
    static let selectVehicle1 = ImageResource(name: "selectVehicle 1", bundle: resourceBundle)

    /// The "user_ic" asset catalog image resource.
    static let userIc = ImageResource(name: "user_ic", bundle: resourceBundle)

    /// The "violationArrow" asset catalog image resource.
    static let violationArrow = ImageResource(name: "violationArrow", bundle: resourceBundle)

    /// The "ym_ic" asset catalog image resource.
    static let ymIc = ImageResource(name: "ym_ic", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "DVIR" asset catalog image.
    static var DVIR: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .DVIR)
#else
        .init()
#endif
    }

    /// The "Home" asset catalog image.
    static var home: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .home)
#else
        .init()
#endif
    }

    /// The "Logs" asset catalog image.
    static var logs: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logs)
#else
        .init()
#endif
    }

    /// The "Menu" asset catalog image.
    static var menu: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .menu)
#else
        .init()
#endif
    }

    /// The "Rules" asset catalog image.
    static var rules: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rules)
#else
        .init()
#endif
    }

    /// The "Tick" asset catalog image.
    static var tick: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tick)
#else
        .init()
#endif
    }

    /// The "Vector" asset catalog image.
    static var vector: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .vector)
#else
        .init()
#endif
    }

    /// The "ble" asset catalog image.
    static var ble: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ble)
#else
        .init()
#endif
    }

    /// The "coDriver" asset catalog image.
    static var coDriver: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coDriver)
#else
        .init()
#endif
    }

    /// The "drive_ic" asset catalog image.
    static var driveIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .driveIc)
#else
        .init()
#endif
    }

    /// The "footer_info_card" asset catalog image.
    static var footerInfoCard: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .footerInfoCard)
#else
        .init()
#endif
    }

    /// The "infoPacket" asset catalog image.
    static var infoPacket: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .infoPacket)
#else
        .init()
#endif
    }

    /// The "infoRed" asset catalog image.
    static var infoRed: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .infoRed)
#else
        .init()
#endif
    }

    /// The "left" asset catalog image.
    static var left: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .left)
#else
        .init()
#endif
    }

    /// The "loginBG" asset catalog image.
    static var loginBG: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginBG)
#else
        .init()
#endif
    }

    /// The "logout" asset catalog image.
    static var logout: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .logout)
#else
        .init()
#endif
    }

    /// The "off_ic" asset catalog image.
    static var offIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .offIc)
#else
        .init()
#endif
    }

    /// The "on_ic" asset catalog image.
    static var onIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .onIc)
#else
        .init()
#endif
    }

    /// The "pu_ic" asset catalog image.
    static var puIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .puIc)
#else
        .init()
#endif
    }

    /// The "safemile_logo_ic" asset catalog image.
    static var safemileLogoIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .safemileLogoIc)
#else
        .init()
#endif
    }

    /// The "safemiles_white" asset catalog image.
    static var safemilesWhite: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .safemilesWhite)
#else
        .init()
#endif
    }

    /// The "sb_ic" asset catalog image.
    static var sbIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .sbIc)
#else
        .init()
#endif
    }

    /// The "selectVehicle" asset catalog image.
    static var selectVehicle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .selectVehicle)
#else
        .init()
#endif
    }

    /// The "selectVehicle 1" asset catalog image.
    static var selectVehicle1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .selectVehicle1)
#else
        .init()
#endif
    }

    /// The "user_ic" asset catalog image.
    static var userIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .userIc)
#else
        .init()
#endif
    }

    /// The "violationArrow" asset catalog image.
    static var violationArrow: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .violationArrow)
#else
        .init()
#endif
    }

    /// The "ym_ic" asset catalog image.
    static var ymIc: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ymIc)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "DVIR" asset catalog image.
    static var DVIR: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .DVIR)
#else
        .init()
#endif
    }

    /// The "Home" asset catalog image.
    static var home: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .home)
#else
        .init()
#endif
    }

    /// The "Logs" asset catalog image.
    static var logs: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logs)
#else
        .init()
#endif
    }

    /// The "Menu" asset catalog image.
    static var menu: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .menu)
#else
        .init()
#endif
    }

    /// The "Rules" asset catalog image.
    static var rules: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rules)
#else
        .init()
#endif
    }

    /// The "Tick" asset catalog image.
    static var tick: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tick)
#else
        .init()
#endif
    }

    /// The "Vector" asset catalog image.
    static var vector: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .vector)
#else
        .init()
#endif
    }

    /// The "ble" asset catalog image.
    static var ble: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ble)
#else
        .init()
#endif
    }

    /// The "coDriver" asset catalog image.
    static var coDriver: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coDriver)
#else
        .init()
#endif
    }

    /// The "drive_ic" asset catalog image.
    static var driveIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .driveIc)
#else
        .init()
#endif
    }

    /// The "footer_info_card" asset catalog image.
    static var footerInfoCard: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .footerInfoCard)
#else
        .init()
#endif
    }

    /// The "infoPacket" asset catalog image.
    static var infoPacket: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .infoPacket)
#else
        .init()
#endif
    }

    /// The "infoRed" asset catalog image.
    static var infoRed: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .infoRed)
#else
        .init()
#endif
    }

    /// The "left" asset catalog image.
    static var left: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .left)
#else
        .init()
#endif
    }

    /// The "loginBG" asset catalog image.
    static var loginBG: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginBG)
#else
        .init()
#endif
    }

    /// The "logout" asset catalog image.
    static var logout: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .logout)
#else
        .init()
#endif
    }

    /// The "off_ic" asset catalog image.
    static var offIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .offIc)
#else
        .init()
#endif
    }

    /// The "on_ic" asset catalog image.
    static var onIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .onIc)
#else
        .init()
#endif
    }

    /// The "pu_ic" asset catalog image.
    static var puIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .puIc)
#else
        .init()
#endif
    }

    /// The "safemile_logo_ic" asset catalog image.
    static var safemileLogoIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .safemileLogoIc)
#else
        .init()
#endif
    }

    /// The "safemiles_white" asset catalog image.
    static var safemilesWhite: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .safemilesWhite)
#else
        .init()
#endif
    }

    /// The "sb_ic" asset catalog image.
    static var sbIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .sbIc)
#else
        .init()
#endif
    }

    /// The "selectVehicle" asset catalog image.
    static var selectVehicle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .selectVehicle)
#else
        .init()
#endif
    }

    /// The "selectVehicle 1" asset catalog image.
    static var selectVehicle1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .selectVehicle1)
#else
        .init()
#endif
    }

    /// The "user_ic" asset catalog image.
    static var userIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .userIc)
#else
        .init()
#endif
    }

    /// The "violationArrow" asset catalog image.
    static var violationArrow: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .violationArrow)
#else
        .init()
#endif
    }

    /// The "ym_ic" asset catalog image.
    static var ymIc: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ymIc)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif