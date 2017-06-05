import PackageDescription

let package = Package(
    name: "SubContract_API",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/matthijs2704/vapor-apns", majorVersion: 1, minor: 2),
        .Package(url: "https://github.com/BrettRToomey/Jobs.git", majorVersion: 0),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/ankurp/Dollar", majorVersion: 6, minor: 2),
        .Package(url: "https://github.com/SwifterSwift/SwifterSwift", majorVersion: 1, minor: 6),
        .Package(url: "https://github.com/malcommac/SwiftDate", majorVersion: 4, minor: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

