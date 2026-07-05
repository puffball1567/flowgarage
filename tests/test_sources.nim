import std/[strutils, tables, unittest]

import flowgarage

suite "sources":
  test "converts source records into bundle sections":
    let records = @[
      sourceRecord("logbook-run", "Logbook Run", gskLogbook,
                   "3 tasks completed", "No retry required.", "info",
                   metadata(@[("runId", "daily")])),
      sourceRecord("survey-bottleneck", "Survey Finding", gskSurveyor,
                   "Slow section found", "extract took 80% of elapsed time.",
                   "warning", metadata(@[("node", "extract")]))
    ]

    let bundle = bundleFromSources("daily", "Daily Report", records,
                                   summary = "Generated from source records",
                                   createdAt = "2026-07-05T00:00:00Z")

    check bundle.sections.len == 2
    check bundle.sections[0].metadata["sourceKind"] == "gskLogbook"
    check bundle.sections[1].metadata["severity"] == "warning"

  test "validates source records through normal bundle validation":
    let records = @[sourceRecord("bad id", "", gskCustom, "", "", "info",
                                 metadata([]))]
    let checked = validateSources(records)
    check not checked.ok
    check checked.errors.len >= 2

  test "renders source metadata into markdown and html":
    let records = @[sourceRecord("survey", "Survey", gskSurveyor,
                                 "summary", "body", "warning",
                                 metadata(@[("node", "publish")]))]
    let bundle = bundleFromSources("daily", "Daily", records,
                                   createdAt = "2026-07-05T00:00:00Z")
    check bundle.render(rfMarkdown).content.contains("`sourceKind`: gskSurveyor")
    check bundle.render(rfHtml).content.contains("<dt>severity</dt><dd>warning</dd>")
