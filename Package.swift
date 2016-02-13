import PackageDescription

let package = Package(
    name: "HelloServer",
    dependencies: [
        .Package(url: "https://github.com/loganwright/vapor.git", majorVersion: 0),
        .Package(url: "https://github.com/gfx/Swift-PureJsonSerializer.git", majorVersion: 1)
    ]
)
