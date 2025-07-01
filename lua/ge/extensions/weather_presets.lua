local presets = {
  cloudy_evening = {
    CloudLayer = {
      coverage = 1
    },
    ForestWindEmitter = {
      strength = 1.5
    },
    LevelInfo = {
      fogDensity = 0
    },
    Precipitation = {
      numDrops = 0
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.427451, 0.427451, 0.427451, 1 },
      fogScale = { 0.756863, 0.760784, 0.760784, 1 },
      shadowSoftness = 1,
      sunScale = { 0.686275, 0.686275, 0.686275, 1 }
    }
  },
  foggy_morning = {
    CloudLayer = {
      coverage = 1
    },
    ForestWindEmitter = {
      strength = 1.5
    },
    LevelInfo = {
      fogDensity = 0.02
    },
    Precipitation = {
      numDrops = 0
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.427451, 0.427451, 0.427451, 1 },
      fogScale = { 0.756863, 0.760784, 0.760784, 1 },
      shadowSoftness = 1,
      sunScale = { 0.686275, 0.686275, 0.686275, 1 }
    }
  },
  foggy_night = {
    CloudLayer = {
      coverage = 0.1
    },
    ForestWindEmitter = {
      strength = 1.5
    },
    LevelInfo = {
      fogDensity = 0.02
    },
    Precipitation = {
      numDrops = 0
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.427451, 0.427451, 0.427451, 1 },
      fogScale = { 0.756863, 0.760784, 0.760784, 1 },
      shadowSoftness = 1,
      sunScale = { 0.686275, 0.686275, 0.686275, 1 }
    }
  },
  rainy = {
    CloudLayer = {
      coverage = 1
    },
    ForestWindEmitter = {
      strength = 1.5
    },
    LevelInfo = {
      fogDensity = 0.002
    },
    Precipitation = {
      numDrops = 200
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.427451, 0.427451, 0.427451, 1 },
      fogScale = { 0.756863, 0.760784, 0.760784, 1 },
      shadowSoftness = 1,
      sunScale = { 0.686275, 0.686275, 0.686275, 1 }
    },
    Sound = { name = "amb_rain_medium", duration = 8 }
  },
  sunny = {
    CloudLayer = {
      coverage = 0
    },
    ForestWindEmitter = {
      strength = 0.5
    },
    LevelInfo = {
      fogDensity = 0
    },
    Precipitation = {
      numDrops = 0
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.439216, 0.580392, 0.72549, 1 },
      fogScale = { 0.580392, 0.792157, 0.996078, 1 },
      shadowSoftness = 1,
      sunScale = { 0.996078, 0.901961, 0.831373, 1 }
    }
  },
  sunny_evening = {
    CloudLayer = {
      coverage = 0
    },
    ForestWindEmitter = {
      strength = 0.5
    },
    LevelInfo = {
      fogDensity = 0
    },
    Precipitation = {
      numDrops = 0
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.439216, 0.580392, 0.72549, 1 },
      fogScale = { 0.580392, 0.792157, 0.996078, 1 },
      shadowSoftness = 1,
      sunScale = { 0.996078, 0.901961, 0.831373, 1 }
    }
  },
  sunny_noon = {
    CloudLayer = {
      coverage = 0
    },
    ForestWindEmitter = {
      strength = 0.5
    },
    LevelInfo = {
      fogDensity = 0
    },
    Precipitation = {
      numDrops = 0
    },
    ScatterSky = {
      ambientScale = { 0.545098, 0.545098, 0.54902, 1 },
      colorize = { 0.439216, 0.580392, 0.72549, 1 },
      fogScale = { 0.580392, 0.792157, 0.996078, 1 },
      shadowSoftness = 1,
      sunScale = { 0.996078, 0.901961, 0.831373, 1 }
    }
  }
}

return presets