import std/[strutils, tables]

import ./types
import ./validation

proc sectionFromSource*(record: GarageSourceRecord): ReportSection =
  var body = ""
  if record.summary.strip.len > 0:
    body.add(record.summary.strip)
  if record.body.strip.len > 0:
    if body.len > 0:
      body.add("\n\n")
    body.add(record.body.strip)
  if body.len == 0:
    body = "(no details)"

  var meta = record.metadata
  meta["sourceKind"] = $record.kind
  meta["severity"] = record.severity
  section(record.id, record.title, body, meta)

proc bundleFromSources*(id, title: string; records: openArray[GarageSourceRecord];
                        summary = ""; createdAt = ""): GarageBundle =
  result = initGarageBundle(id, title, summary = summary, createdAt = createdAt)
  for record in records:
    result.sections.add(sectionFromSource(record))

proc validateSources*(records: openArray[GarageSourceRecord]): ValidationResult =
  var bundle = initGarageBundle("source-check", "Source Check",
                                createdAt = "1970-01-01T00:00:00Z")
  for record in records:
    bundle.sections.add(sectionFromSource(record))
  bundle.validate()
