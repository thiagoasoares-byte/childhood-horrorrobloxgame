--!strict

export type FearSample = {
	saturation: number,
	scanlines: number,
	noise: number,
	vignette: number,
	aberration: number,
	glitchInterval: number,
}

export type QualityName = "high" | "medium" | "low"

export type QualityProfile = {
	blurMax: number,
	noiseFps: number,
	aberration: "animated" | "static" | "off",
	posterize: boolean,
}

local VisualConfig = {}

VisualConfig.FEAR_MIN = 0
VisualConfig.FEAR_MAX = 100

-- Anchors sit at the middle of each GDD 9.5 band, so the value is exact at the centre and blends toward the neighbour.
local ANCHORS: { { at: number, sample: FearSample } } = {
	{
		at = 12.5,
		sample = {
			saturation = -0.15,
			scanlines = 0.10,
			noise = 0.06,
			vignette = 0.35,
			aberration = 0,
			glitchInterval = 60,
		},
	},
	{
		at = 38,
		sample = {
			saturation = -0.28,
			scanlines = 0.15,
			noise = 0.11,
			vignette = 0.50,
			aberration = 1,
			glitchInterval = 35,
		},
	},
	{
		at = 63,
		sample = {
			saturation = -0.40,
			scanlines = 0.21,
			noise = 0.16,
			vignette = 0.65,
			aberration = 2,
			glitchInterval = 18,
		},
	},
	{
		at = 88,
		sample = {
			saturation = -0.55,
			scanlines = 0.28,
			noise = 0.22,
			vignette = 0.80,
			aberration = 3,
			glitchInterval = 8,
		},
	},
}

-- blurMax values are provisional until measured on the P5 reference phone.
local QUALITY: { [QualityName]: QualityProfile } = {
	high = { blurMax = 24, noiseFps = 12, aberration = "animated", posterize = true },
	medium = { blurMax = 14, noiseFps = 6, aberration = "static", posterize = true },
	low = { blurMax = 6, noiseFps = 0, aberration = "off", posterize = false },
}
VisualConfig.QUALITY = QUALITY

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function VisualConfig.sampleFear(fear: number): FearSample
	local first, last = ANCHORS[1], ANCHORS[#ANCHORS]
	if fear <= first.at then
		return first.sample
	end
	for i = 2, #ANCHORS do
		local hi = ANCHORS[i]
		if fear <= hi.at then
			local lo = ANCHORS[i - 1]
			local t = (fear - lo.at) / (hi.at - lo.at)
			return {
				saturation = lerp(lo.sample.saturation, hi.sample.saturation, t),
				scanlines = lerp(lo.sample.scanlines, hi.sample.scanlines, t),
				noise = lerp(lo.sample.noise, hi.sample.noise, t),
				vignette = lerp(lo.sample.vignette, hi.sample.vignette, t),
				aberration = lerp(lo.sample.aberration, hi.sample.aberration, t),
				glitchInterval = lerp(lo.sample.glitchInterval, hi.sample.glitchInterval, t),
			}
		end
	end
	return last.sample
end

return VisualConfig
