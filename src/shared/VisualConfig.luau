-- Pilha visual SAUDADE.EXE (diagramas_visual_v2.html + GDD §7)

local VisualConfig = {}

VisualConfig.FEAR_LERP_SECONDS = 0.4

VisualConfig.FEAR_DEFAULT = 30

VisualConfig.APPEARANCES = {
	cooldownSeconds = 45,
	maxSimultaneous = 2,
	durationSeconds = 12,
	lookSecondsToDismiss = 1.5,
	fearOnAppear = 8,
}

VisualConfig.HUD = {
	recStamp = "03/11/2012",
	recTime = "22:14",
}

VisualConfig.VHS = {
	noiseFps = 12,
	glitchIntervalMin = 5,
	glitchIntervalMax = 20,
	scanlineBaseTransparency = 0.5,
	scanlineFearBoost = 0.15,
	noiseBaseTransparency = 0.82,
	noiseFearBoost = 0.17,
	vignetteBase = 0.55,
	vignetteFearBoost = 0.35,
	chromaBasePx = 1,
	chromaFearPx = 3,
	saturationBase = -0.35,
	saturationFear = -0.35,
}

function VisualConfig.lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function VisualConfig.fearNorm(fear: number): number
	return math.clamp(fear / 100, 0, 1)
end

function VisualConfig.blurMaxForFear(fear: number): number
	local f = VisualConfig.fearNorm(fear)
	return VisualConfig.lerp(4, 10, f)
end

return VisualConfig
