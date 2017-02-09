//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(identifier: "com.99centbrains.catwang-debug") ?? Bundle.main
  
  static func validate() throws {
    try intern.validate()
  }
  
  /// This `R.color` struct is generated, and contains static references to 0 color palettes.
  struct color {
    fileprivate init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 5 files.
  struct file {
    /// Resource file `Configuration-Beta.plist`.
    static let configurationBetaPlist = Rswift.FileResource(bundle: R.hostingBundle, name: "Configuration-Beta", pathExtension: "plist")
    /// Resource file `Configuration-Debug.plist`.
    static let configurationDebugPlist = Rswift.FileResource(bundle: R.hostingBundle, name: "Configuration-Debug", pathExtension: "plist")
    /// Resource file `Configuration-Release.plist`.
    static let configurationReleasePlist = Rswift.FileResource(bundle: R.hostingBundle, name: "Configuration-Release", pathExtension: "plist")
    /// Resource file `Configuration-Staging.plist`.
    static let configurationStagingPlist = Rswift.FileResource(bundle: R.hostingBundle, name: "Configuration-Staging", pathExtension: "plist")
    /// Resource file `Settings.bundle`.
    static let settingsBundle = Rswift.FileResource(bundle: R.hostingBundle, name: "Settings", pathExtension: "bundle")
    
    /// `bundle.url(forResource: "Configuration-Beta", withExtension: "plist")`
    static func configurationBetaPlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.configurationBetaPlist
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "Configuration-Debug", withExtension: "plist")`
    static func configurationDebugPlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.configurationDebugPlist
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "Configuration-Release", withExtension: "plist")`
    static func configurationReleasePlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.configurationReleasePlist
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "Configuration-Staging", withExtension: "plist")`
    static func configurationStagingPlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.configurationStagingPlist
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "Settings", withExtension: "bundle")`
    static func settingsBundle(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.settingsBundle
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 0 fonts.
  struct font {
    fileprivate init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 0 images.
  struct image {
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 0 nibs.
  struct nib {
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 0 reuse identifiers.
  struct reuseIdentifier {
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 0 view controllers.
  struct segue {
    fileprivate init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 2 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    /// Storyboard `Main`.
    static let main = _R.storyboard.main()
    
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    
    /// `UIStoryboard(name: "Main", bundle: ...)`
    static func main(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.main)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      // There are no resources to validate
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}

struct _R {
  struct nib {
    fileprivate init() {}
  }
  
  struct storyboard {
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType {
      typealias InitialController = UIKit.UIViewController
      
      let bundle = R.hostingBundle
      let name = "LaunchScreen"
      
      fileprivate init() {}
    }
    
    struct main: Rswift.StoryboardResourceWithInitialControllerType {
      typealias InitialController = ViewController
      
      let bundle = R.hostingBundle
      let name = "Main"
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}