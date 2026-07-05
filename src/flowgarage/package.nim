import std/[strutils]

import ./types
import ./builder

proc extension*(format: RenderFormat): string =
  case format
  of rfMarkdown: "md"
  of rfJson: "json"
  of rfHtml: "html"

proc safeFileStem*(value: string): string =
  result = newStringOfCap(value.len)
  var previousDash = false
  for ch in value.toLowerAscii():
    let allowed = ch.isAlphaNumeric or ch in {'-', '_', '.'}
    if allowed:
      result.add(ch)
      previousDash = false
    elif not previousDash:
      result.add('-')
      previousDash = true

  result = result.strip(chars = {'-', '.', '_'})
  if result.len == 0:
    result = "bundle"

proc defaultFileName*(bundleId: string; format: RenderFormat): string =
  safeFileStem(bundleId) & "." & format.extension()

proc manifestFor*(bundle: GarageBundle; outputs: openArray[RenderOutput]):
                  GaragePackageManifest =
  result = GaragePackageManifest(schemaVersion: 1, bundleId: bundle.id,
                                 createdAt: bundle.createdAt, files: @[])
  for output in outputs:
    result.files.add(GarageOutputFile(
      fileName: defaultFileName(bundle.id, output.format),
      format: output.format,
      mediaType: output.mediaType,
      byteSize: output.content.len
    ))

proc package*(bundle: GarageBundle; formats: seq[RenderFormat] = @[rfMarkdown]):
              GarageOutcome =
  build(initGarageBuildInput(bundle, formats))

proc packageWithManifest*(bundle: GarageBundle;
                          formats: seq[RenderFormat] = @[rfMarkdown]):
                          tuple[ok: bool, package: GaragePackage,
                                errors: seq[string]] =
  let outcome = package(bundle, formats)
  if not outcome.ok:
    return (ok: false,
            package: GaragePackage(manifest: GaragePackageManifest(), outputs: @[]),
            errors: outcome.errors)

  (ok: true,
   package: GaragePackage(manifest: manifestFor(bundle, outcome.outputs),
                          outputs: outcome.outputs),
   errors: @[])
