import std/tables

import ./types
import ./jsonio

proc hasMetadata(values: OrderedTable[string, string]): bool =
  values.len > 0

proc htmlEscape*(value: string): string =
  result = newStringOfCap(value.len)
  for ch in value:
    case ch
    of '&': result.add("&amp;")
    of '<': result.add("&lt;")
    of '>': result.add("&gt;")
    of '"': result.add("&quot;")
    of char(39): result.add("&#39;")
    else: result.add(ch)

proc markdown*(bundle: GarageBundle): string =
  result.add("# " & bundle.title & "\n\n")
  if bundle.summary.len > 0:
    result.add(bundle.summary & "\n\n")
  result.add("- Bundle: `" & bundle.id & "`\n")
  result.add("- Created: `" & bundle.createdAt & "`\n\n")
  if bundle.metadata.hasMetadata:
    result.add("## Metadata\n\n")
    for key, value in bundle.metadata:
      result.add("- `" & key & "`: " & value & "\n")
    result.add("\n")

  if bundle.sections.len > 0:
    for item in bundle.sections:
      result.add("## " & item.title & "\n\n")
      result.add(item.body & "\n\n")
      if item.metadata.hasMetadata:
        result.add("Metadata:\n\n")
        for key, value in item.metadata:
          result.add("- `" & key & "`: " & value & "\n")
        result.add("\n")

  if bundle.artifacts.len > 0:
    result.add("## Artifacts\n\n")
    for item in bundle.artifacts:
      result.add("- `" & item.id & "` " & item.title & " (" & item.mediaType & ")\n")
      if item.metadata.hasMetadata:
        for key, value in item.metadata:
          result.add("  - `" & key & "`: " & value & "\n")

proc html*(bundle: GarageBundle): string =
  result.add("<!doctype html><html><head><meta charset=\"utf-8\">")
  result.add("<title>" & htmlEscape(bundle.title) & "</title></head><body>")
  result.add("<h1>" & htmlEscape(bundle.title) & "</h1>")
  if bundle.summary.len > 0:
    result.add("<p>" & htmlEscape(bundle.summary) & "</p>")
  result.add("<p><strong>Bundle:</strong> <code>" & htmlEscape(bundle.id) & "</code></p>")
  result.add("<p><strong>Created:</strong> <code>" & htmlEscape(bundle.createdAt) & "</code></p>")
  if bundle.metadata.hasMetadata:
    result.add("<section><h2>Metadata</h2><dl>")
    for key, value in bundle.metadata:
      result.add("<dt>" & htmlEscape(key) & "</dt><dd>" & htmlEscape(value) & "</dd>")
    result.add("</dl></section>")
  for item in bundle.sections:
    result.add("<section><h2>" & htmlEscape(item.title) & "</h2>")
    result.add("<pre>" & htmlEscape(item.body) & "</pre>")
    if item.metadata.hasMetadata:
      result.add("<dl>")
      for key, value in item.metadata:
        result.add("<dt>" & htmlEscape(key) & "</dt><dd>" & htmlEscape(value) & "</dd>")
      result.add("</dl>")
    result.add("</section>")
  if bundle.artifacts.len > 0:
    result.add("<section><h2>Artifacts</h2><ul>")
    for item in bundle.artifacts:
      result.add("<li><code>" & htmlEscape(item.id) & "</code> ")
      result.add(htmlEscape(item.title) & " (" & htmlEscape(item.mediaType) & ")")
      if item.metadata.hasMetadata:
        result.add("<dl>")
        for key, value in item.metadata:
          result.add("<dt>" & htmlEscape(key) & "</dt><dd>" & htmlEscape(value) & "</dd>")
        result.add("</dl>")
      result.add("</li>")
    result.add("</ul></section>")
  result.add("</body></html>")

proc render*(bundle: GarageBundle; format: RenderFormat): RenderOutput =
  case format
  of rfMarkdown:
    RenderOutput(format: format, mediaType: "text/markdown", content: markdown(bundle))
  of rfJson:
    RenderOutput(format: format, mediaType: "application/json", content: bundle.toJsonString())
  of rfHtml:
    RenderOutput(format: format, mediaType: "text/html", content: html(bundle))
