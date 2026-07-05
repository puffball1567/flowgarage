import flowgarage

var bundle = initGarageBundle("daily-report", "Daily Report", summary = "Workflow output package")
bundle.sections.add(section("summary", "Summary", "All required work completed."))
bundle.artifacts.add(artifact("metrics-json", "Metrics JSON", akDataset, "application/json", "{\"ok\":true}", metadata(@[("source", "flowsurveyor")])) )

let outcome = build(initGarageBuildInput(bundle, @[rfMarkdown, rfJson]))
if outcome.ok:
  for output in outcome.outputs:
    echo output.mediaType
else:
  echo outcome.errors
