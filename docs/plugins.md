# FlowGarage Plugins

FlowGarage core exposes plugin manifests and publisher callbacks. The core does
not write files, call cloud APIs, or open network sockets.

Useful plugin categories include:

- local filesystem publisher
- SQLite or object storage publisher
- signed audit bundle exporter
- FlowCaptain or Shelfer integration package
- controlled delivery into a product-specific reporting surface

Publisher callbacks receive a `RenderOutput` and a `GaragePublishTarget`. They
return `GaragePublishResult`, so plugin failures can be reported as data.
