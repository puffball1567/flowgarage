import std/[json, unittest]

import flowgarage

suite "package":
  test "creates safe default file names":
    check safeFileStem("Daily Report: 2026/07/05") == "daily-report-2026-07-05"
    check safeFileStem("...") == "bundle"
    check defaultFileName("Daily Report", rfMarkdown) == "daily-report.md"
    check defaultFileName("Daily Report", rfJson) == "daily-report.json"
    check defaultFileName("Daily Report", rfHtml) == "daily-report.html"

  test "builds package manifest from outputs":
    var bundle = initGarageBundle("daily-report", "Daily",
                                  createdAt = "2026-07-05T00:00:00Z")
    bundle.sections.add(section("summary", "Summary", "ok"))

    let result = packageWithManifest(bundle, @[rfMarkdown, rfJson])
    check result.ok
    check result.package.outputs.len == 2
    check result.package.manifest.schemaVersion == 1
    check result.package.manifest.bundleId == "daily-report"
    check result.package.manifest.files[0].fileName == "daily-report.md"
    check result.package.manifest.files[0].byteSize > 0

  test "serializes package manifest":
    let manifest = GaragePackageManifest(
      schemaVersion: 1,
      bundleId: "daily",
      createdAt: "2026-07-05T00:00:00Z",
      files: @[GarageOutputFile(fileName: "daily.md", format: rfMarkdown,
                                mediaType: "text/markdown", byteSize: 12)]
    )
    let node = parseJson(manifest.toJsonString())
    check node["schemaVersion"].getInt() == 1
    check node["files"][0]["fileName"].getStr() == "daily.md"

  test "returns validation errors when package cannot be built":
    let result = packageWithManifest(initGarageBundle("empty", "Empty"), @[rfJson])
    check not result.ok
    check result.errors.len > 0
