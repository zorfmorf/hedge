-- Global settings

C_DEBUG = true

-- pathing
C_FOLDER_TILES = 'img/tiles/'
C_MAP_MASTER = 'master/' -- contains all master files
C_MAP_SAVEGAMES = 'savegames/' -- subfolder for savegames
C_MAP_NAME_DEFAULT = 'init.map'
C_MAP_CURRENT = 'current/' -- currently played game is here
C_MAP_SUFFIX = '.map'

-- amount of individual tiles in a block
C_BLOCK_SIZE = 8

-- tile size nxn
C_TILE_SIZE = 32

-- camera tile speed per second/click
C_CAM_SPEED = 4 * C_TILE_SIZE


-- Gui settings
G_TOPBAR_HEIGHT = 30
G_TOPBAR_PAD = 5

COLOR = {
    white = {255, 255, 255},
    black = {0, 0, 0},
    selected = {49,181,64}
}