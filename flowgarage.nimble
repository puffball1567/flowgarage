version       = "0.1.1"
author        = "flowgarage contributors"
description   = "Artifact and report assembly primitives for FlowBrigade Toolkit workflows."
license       = "Apache-2.0"
srcDir        = "src"
installExt    = @["nim"]
skipDirs      = @[
  ".github",
  "benchmarks",
  "docs",
  "examples",
  "tests"
]

requires "nim >= 2.2.0"

task test, "Run the test suite":
  exec "nim r --nimcache:/tmp/flowgarage-test-nimcache -p:src tests/all.nim"

task leak, "Run the ARC leak probe under Valgrind":
  exec "nim c -d:release --nimcache:/tmp/flowgarage-leak-nimcache -p:src --out:/tmp/flowgarage-leak-probe tests/leak_probe.nim"
  exec "valgrind --leak-check=full --show-leak-kinds=definite,indirect --errors-for-leak-kinds=definite,indirect --error-exitcode=99 /tmp/flowgarage-leak-probe"

task examples, "Check examples":
  exec "nim check --nimcache:/tmp/flowgarage-nimcache -p:src examples/basic_garage.nim"

task bench, "Run basic local benchmarks":
  exec "nim r -d:release --nimcache:/tmp/flowgarage-bench-nimcache -p:src benchmarks/basic_garage.nim"
