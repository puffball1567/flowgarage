import std/[tables, times]

type
  ArtifactKind* = enum
    akReport, akDataset, akLog, akSnapshot, akOther

  RenderFormat* = enum
    rfMarkdown, rfJson, rfHtml

  Artifact* = object
    id*: string
    title*: string
    kind*: ArtifactKind
    mediaType*: string
    content*: string
    metadata*: OrderedTable[string, string]

  ReportSection* = object
    id*: string
    title*: string
    body*: string
    metadata*: OrderedTable[string, string]

  GarageBundle* = object
    id*: string
    title*: string
    summary*: string
    createdAt*: string
    sections*: seq[ReportSection]
    artifacts*: seq[Artifact]
    metadata*: OrderedTable[string, string]

  ValidationResult* = object
    ok*: bool
    errors*: seq[string]

  RenderOutput* = object
    format*: RenderFormat
    mediaType*: string
    content*: string

  GarageSourceKind* = enum
    gskLogbook, gskSurveyor, gskRunner, gskDependency, gskCustom

  GarageSourceRecord* = object
    id*: string
    title*: string
    kind*: GarageSourceKind
    summary*: string
    body*: string
    severity*: string
    metadata*: OrderedTable[string, string]

  GarageOutcome* = object
    ok*: bool
    outputs*: seq[RenderOutput]
    errors*: seq[string]

  GarageOutputFile* = object
    fileName*: string
    format*: RenderFormat
    mediaType*: string
    byteSize*: int

  GaragePackageManifest* = object
    schemaVersion*: int
    bundleId*: string
    createdAt*: string
    files*: seq[GarageOutputFile]

  GaragePackage* = object
    manifest*: GaragePackageManifest
    outputs*: seq[RenderOutput]

proc metadata*(pairs: openArray[(string, string)]): OrderedTable[string, string] =
  result = initOrderedTable[string, string]()
  for pair in pairs:
    result[pair[0]] = pair[1]

proc nowIso*(): string =
  now().utc.format("yyyy-MM-dd'T'HH:mm:ss'Z'")

proc artifact*(id, title: string; kind = akReport; mediaType = "text/plain";
               content = ""): Artifact =
  Artifact(id: id, title: title, kind: kind, mediaType: mediaType,
           content: content, metadata: initOrderedTable[string, string]())

proc artifact*(id, title: string; kind: ArtifactKind; mediaType, content: string;
               metadata: OrderedTable[string, string]): Artifact =
  Artifact(id: id, title: title, kind: kind, mediaType: mediaType,
           content: content, metadata: metadata)

proc section*(id, title, body: string): ReportSection =
  ReportSection(id: id, title: title, body: body,
                metadata: initOrderedTable[string, string]())

proc section*(id, title, body: string;
              metadata: OrderedTable[string, string]): ReportSection =
  ReportSection(id: id, title: title, body: body, metadata: metadata)

proc sourceRecord*(id, title: string; kind = gskCustom; summary = "";
                   body = ""; severity = "info"): GarageSourceRecord =
  GarageSourceRecord(id: id, title: title, kind: kind, summary: summary,
                     body: body, severity: severity,
                     metadata: initOrderedTable[string, string]())

proc sourceRecord*(id, title: string; kind: GarageSourceKind; summary, body,
                   severity: string; metadata: OrderedTable[string, string]):
                   GarageSourceRecord =
  GarageSourceRecord(id: id, title: title, kind: kind, summary: summary,
                     body: body, severity: severity, metadata: metadata)

proc initGarageBundle*(id, title: string; summary = "";
                       createdAt = ""): GarageBundle =
  let stamp = if createdAt.len == 0: nowIso() else: createdAt
  GarageBundle(id: id, title: title, summary: summary, createdAt: stamp,
               sections: @[], artifacts: @[],
               metadata: initOrderedTable[string, string]())

proc success*(outputs: seq[RenderOutput]): GarageOutcome =
  GarageOutcome(ok: true, outputs: outputs, errors: @[])

proc failure*(errors: seq[string]): GarageOutcome =
  GarageOutcome(ok: false, outputs: @[], errors: errors)
