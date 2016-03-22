import PackageDescription

let package = Package(
    name: "HelloServer",
    dependencies: [
        .Package(url: "https://github.com/loganwright/genome.git", majorVersion: 2),
        .Package(url: "https://github.com/qutheory/vapor.git", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/loganwright/MongoKitten.git", majorVersion: 0, minor: 3)
//        .Package(url: "https://github.com/loganwright/swifter.git", majorVersion: 1),
    ]
)
