# FlowGarage Design

FlowGarage is the FlowBrigade Toolkit component for packaging outputs. It keeps
report assembly separate from execution, analysis, persistence, and delivery.

## Responsibilities

- represent sections, artifacts, metadata, and bundle identity
- validate bundle shape before output generation
- render deterministic Markdown, JSON, and HTML strings
- convert neutral source records from other components into report sections
- describe rendered outputs with stable file names and sizes
- provide a non-throwing boundary for orchestration tools
- expose plugin points for storage and publishing

## Non-responsibilities

- running tasks
- scheduling work
- storing files or database rows in core
- collecting metrics
- rendering application reporting surfaces

## FlowCaptain Boundary

FlowCaptain should pass a `GarageBundle` to `build`. The result is a
`GarageOutcome`, which carries either rendered outputs or validation errors. This
keeps orchestration code independent from specific storage or report plugins.

FlowCaptain can also pass neutral `GarageSourceRecord` values through
`bundleFromSources`. This keeps FlowGarage useful for FlowLogbook and
FlowSurveyor data without coupling it to those packages.

`packageWithManifest` gives callers stable output names and byte sizes without
performing any file-system, database, or network operation.
