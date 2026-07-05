# FlowGarage

FlowGarage is a small Nim library for assembling workflow artifacts and reports.

It is part of the **FlowBrigade Toolkit**.

## Status

FlowGarage v0.1.0 is focused on deterministic in-process artifact packaging.
Within that scope, it provides:

- artifact and report bundle primitives
- validation for bundle, section, and artifact shape
- source-record helpers for packaging data from other FlowBrigade Toolkit components
- Markdown, JSON, and HTML rendering
- non-throwing build outcomes for FlowCaptain-style integration
- package manifests for rendered outputs
- publisher extension points for optional storage or delivery plugins
- plugin manifests and capability declarations
- examples, tests, design notes, and benchmarks

## v0.1.0 Scope

The first release is intentionally narrow and complete:

- accept an in-memory `GarageBundle`
- validate bundle shape before rendering
- convert neutral source records into report sections
- render a bundle to Markdown, JSON, or HTML
- describe rendered outputs with a small package manifest
- return validation and publisher failures as data
- expose publisher callbacks for external storage or delivery packages
- keep the core free of database, filesystem, cloud, and network dependencies

FlowGarage does not persist files, upload artifacts, run jobs, or analyze metrics in
v0.1.0. Those responsibilities belong to optional plugins or other FlowBrigade
Toolkit components.

## Example

```nim
import flowgarage

var bundle = initGarageBundle("daily-report", "Daily Report", summary = "Workflow output package")
bundle.sections.add(section("summary", "Summary", "All required work completed."))
bundle.artifacts.add(artifact("metrics-json", "Metrics JSON", akDataset,
  "application/json", "{\"ok\":true}", metadata(@[("source", "flowsurveyor")])) )

let outcome = build(initGarageBuildInput(bundle, @[rfMarkdown, rfJson]))
if outcome.ok:
  echo outcome.outputs[0].content
else:
  echo outcome.errors
```

For callers that want stable output names without file-system writes:

```nim
let packed = packageWithManifest(bundle, @[rfMarkdown, rfJson])
if packed.ok:
  echo packed.package.manifest.toJsonString()
```

## Integration

FlowCaptain should use `build(input) -> GarageOutcome` as the integration
boundary. The outcome contains `ok`, `outputs`, and `errors`, so callers can
reject invalid bundles or missing publishers without relying on exception control
flow.

FlowLogbook can provide execution records, FlowSurveyor can provide analysis
results, and FlowGarage can package both into a report bundle through neutral
`GarageSourceRecord` values. FlowDependency and FlowWorkRunner remain upstream
graph and execution components.

## Extension Points

The core package includes small extension points so external packages can add
capabilities without changing the report core:

- plugin manifests describe optional packages and capabilities
- publisher callbacks deliver rendered outputs to a named target type
- publisher errors are converted into data results

Plugin-side responsibilities can include local file writes, SQLite or object
storage persistence, signed audit delivery, and controlled delivery to an
application-specific reporting surface.

## Requirements

FlowGarage only depends on Nim's standard library.

## Development

```bash
nimble test
nimble examples
nimble bench
```

## Intellectual Property Notes

FlowGarage uses general, well-known concepts: report bundles, source records,
artifacts, metadata, format renderers, callback publishers, and
validation-before-output boundaries.

It does not copy workflow engine code, report generator internals, storage
adapter code, or application GUI implementations from other projects.
