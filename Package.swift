import PackageDescription

let package = Package(
    name: "HelloServer",
    dependencies: [
        .Package(url: "https://github.com/loganwright/vapor.git", majorVersion: 0),
        .Package(url: "https://github.com/loganwright/genome.git", majorVersion: 2),
        .Package(url: "https://github.com/novi/mysql-swift.git", majorVersion: 0)
    ]
)
