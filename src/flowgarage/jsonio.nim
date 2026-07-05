import std/[json, tables]
import ./types

proc `%`*(kind: ArtifactKind): JsonNode = %($kind)
proc `%`*(format: RenderFormat): JsonNode = %($format)

proc metadataJson(values: OrderedTable[string, string]): JsonNode =
  result = newJObject()
  for key, value in values:
    result[key] = %value

proc toJson*(item: Artifact): JsonNode =
  %*{
    "id": item.id,
    "title": item.title,
    "kind": $item.kind,
    "mediaType": item.mediaType,
    "content": item.content,
    "metadata": metadataJson(item.metadata)
  }

proc toJson*(item: ReportSection): JsonNode =
  %*{
    "id": item.id,
    "title": item.title,
    "body": item.body,
    "metadata": metadataJson(item.metadata)
  }

proc toJson*(bundle: GarageBundle): JsonNode =
  result = %*{
    "schemaVersion": 1,
    "id": bundle.id,
    "title": bundle.title,
    "summary": bundle.summary,
    "createdAt": bundle.createdAt,
    "metadata": metadataJson(bundle.metadata),
    "sections": [],
    "artifacts": []
  }
  for item in bundle.sections:
    result["sections"].add item.toJson()
  for item in bundle.artifacts:
    result["artifacts"].add item.toJson()

proc toJsonString*(bundle: GarageBundle): string =
  $bundle.toJson()

proc toJsonString*(output: RenderOutput): string =
  $(%*{
    "format": $output.format,
    "mediaType": output.mediaType,
    "content": output.content
  })

proc toJson*(file: GarageOutputFile): JsonNode =
  %*{
    "fileName": file.fileName,
    "format": $file.format,
    "mediaType": file.mediaType,
    "byteSize": file.byteSize
  }

proc toJson*(manifest: GaragePackageManifest): JsonNode =
  result = %*{
    "schemaVersion": manifest.schemaVersion,
    "bundleId": manifest.bundleId,
    "createdAt": manifest.createdAt,
    "files": []
  }
  for file in manifest.files:
    result["files"].add file.toJson()

proc toJsonString*(manifest: GaragePackageManifest): string =
  $manifest.toJson()
