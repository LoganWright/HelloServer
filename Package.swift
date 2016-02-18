import PackageDescription

let package = Package(
    name: "HelloServer",
    dependencies: [
        .Package(url: "https://github.com/loganwright/genome.git", majorVersion: 2),
//        .Package(url: "https://github.com/loganwright/Curassow.git", majorVersion: 0, minor: 5),
        .Package(url: "https://github.com/loganwright/swifter.git", majorVersion: 1),
    ]
)
