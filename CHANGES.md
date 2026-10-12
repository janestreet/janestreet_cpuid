## Release v0.17.1
+ Use the standard OCaml allocator for arbitrary CPUID results, fixing build and
  link failures on upstream OCaml (issue #1).
+ Restrict availability to Linux x86_64, the architecture supported by this
  release's CPUID stubs.

## Release v0.17.0
+ Renamed `cpuid_fetch.exe` to `cpuid_tool.exe`
+ Added support to dump arbitrary CPUID leaf and subleaf as hex string
