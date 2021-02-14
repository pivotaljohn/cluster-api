load("@ytt:data", "data"); d = data.values
load("@ytt:assert", "assert")

unspecified = []
d.service.name or unspecified.append("service.name")
d.service.namespace or unspecified.append("service.namespace")

if len(unspecified) > 0:
  unspecified_data_values = "the following data values need to be specified: {}.".format(", ".join(unspecified))
  assert.fail(unspecified_data_values)
end

