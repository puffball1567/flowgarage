import std/unittest
import flowgarage

suite "memory model":
  test "uses Nim ARC memory manager":
    when defined(gcArc):
      check true
    else:
      check false

  test "creates and releases report bundles under ARC":
    var totalSections = 0
    for i in 0 ..< 200:
      var bundle = initGarageBundle("bundle-" & $i, "Daily flow " & $i, summary = "memory test")
      bundle.sections.add section("summary", "Summary", "Flow completed")
      bundle.artifacts.add artifact("report", "Report", akReport, "text/plain", "ok", metadata([("run", $i)]))
      totalSections += bundle.sections.len
    check totalSections == 200
