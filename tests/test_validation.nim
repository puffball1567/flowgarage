import std/unittest
import flowgarage

suite "validation":
  test "accepts a valid bundle":
    var bundle = initGarageBundle("daily", "Daily Report", summary = "done", createdAt = "2026-07-05T00:00:00Z")
    bundle.sections.add(section("summary", "Summary", "All tasks completed."))
    bundle.artifacts.add(artifact("log", "Run log", akLog, "text/plain", "ok", metadata(@[("source", "test")])) )
    let checked = bundle.validate()
    check checked.ok
    check checked.errors.len == 0

  test "rejects empty bundles":
    let checked = initGarageBundle("empty", "Empty").validate()
    check not checked.ok
    check checked.errors.len == 1

  test "rejects invalid ids and duplicate ids":
    var bundle = initGarageBundle("bad id", "Bad")
    bundle.sections.add(section("same", "One", "body"))
    bundle.sections.add(section("same", "Two", "body"))
    bundle.artifacts.add(artifact("", "Artifact"))
    let checked = bundle.validate()
    check not checked.ok
    check checked.errors.len >= 3

  test "rejects blank titles and media types":
    var bundle = initGarageBundle("bundle", "  ")
    bundle.sections.add(section("s", " ", "body"))
    bundle.artifacts.add(artifact("a", "Artifact", akReport, " ", "content", metadata([])))
    let checked = bundle.validate()
    check not checked.ok
    check checked.errors.len >= 3
