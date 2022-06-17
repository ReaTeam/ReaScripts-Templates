-- Use ReaLearn: Import from clipboard

local source = {
    kind = "RealearnParameter",
    parameter_index = 0,
}

local configs = {
    { name = "EQ1" },
    { name = "EQ2" },
    { name = "EQ3" },
    { name = "EQ4" },
}

local mappings = {}

for i, config in ipairs(configs) do
    local mapping = {
        name = config.name,
        feedback_enabled = false,
        source = source,
        glue = {
            control_transformation = "y = x >= " .. (i - 1)/ #configs .. " && x <= " .. i / #configs .. " ? 0 : 1"
        },
        target = {
            kind = "FxParameterValue",
            parameter = {
                address = "ByName",
                fx = {
                    address = "ByName",
                    chain = {
                        address = "Track",
                        track = {
                            address = "This",
                        },
                    },
                    name = config.name,
                },
                name = "Bypass",
            },
        },
    }
    table.insert(mappings, mapping)
end

return {
    kind = "MainCompartment",
    value = {
        parameters = {
            {
                index = 0,
                name = "Active EQ",
                value_count = 4,
                value_labels = {
                    "EQ1",
                    "EQ2",
                    "EQ3",
                    "EQ4",
                },
            }
        },
        mappings = mappings,
    },
}
