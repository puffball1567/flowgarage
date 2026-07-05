import std/[json, unittest]
import flowgarage

suite "json io":
  test "serializes bundle schema":
    var bundle = initGarageBundle("daily", "Daily", createdAt = "2026-07-05T00:00:00Z")
    bundle.sections.add(section("summary", "Summary", "ok"))
    bundle.artifacts.add(artifact("report", "Report", akReport, "text/markdown", "# ok", metadata(@[("kind", "demo")])) )
    let node = parseJson(bundle.toJsonString())
    check node["schemaVersion"].getInt() == 1
    check node["sections"].len == 1
    check node["artifacts"][0]["metadata"]["kind"].getStr() == "demo"
