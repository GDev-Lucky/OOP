--!strict

local Class = require("../src/")
local Types = require("../src/types")


type Animal = Types.Class<{

    new: Types.Constructor<(name: string) -> Types.Object>,

    name: Types.Protected<string>,

    getName: () -> string,

    getAnimals: Types.Static<() -> { Types.Object }>

}>

local Animals = {}

local AnimalImpl = Class.new<<Animal>>():declare()

function AnimalImpl.new(name)
    local animal =  AnimalImpl:object({ name = name })
    table.insert(Animals, animal)
    return animal
end

function AnimalImpl:getName()
    return self.name
end

function AnimalImpl.getAnimals()
    return Animals
end

local Animal = AnimalImpl:export()
local animal = AnimalImpl.new("foo")

type Human = Types.Class<{


}>
