import std/unittest
import flowgarage

suite "builder":
  test "builds multiple outputs":
    var bundle = initGarageBundle("daily", "Daily", createdAt = "2026-07-05T00:00:00Z")
    bundle.sections.add(section("summary", "Summary", "ok"))
    let outcome = build(initGarageBuildInput(bundle, @[rfMarkdown, rfJson, rfHtml]))
    check outcome.ok
    check outcome.outputs.len == 3

  test "returns validation errors as data":
    let outcome = build(initGarageBuildInput(initGarageBundle("empty", "Empty"), @[rfMarkdown]))
    check not outcome.ok
    check outcome.errors.len > 0

  test "rejects empty format list":
    var bundle = initGarageBundle("daily", "Daily")
    bundle.sections.add(section("summary", "Summary", "ok"))
    let outcome = build(initGarageBuildInput(bundle, @[]))
    check not outcome.ok
    check outcome.errors == @["at least one render format is required"]
