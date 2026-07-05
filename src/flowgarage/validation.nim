import std/[sets, strutils]
import ./types

const MaxIdLen* = 160

proc validId(id: string): bool =
  if id.len == 0 or id.len > MaxIdLen:
    return false
  for ch in id:
    if not (ch.isAlphaNumeric or ch in {'-', '_', '.', ':'}):
      return false
  true

proc validate*(bundle: GarageBundle): ValidationResult =
  var errors: seq[string] = @[]
  if not validId(bundle.id):
    errors.add("bundle id must be 1..160 chars and contain only letters, digits, '-', '_', '.', ':'")
  if bundle.title.strip.len == 0:
    errors.add("bundle title must not be empty")
  if bundle.sections.len == 0 and bundle.artifacts.len == 0:
    errors.add("bundle must contain at least one section or artifact")

  var sectionIds = initHashSet[string]()
  for item in bundle.sections:
    if not validId(item.id):
      errors.add("section id is invalid: " & item.id)
    if item.id in sectionIds:
      errors.add("duplicate section id: " & item.id)
    sectionIds.incl(item.id)
    if item.title.strip.len == 0:
      errors.add("section title must not be empty: " & item.id)

  var artifactIds = initHashSet[string]()
  for item in bundle.artifacts:
    if not validId(item.id):
      errors.add("artifact id is invalid: " & item.id)
    if item.id in artifactIds:
      errors.add("duplicate artifact id: " & item.id)
    artifactIds.incl(item.id)
    if item.title.strip.len == 0:
      errors.add("artifact title must not be empty: " & item.id)
    if item.mediaType.strip.len == 0:
      errors.add("artifact mediaType must not be empty: " & item.id)

  ValidationResult(ok: errors.len == 0, errors: errors)
