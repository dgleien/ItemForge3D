itemforge3d = {
    defs = {},
    last_wield = {},
    player_entities = {},
    step_accum = 0,
}

function itemforge3d.register(modname, name, def)
    local full_name = modname .. ":" .. name

    if def.type == "tool" then
        core.register_tool(full_name, def)
    elseif def.type == "node" then
        core.register_node(full_name, def)
    elseif def.type == "craftitem" then
        core.register_craftitem(full_name, def)
    else
        core.log("warning", "[itemforge3d] Unknown type for " .. full_name)
    end

    if def.recipe then
        core.register_craft({
            output = full_name,
            recipe = def.recipe
        })
    end

    itemforge3d.defs[full_name] = def
end

core.register_entity("itemforge3d:wield_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "blank.glb",
        textures = {},
        visual_size = {x=1, y=1},
        pointable = false,
        physical = false,
        collide_with_objects = false,
    },
})

local function attach_model(player, def)
    local pname = player:get_player_name()
    local ent = core.add_entity(player:get_pos(), "itemforge3d:wield_entity")
    if not ent then return end

    if def.attach_model and def.attach_model.properties then
        ent:set_properties(def.attach_model.properties)
    else
        ent:set_properties({
            mesh = "blank.glb",
            textures = {def.inventory_image or "blank.png"},
            visual_size = {x=0.5, y=0.5}
        })
    end

    local a = def.attach_model and def.attach_model.attach or {}
    ent:set_attach(player,
        a.bone or "Arm_Right",
        a.position or {x=0,y=5,z=0},
        a.rotation or {x=0,y=90,z=0},
        a.forced_visible or false
    )

    itemforge3d.player_entities[pname] = ent
end

core.register_on_leaveplayer(function(player)
    local pname = player:get_player_name()
    if itemforge3d.player_entities[pname] then
        itemforge3d.player_entities[pname]:remove()
        itemforge3d.player_entities[pname] = nil
    end
    itemforge3d.last_wield[pname] = nil
end)

core.register_on_dieplayer(function(player)
    local pname = player:get_player_name()
    if itemforge3d.player_entities[pname] then
        itemforge3d.player_entities[pname]:remove()
        itemforge3d.player_entities[pname] = nil
    end
end)

core.register_globalstep(function(dtime)
    itemforge3d.step_accum = itemforge3d.step_accum + dtime
    if itemforge3d.step_accum < 0.15 then return end
    itemforge3d.step_accum = 0

    for _, player in ipairs(core.get_connected_players()) do
        local pname = player:get_player_name()
        local wield = player:get_wielded_item():get_name()

        if itemforge3d.last_wield[pname] ~= wield then
            itemforge3d.last_wield[pname] = wield

            if itemforge3d.player_entities[pname] then
                itemforge3d.player_entities[pname]:remove()
                itemforge3d.player_entities[pname] = nil
            end

            local def = itemforge3d.defs[wield]
            if def then
                attach_model(player, def)
            end
        end

        local ent = itemforge3d.player_entities[pname]
        if ent and def and def.attach_model and def.attach_model.update then
            def.attach_model.update(ent, player)
        end
    end
end)
