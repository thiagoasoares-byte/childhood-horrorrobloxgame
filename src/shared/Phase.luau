--!strict
export type Block = "ida" | "turno" | "volta" | "fim"

export type State = {
	night: number,
	block: Block,
}

local BLOCKS: { [string]: boolean } = { ida = true, turno = true, volta = true, fim = true }

local Phase = {}

function Phase.isBlock(value: any): boolean
	return type(value) == "string" and BLOCKS[value] == true
end

return Phase
