%dw 2.0
input payload application/json
output application/json
ns example http://example.org/schema
type Item = { name: String, age?: Number }
type Items = Array<Item>
type Label = String | Null
type Identified = Item & { id: Number }
fun label(item: Item, fallback: String = "unknown"): String =
  item.name default fallback
var values = [1, 2] << 3
---
do {
  var first = values[0]
  ---
  {
    name: label(payload),
    range: 1 to 3,
    prepended: 0 >> values,
    qualified: payload.example#name,
    present: payload.name?,
    selected: values[?($ > 1)],
    result: first match {
      case 1 -> "first"
      case value is Number if value > 1 -> "later"
      case text matches /[a-z]+/ -> text
      else -> "unknown"
    },
    message: """Hello $(payload.name)
Next line""",
    (extra: true) if (first == 1),
    (payload)
  }
}
