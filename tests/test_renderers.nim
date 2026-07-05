import std/[unittest, strutils]
import flowgarage

proc sampleBundle(): GarageBundle =
  result = initGarageBundle("run:1", "Run <Report>", summary = "A&B", createdAt = "2026-07-05T00:00:00Z")
  result.sections.add(section("summary", "Summary", "line 1"))
  result.artifacts.add(artifact("json", "Metrics", akDataset, "application/json", "{}", metadata([])))

suite "renderers":
  test "renders markdown":
    let output = sampleBundle().render(rfMarkdown)
    check output.mediaType == "text/markdown"
    check output.content.contains("# Run <Report>")
    check output.content.contains("`json` Metrics")
    check output.content.contains("application/json")

  test "renders html with escaping":
    let output = sampleBundle().render(rfHtml)
    check output.mediaType == "text/html"
    check output.content.contains("Run &lt;Report&gt;")
    check output.content.contains("A&amp;B")
    check output.content.contains("<li><code>json</code>")

  test "renders json":
    let output = sampleBundle().render(rfJson)
    check output.mediaType == "application/json"
    check output.content.contains("schemaVersion")
    check output.content.contains("artifacts")
