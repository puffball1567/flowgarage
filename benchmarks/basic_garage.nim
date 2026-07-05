import std/[monotimes, strformat, times]
import flowgarage

proc elapsedMs(started: MonoTime): int64 =
  (getMonoTime() - started).inMilliseconds

var bundle = initGarageBundle("bench", "Benchmark", createdAt = "2026-07-05T00:00:00Z")
for i in 0 ..< 1000:
  bundle.sections.add(section("section-" & $i, "Section " & $i, "body " & $i))
  bundle.artifacts.add(artifact("artifact-" & $i, "Artifact " & $i, akReport, "text/plain", "content " & $i, metadata([])))

let started = getMonoTime()
let outcome = build(initGarageBuildInput(bundle, @[rfMarkdown, rfJson, rfHtml]))
doAssert outcome.ok
echo &"build: {bundle.sections.len} sections, {bundle.artifacts.len} artifacts, {outcome.outputs.len} outputs in {elapsedMs(started)} ms"
