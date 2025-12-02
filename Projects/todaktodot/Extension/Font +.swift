//
//  Font +.swift
//  todaktodot
//
//  Created by markany on 11/28/25.
//


import UIKit

extension UIFont {
    /// Weight 100
    static func pretenThin(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.thin.font(size: size)
    }
    /// Weight 200
    static func pretenExtraLight(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.extraLight.font(size: size)
    }
    /// Weight 300
    static func pretenLight(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.light.font(size: size)
    }
    /// Weight 400
    static func pretenRegular(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.regular.font(size: size)
    }
    /// Weight 500
    static func pretenMedium(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.medium.font(size: size)
    }
    /// Weight 600
    static func pretenSemiBold(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.semiBold.font(size: size)
    }
    /// Weight 700
    static func pretenBold(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.bold.font(size: size)
    }
    /// Weight 800
    static func pretenExtraBold(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.extraBold.font(size: size)
    }
    /// Weight 900
    static func pretenBlack(_ size: CGFloat) -> UIFont {
        return TodaktodotFontFamily.PretendardVariable.black.font(size: size)
    }
}

