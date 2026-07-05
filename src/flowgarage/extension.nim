import std/[tables, strutils]
import ./types

type
  GaragePluginCapabilityKind* = enum
    gpcRenderer, gpcPublisher, gpcStorage, gpcTransformer, gpcAudit

  GaragePluginCapability* = object
    kind*: GaragePluginCapabilityKind
    name*: string

  GaragePluginManifest* = object
    name*: string
    version*: string
    capabilities*: seq[GaragePluginCapability]

  GaragePublishTarget* = object
    id*: string
    targetType*: string
    settings*: OrderedTable[string, string]

  GaragePublishResult* = object
    targetId*: string
    ok*: bool
    location*: string
    errors*: seq[string]

  GaragePublisher* = proc(output: RenderOutput; target: GaragePublishTarget): GaragePublishResult {.gcsafe.}

  GarageExtensionRegistry* = object
    manifests*: seq[GaragePluginManifest]
    publishers*: OrderedTable[string, GaragePublisher]

proc capability*(kind: GaragePluginCapabilityKind; name: string): GaragePluginCapability =
  GaragePluginCapability(kind: kind, name: name)

proc manifest*(name, version: string;
               capabilities: seq[GaragePluginCapability]): GaragePluginManifest =
  GaragePluginManifest(name: name, version: version, capabilities: capabilities)

proc validate*(manifest: GaragePluginManifest): ValidationResult =
  var errors: seq[string] = @[]
  if manifest.name.strip.len == 0:
    errors.add("plugin name must not be empty")
  if manifest.version.strip.len == 0:
    errors.add("plugin version must not be empty")
  if manifest.capabilities.len == 0:
    errors.add("plugin must declare at least one capability")
  for item in manifest.capabilities:
    if item.name.strip.len == 0:
      errors.add("plugin capability name must not be empty")
  ValidationResult(ok: errors.len == 0, errors: errors)

proc initGarageExtensionRegistry*(): GarageExtensionRegistry =
  GarageExtensionRegistry(manifests: @[], publishers: initOrderedTable[string, GaragePublisher]())

proc addManifest*(registry: var GarageExtensionRegistry; manifest: GaragePluginManifest): ValidationResult =
  result = manifest.validate()
  if result.ok:
    registry.manifests.add(manifest)

proc registerPublisher*(registry: var GarageExtensionRegistry; targetType: string;
                        publisher: GaragePublisher): ValidationResult =
  var errors: seq[string] = @[]
  if targetType.strip.len == 0:
    errors.add("publisher targetType must not be empty")
  if publisher.isNil:
    errors.add("publisher callback must not be nil")
  if errors.len == 0:
    registry.publishers[targetType] = publisher
  ValidationResult(ok: errors.len == 0, errors: errors)

proc publishTarget*(id, targetType: string): GaragePublishTarget =
  GaragePublishTarget(id: id, targetType: targetType, settings: initOrderedTable[string, string]())

proc publish*(registry: GarageExtensionRegistry; output: RenderOutput;
              target: GaragePublishTarget): GaragePublishResult =
  if target.id.strip.len == 0:
    return GaragePublishResult(targetId: target.id, ok: false, errors: @["publish target id must not be empty"])
  if target.targetType notin registry.publishers:
    return GaragePublishResult(targetId: target.id, ok: false, errors: @["missing publisher for target type: " & target.targetType])
  try:
    registry.publishers[target.targetType](output, target)
  except CatchableError as err:
    GaragePublishResult(targetId: target.id, ok: false, errors: @["publisher failed: " & err.msg])
