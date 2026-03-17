/// Recursively merge two dictionaries. Values in `override` take precedence.
/// For nested dictionaries, merging is recursive (deep merge). For all other
/// value types, the override value replaces the base value entirely.
///
/// This is useful for layering a sparse profile configuration on top of a
/// complete base `metadata.toml`, so that only the fields that differ need
/// to be specified in the profile.
///
/// - base (dictionary): The base dictionary (e.g. root metadata).
/// - override (dictionary): The override dictionary whose values win on conflict.
/// -> dictionary
#let deep-merge(base, override) = {
  let result = base
  for (key, value) in override {
    if key in result and type(result.at(key)) == dictionary and type(value) == dictionary {
      result.insert(key, deep-merge(result.at(key), value))
    } else {
      result.insert(key, value)
    }
  }
  result
}
