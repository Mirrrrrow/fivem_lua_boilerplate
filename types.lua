---@class BlipStruct
---@field label string
---@field sprite number
---@field color? number
---@field scale? number

---@class Blip : BlipStruct
---@field coords vector3|{ x: number, y: number, z: number }

---@class PedStruct
---@field model string|number
---@field animation? { name: string }|{ dict: string, name: string, flag: number }

---@class Ped : PedStruct
---@field coords vector4|{ x: number, y: number, z: number, w: number }
