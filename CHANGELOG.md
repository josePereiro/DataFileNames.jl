# [DataFileNames]

Just a package for pretty naming data files. It was inspired on [DrWatson] `savename` utility.

<!-- ## [Unreleased] -->

## [0.3.0] - 2021-06-22

### Changed

- Improve extension detection. Now it will take that extension (if it is a valid `dfname`) differently
depending if it is a parametrized name or not. In the case of the former, it is just all after the right param body separator. On the other case it is the shortest matching extension pattern.

## [0.2.0] - 2021-06-22

- Start the `CHANGELOG`
- A first good implementation

[Unreleased]: https://github.com/josePereiro/UtilsJL/v0.2.0...HEAD
[0.3.0]: https://github.com/josePereiro/UtilsJL/releases/tag/v0.3.0
[0.2.0]: https://github.com/josePereiro/DataFileNames.jl/compare/v0.1.0...v0.2.0
[DataFileNames]: https://github.com/josePereiro/DataFileNames.jl
[DrWatson]: https://github.com/JuliaDynamics/DrWatson.jl