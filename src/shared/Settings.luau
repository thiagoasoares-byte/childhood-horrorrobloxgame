--!strict
export type Quality = "Auto" | "High" | "Medium" | "Low"
export type BlurMode = "Normal" | "Reduced" | "Off"

export type Settings = {
	quality: Quality,
	blur: BlurMode,
	frame: boolean,
	scanlines: boolean,
	colorGrade: boolean,
	reduceMotion: boolean,
	vignette: number,
	brightness: number,
}

local Settings = {}

Settings.QUALITIES = { "Auto", "High", "Medium", "Low" } :: { Quality }
Settings.BLUR_MODES = { "Normal", "Reduced", "Off" } :: { BlurMode }

function Settings.defaults(): Settings
	return {
		quality = "Auto",
		blur = "Normal",
		frame = true,
		scanlines = true,
		colorGrade = true,
		reduceMotion = false,
		vignette = 1,
		brightness = 0,
	}
end

local function pick<T>(list: { T }, value: any): T?
	if table.find(list, value) then
		return value
	end
	return nil
end

local function unit(value: any): number?
	if typeof(value) ~= "number" or value ~= value then
		return nil
	end
	return math.clamp(value, 0, 1)
end

-- the server calls this on whatever the client sent; nil means reject
function Settings.sanitize(raw: any): Settings?
	if typeof(raw) ~= "table" then
		return nil
	end
	local quality = pick(Settings.QUALITIES, raw.quality)
	local blur = pick(Settings.BLUR_MODES, raw.blur)
	local vignette = unit(raw.vignette)
	local brightness = unit(raw.brightness)
	if
		quality == nil
		or blur == nil
		or vignette == nil
		or brightness == nil
		or typeof(raw.frame) ~= "boolean"
		or typeof(raw.scanlines) ~= "boolean"
		or typeof(raw.colorGrade) ~= "boolean"
		or typeof(raw.reduceMotion) ~= "boolean"
	then
		return nil
	end
	return {
		quality = quality,
		blur = blur,
		frame = raw.frame,
		scanlines = raw.scanlines,
		colorGrade = raw.colorGrade,
		reduceMotion = raw.reduceMotion,
		vignette = vignette,
		brightness = brightness,
	}
end

return Settings
