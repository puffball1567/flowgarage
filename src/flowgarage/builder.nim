import ./types
import ./validation
import ./renderers

type
  GarageBuildInput* = object
    bundle*: GarageBundle
    formats*: seq[RenderFormat]

proc initGarageBuildInput*(bundle: GarageBundle;
                           formats: seq[RenderFormat] = @[rfMarkdown]): GarageBuildInput =
  GarageBuildInput(bundle: bundle, formats: formats)

proc build*(input: GarageBuildInput): GarageOutcome =
  let checked = input.bundle.validate()
  if not checked.ok:
    return failure(checked.errors)
  if input.formats.len == 0:
    return failure(@["at least one render format is required"])

  var outputs: seq[RenderOutput] = @[]
  for format in input.formats:
    outputs.add(input.bundle.render(format))
  success(outputs)
