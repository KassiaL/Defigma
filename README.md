# Defigma Extension for Defold

Defigma Extension adds advanced linear and radial gradient support to Defold projects using assets exported from the Defigma Figma Plugin.

## Installation

Add this dependency to your game.project file:

```text
https://github.com/yourusername/defigma-extension/archive/master.zip
```

Make sure you've installed the Defigma Figma Plugin and have exported your design to your Defold project.

## Usage

Follow these steps to integrate gradients in your Defold project:

```lua
function init(self)
    -- 1. Import Defigma-generated data
    local menu_defigma_data = require("collections.menu.menu_defigma")

    -- 2. Import Defigma extension module
    local gradient = require("defigma.gradient")

    -- 3. Apply gradients (call in init)
    gradient.apply_all(menu_defigma_data)
end

function update(self, dt)
    -- 4. Update gradient transformations (call in update)
    gradient.apply_all_transform(menu_defigma_data)
end
```

## Advanced Usage

For static elements that don't change position, you can optimize by calling the transform function only when needed:

```lua
function on_position_changed(self)
    local gradient = require("defigma.gradient")
    local menu_defigma_data = require("collections.menu.menu_defigma")
    gradient.apply_all_transform(menu_defigma_data)
end
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
