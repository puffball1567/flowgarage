import flowgarage

proc main() =
  var totalOutputs = 0
  for i in 0 ..< 1000:
    var bundle = initGarageBundle("bundle-" & $i, "Daily flow " & $i, summary = "leak probe")
    bundle.sections.add section("summary", "Summary", "Flow completed")
    bundle.sections.add section("metrics", "Metrics", "Cycle time looks stable")
    bundle.artifacts.add artifact("report", "Report", akReport, "text/plain", "ok", metadata([("run", $i)]))
    discard render(bundle, rfMarkdown)
    discard render(bundle, rfJson)
    totalOutputs += 2

  doAssert totalOutputs == 2000

main()
