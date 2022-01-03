id: u8xgq6eugih6ex1iivanolxj6srfxst54023p0u3bg9rorji
name: zpp-snappy
main: src/lib.zig
license: APACHE
description: snappy lib for zig
c_include_dirs:
  - include
  - snappy
c_libs:
  - snappy
dependencies:
  - src: git https://github.com/zpplibs/zpp branch-master
root_dependencies:
  - src: git https://github.com/zpplibs/zpp branch-master
