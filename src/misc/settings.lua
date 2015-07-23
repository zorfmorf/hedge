-- Global settings

C_DEBUG = true

-- pathing
C_FOLDER_TILES = 'img/tiles/'
C_MAP_MASTER = 'master/' -- contains all master files
C_MAP_SAVEGAMES = 'savegames/' -- subfolder for savegames
C_MAP_NAME_DEFAULT = 'init.map' -- the map loaded on first startup
C_MAP_CURRENT = 'current/' -- currently played game is here
C_MAP_SUFFIX = '.map' -- file name of maps
C_MAP_VAR = 'var.file' -- contains game variables

-- amount of individual tiles in a block
C_BLOCK_SIZE = 8

-- tile size nxn
C_TILE_SIZE = 32
C_CHAR_SIZE = 64
C_CHAR_MOD_X = 16
C_CHAR_MOD_Y = 38

-- camera tile speed per second/click
C_CAM_SPEED = 4 * C_TILE_SIZE

-- Gui settings
G_TOPBAR_HEIGHT = 30
G_TOPBAR_PAD = 5

-- Key settings
KEY_LEFT = "left"
KEY_RIGHT = "right"
KEY_DOWN = "down"
KEY_UP = "up"

-- entity setting
CHAR_MOVE = 4 -- tile movement per second
CHAR_ANIM = 15 -- animation speed
