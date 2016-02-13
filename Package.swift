import PackageDescription

let package = Package(
    name: "HelloServer",
    dependencies: [
        .Package(url: "https://github.com/loganwright/vapor.git", majorVersion: 0),
        .Package(url: "https://github.com/loganwright/genome.git", majorVersion: 2),
        .Package(url: "https://github.com/gfx/Swift-PureJsonSerializer.git", majorVersion: 1),
        .Package(url: "https://github.com/tannernelson/fluent.git", majorVersion: 0),
        .Package(url: "https://github.com/loganwright/fluent-sqlite-driver.git", majorVersion: 0)
    ]
)
