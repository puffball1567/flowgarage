import std/unittest
import flowgarage

suite "extension":
  test "validates plugin manifests":
    let checked = manifest("flowgarage_local", "0.1.0", @[capability(gpcPublisher, "local")]).validate()
    check checked.ok

  test "rejects invalid plugin manifests":
    let checked = manifest("", "", @[]).validate()
    check not checked.ok
    check checked.errors.len == 3

  test "publishes through registered callback":
    var registry = initGarageExtensionRegistry()
    let registered = registry.registerPublisher("memory", proc(output: RenderOutput; target: GaragePublishTarget): GaragePublishResult =
      GaragePublishResult(targetId: target.id, ok: true, location: "memory://" & target.id, errors: @[])
    )
    check registered.ok
    let output = RenderOutput(format: rfMarkdown, mediaType: "text/markdown", content: "# ok")
    let result = registry.publish(output, publishTarget("target", "memory"))
    check result.ok
    check result.location == "memory://target"

  test "returns missing publisher and callback failures as data":
    var registry = initGarageExtensionRegistry()
    let output = RenderOutput(format: rfMarkdown, mediaType: "text/markdown", content: "# ok")
    check not registry.publish(output, publishTarget("target", "missing")).ok
    discard registry.registerPublisher("bad", proc(output: RenderOutput; target: GaragePublishTarget): GaragePublishResult =
      raise newException(ValueError, "boom")
    )
    let failed = registry.publish(output, publishTarget("target", "bad"))
    check not failed.ok
    check failed.errors.len == 1

  test "rejects invalid publisher registration":
    var registry = initGarageExtensionRegistry()
    let checked = registry.registerPublisher("", nil)
    check not checked.ok
    check checked.errors.len == 2
