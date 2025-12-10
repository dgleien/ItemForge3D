## How to Register Items

Use the function:

```lua
itemforge3d.register(modname, name, def)
```

- `modname`: The mod's namespace (e.g. `"mymod"`).  
- `name`: The item’s unique name (e.g. `"sword"`).  
- `def`: A table with item definition and optional 3D model info.  

> The final registered item will be named as `modname:name`, for example: `"mymod:sword"`.

---

## Supported Item Types

You can register **three kinds of items**:

1. **Tools** → `type = "tool"`  
   - Pickaxes, swords, axes, etc.  
   - Registered with `core.register_tool`.

2. **Nodes** → `type = "node"`  
   - Blocks you can place in the world.  
   - Registered with `core.register_node`.

3. **Craftitems** → `type = "craftitem"`  
   - Misc items (food, gems, scrolls).  
   - Registered with `core.register_craftitem`.

---

## Definition Fields

Here’s what you can put inside `def`:

| Field             | Type    | Description |
|-------------------|---------|-------------|
| `type`            | string  | `"tool"`, `"node"`, or `"craftitem"` |
| `description`     | string  | Text shown in inventory |
| `inventory_image` | string  | Icon texture for inventory |
| `recipe`          | table   | Shaped craft recipe (shorthand) |
| `craft`           | table   | Full craft definition (shapeless, cooking, fuel, etc.) |
| `attach_model`    | table   | Defines the 3D model to attach when wielded |

---

## attach_model Fields

Inside `attach_model`, you can define:

| Field        | Type     | Description |
|--------------|----------|-------------|
| `properties` | table    | Entity properties (mesh, textures, size) |
| `attach`     | table    | Where/how to attach to player |
| `update`     | function | Optional per-frame logic (animations, effects) |

### Example `properties`
```lua
properties = {
    mesh = "sword.glb",
    textures = {"sword_texture.png"},
    visual_size = {x=1, y=1}
}
```

### Example `attach`
```lua
attach = {
    bone = "Arm_Right",
    position = {x=0, y=5, z=0},
    rotation = {x=0, y=90, z=0},
    forced_visible = false
}
```

### Example `update`
```lua
update = function(ent, player)
    if player:get_player_control().dig then
        ent:set_animation({x=0,y=20}, 15, 0) -- swing animation
    end
end
```

---

## Full Examples

### 1. Tool with 3D Model (shaped recipe shorthand)
```lua
itemforge3d.register("mymod", "sword", {
    type = "tool",
    description = "Forged Sword",
    inventory_image = "sword.png",
    recipe = {
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"", "default:stick", ""},
        {"", "default:stick", ""}
    },
    attach_model = {
        properties = {
            mesh = "sword.glb",
            textures = {"sword_texture.png"},
            visual_size = {x=1, y=1}
        },
        attach = {
            bone = "Arm_Right",
            position = {x=0, y=5, z=0},
            rotation = {x=0, y=90, z=0}
        }
    }
})
```

---

### 2. Node with 3D Model (full craft passthrough)
```lua
itemforge3d.register("mymod", "magic_block", {
    type = "node",
    description = "Magic Block",
    inventory_image = "magic_block.png",
    craft = {
        output = "mymod:magic_block",
        recipe = {
            {"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
            {"default:mese_crystal", "default:diamond", "default:mese_crystal"},
            {"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"}
        }
    },
    attach_model = {
        properties = {
            mesh = "block.glb",
            textures = {"magic_block_texture.png"},
            visual_size = {x=0.5, y=0.5}
        },
        attach = {
            bone = "Arm_Right",
            position = {x=0, y=4, z=0},
            rotation = {x=0, y=0, z=0}
        }
    }
})
```

---

### 3. Craftitem with Dynamic Effect
```lua
itemforge3d.register("mymod", "lantern", {
    type = "craftitem",
    description = "Lantern",
    inventory_image = "lantern.png",
    recipe = {
        {"default:steel_ingot", "default:torch", "default:steel_ingot"},
        {"", "default:glass", ""}
    },
    attach_model = {
        properties = {
            mesh = "lantern.glb",
            textures = {"lantern_texture.png"},
            visual_size = {x=0.7, y=0.7}
        },
        attach = {
            bone = "Arm_Right",
            position = {x=0, y=6, z=0},
            rotation = {x=0, y=0, z=0}
        },
        update = function(ent, player)
            -- Emit particles when sneaking
            if player:get_player_control().sneak then
                core.add_particlespawner({
                    amount = 5,
                    time = 0.1,
                    minpos = player:get_pos(),
                    maxpos = player:get_pos(),
                    texture = "light_particle.png"
                })
            end
        end
    }
})
```

---

## Summary

- Use `itemforge3d.register(modname, name, def)` for **tools, nodes, or craftitems**.  
- Add `attach_model` to show a **3D mesh** when wielded.  
- Use `update` for **animations, effects, or dynamic behavior**.  
- Recipes can be declared either with `recipe` (shaped shorthand) or `craft` (full passthrough).  
- Fallback: if no `attach_model`, the mod shows a default cube.  
- Duplicate registrations log a warning.  
- The registered item will be named `modname:name`.  
