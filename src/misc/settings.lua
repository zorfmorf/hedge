-- Global settings

C_DEBUG = false

-- pathing
C_FOLDER_TILES = 'img/tiles/'
C_MAP_MASTER = 'master/' -- contains all master files
C_MAP_SAVEGAMES = 'savegames/' -- subfolder for savegames
C_MAP_SAVEGAME_DEFAULT = 'auto'
C_MAP_NAME_DEFAULT = 'farm.map' -- the map loaded on first startup
C_MAP_CURRENT = 'current/' -- currently played game is here
C_MAP_SUFFIX = '.map' -- file name of maps
C_MAP_VAR = 'var.file' -- contains game variables
C_MAP_GAME_ATLAS = 'atlas.png' -- name of the generated game atlas
C_MAP_GAME_ATLAS_MAPPING = 'atlas.file' -- maping for atlas
C_MAP_PLANTS = 'plants.file' -- contains all plants
C_MAP_SETTINGS = 'settings.file' --contains video settings
C_MAP_INVENTORY = 'inventory.file' --contains video settings
C_FILE_SUFFIX = '.file'

-- amount of individual tiles in a block
C_BLOCK_SIZE = 8

-- tile size nxn
C_TILE_SIZE = 32
C_CHAR_SIZE = 64
C_INVENTORY_SIZE = 64
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
KEY_SPRINT = "lshift"
KEY_RETURN = "return"
KEY_NEXT_TOOL = "e"
KEY_PREVIOUS_TOOL = "q"
KEY_CYCLE_SEED = "w"
KEY_USE = "return"
KEY_EXIT = "escape"
KEY_HELP = "f1"
KEY_INVENTORY = "i"
KEY_EDITOR_DELETE = "d"

-- entity setting
CHAR_MOVE = 4 -- tile movement per second
CHAR_ANIM = 17 -- animation speed
CHAR_ANIM_WORK = 8 -- work animation speed
CHAR_MOVE_DIRCHANGE_THRESHOLD = 0.13 -- time buffer when changing direction in case it's just a direction change

-- npc settings
NPC_STROLL_CD = 4

-- time settings
C_WORK_UNIT = 10 -- amount of minutes one work unit takes
C_TRANSITION_TIME = 60 -- time that elapses for costly map transitions

-- dialog settings
C_DIALOG_LINE_TIME = 1 -- time it takes until a dialog line is displayed
C_DIALOG_LINE_BLINK = 2 -- blink speed of triangle at line end

-- transition settings
C_TRANS_TIME = 0.6 -- in seconds

-- item pickup floating texts
C_FLOAT_SPEED = 0.6
C_FLOAT_COOLDOWN = 0.6
C_FLOAT_TIME = 1.5

-- intro
C_LINE_TIME = 4
