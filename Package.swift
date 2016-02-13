import PackageDescription

let package = Package(
    name: "HelloServer",
    dependencies: [
        .Package(url: "https://github.com/tannernelson/vapor-stencil.git", majorVersion: 0)
    ]
)
