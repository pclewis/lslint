// TODO: use enums?

#define AGENT_FLYING                0x1 
#define AGENT_ATTACHMENTS           0x2
#define AGENT_SCRIPTED              0x4
#define AGENT_MOUSELOOK             0x8
#define AGENT_SITTING               0x10
#define AGENT_ON_OBJECT             0x20
#define AGENT_AWAY                  0x40
#define AGENT_WALKING               0x80
#define AGENT_IN_AIR                0x100
#define AGENT_TYPING                0x200
#define AGENT_CROUCHING             0x400
#define AGENT_BUSY                  0x800
#define AGENT_ALWAYS_RUN            0x1000

#define LSL_ALL_SIDES               -1

#define LSL_LINK_ROOT                0
#define LSL_LINK_SET                -1
#define LSL_LINK_ALL_OTHERS         -2
#define LSL_LINK_ALL_CHILDREN       -3
#define LSL_LINK_THIS               -4

#define AGENT_CONTROL_AT_POS        0x1
#define AGENT_CONTROL_AT_NEG        0x2
#define AGENT_CONTROL_LEFT_POS      0x4
#define AGENT_CONTROL_LEFT_NEG      0x8
#define AGENT_CONTROL_UP_POS        0x10
#define AGENT_CONTROL_UP_NEG        0x20
#define AGENT_CONTROL_YAW_POS       0x100
#define AGENT_CONTROL_YAW_NEG       0x200
#define AGENT_CONTROL_LBUTTON_DOWN      0x10000000
#define AGENT_CONTROL_ML_LBUTTON_DOWN   0x40000000

// TODO: Figure out why LL used LSCRIPTRunTimePermissionBits[SCRIPT_PERMISSION_xxx] for these
#define SCRIPT_PERMISSION_DEBIT                 0x2
#define SCRIPT_PERMISSION_TAKE_CONTROLS         0x4
#define SCRIPT_PERMISSION_REMAP_CONTROLS        0x8
#define SCRIPT_PERMISSION_TRIGGER_ANIMATION     0x10
#define SCRIPT_PERMISSION_ATTACH                0x20
#define SCRIPT_PERMISSION_RELEASE_OWNERSHIP     0x40
#define SCRIPT_PERMISSION_CHANGE_LINKS          0x80
#define SCRIPT_PERMISSION_CHANGE_JOINTS         0x100
#define SCRIPT_PERMISSION_CHANGE_PERMISSIONS    0x200
#define SCRIPT_PERMISSION_TRACK_CAMERA          0x400

namespace LLAssetType { 
  enum AT {
    AT_NONE           = -1,
    AT_TEXTURE        = 0,
    AT_SOUND          = 1,
    AT_LANDMARK       = 3,
    AT_CLOTHING       = 5,
    AT_OBJECT         = 6,
    AT_NOTECARD       = 7,
    AT_LSL_TEXT       = 10,
    AT_BODYPART       = 13,
    AT_ANIMATION      = 30,
    AT_GESTURE        = 21,
  };
};

#define E_LANDBRUSH_LEVEL           0
#define E_LANDBRUSH_RAISE           1
#define E_LANDBRUSH_LOWER           2
#define E_LANDBRUSH_SMOOTH          3
#define E_LANDBRUSH_NOISE           4
#define E_LANDBRUSH_REVERT          5

#define LLPS_PART_FLAGS             0
#define LLPS_PART_START_COLOR       1
#define LLPS_PART_START_ALPHA       2
#define LLPS_PART_END_COLOR         3
#define LLPS_PART_END_ALPHA         4
#define LLPS_PART_START_SCALE       5
#define LLPS_PART_END_SCALE         6
#define LLPS_PART_MAX_AGE           7

#define LLPS_SRC_ACCEL              8
#define LLPS_SRC_PATTERN            9
#define LLPS_SRC_INNERANGLE         10
#define LLPS_SRC_OUTERANGLE         11
#define LLPS_SRC_TEXTURE            12
#define LLPS_SRC_BURST_RATE         13
#define LLPS_SRC_BURST_PART_COUNT   15
#define LLPS_SRC_BURST_RADIUS       16
#define LLPS_SRC_BURST_SPEED_MIN    17
#define LLPS_SRC_BURST_SPEED_MAX    18
#define LLPS_SRC_MAX_AGE            19
#define LLPS_SRC_TARGET_UUID        20
#define LLPS_SRC_OMEGA              21
#define LLPS_SRC_ANGLE_BEGIN        22
#define LLPS_SRC_ANGLE_END          23

namespace LLPartData {
  enum LLPartData {
    LL_PART_INTERP_COLOR_MASK         = 0x1,
    LL_PART_INTERP_SCALE_MASK         = 0x2,
    LL_PART_BOUNCE_MASK               = 0x4,
    LL_PART_WIND_MASK                 = 0x8,
    LL_PART_FOLLOW_SRC_MASK           = 0x10,
    LL_PART_FOLLOW_VELOCITY_MASK      = 0x20,
    LL_PART_TARGET_POS_MASK           = 0x40,
    LL_PART_TARGET_LINEAR_MASK        = 0x80,
    LL_PART_EMISSIVE_MASK             = 0x100,
  };
};

namespace LLPartSysData {
  enum LLPartSysData {
    LL_PART_SRC_PATTERN_DROP               = 0x1,
    LL_PART_SRC_PATTERN_EXPLODE            = 0x2,
    LL_PART_SRC_PATTERN_ANGLE              = 0x4,
    LL_PART_SRC_PATTERN_ANGLE_CONE         = 0x8,
    LL_PART_SRC_PATTERN_ANGLE_CONE_EMPTY   = 0x10,
  };
};

#define VEHICLE_TYPE_NONE           0
#define VEHICLE_TYPE_SLED           1
#define VEHICLE_TYPE_CAR            2
#define VEHICLE_TYPE_BOAT           3
#define VEHICLE_TYPE_AIRPLANE       4
#define VEHICLE_TYPE_BALLOON        5

#define VEHICLE_LINEAR_FRICTION_TIMESCALE       16
#define VEHICLE_ANGULAR_FRICTION_TIMESCALE      17
#define VEHICLE_LINEAR_MOTOR_DIRECTION          18
#define VEHICLE_ANGULAR_MOTOR_DIRECTION         19
#define VEHICLE_LINEAR_MOTOR_OFFSET             20
#define VEHICLE_HOVER_HEIGHT                    24
#define VEHICLE_HOVER_EFFICIENCY                25
#define VEHICLE_HOVER_TIMESCALE                 26
#define VEHICLE_BUOYANCY                        27
#define VEHICLE_LINEAR_DEFLECTION_EFFICIENCY    28
#define VEHICLE_LINEAR_DEFLECTION_TIMESCALE     29
#define VEHICLE_LINEAR_MOTOR_TIMESCALE          30
#define VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE    31
#define VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY   32
#define VEHICLE_ANGULAR_DEFLECTION_TIMESCALE    33
#define VEHICLE_ANGULAR_MOTOR_TIMESCALE         34
#define VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE   35
#define VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY  36
#define VEHICLE_VERTICAL_ATTRACTION_TIMESCALE   37
#define VEHICLE_BANKING_EFFICIENCY              38
#define VEHICLE_BANKING_MIX                     39
#define VEHICLE_BANKING_TIMESCALE               40
#define VEHICLE_REFERENCE_FRAME                 44

#define VEHICLE_FLAG_NO_DEFLECTION_UP           0x1
#define VEHICLE_FLAG_LIMIT_ROLL_ONLY            0x2
#define VEHICLE_FLAG_HOVER_WATER_ONLY           0x4
#define VEHICLE_FLAG_HOVER_TERRAIN_ONLY         0x8
#define VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT        0x10
#define VEHICLE_FLAG_HOVER_UP_ONLY              0x20
#define VEHICLE_FLAG_LIMIT_MOTOR_UP             0x40
#define VEHICLE_FLAG_MOUSELOOK_STEER            0x80
#define VEHICLE_FLAG_MOUSELOOK_BANK             0x100
#define VEHICLE_FLAG_CAMERA_DECOUPLED           0x200

#define LSL_PRIM_MATERIAL                       2
#define LSL_PRIM_PHYSICS                        3
#define LSL_PRIM_TEMP_ON_REZ                    4
#define LSL_PRIM_PHANTOM                        5
#define LSL_PRIM_POSITION                       6
#define LSL_PRIM_SIZE                           7
#define LSL_PRIM_ROTATION                       8
#define LSL_PRIM_TYPE                           9
#define LSL_PRIM_TEXTURE                        17
#define LSL_PRIM_COLOR                          18
#define LSL_PRIM_BUMP_SHINY                     19
#define LSL_PRIM_FULLBRIGHT                     20

#define LSL_PRIM_TYPE_BOX                       0
#define LSL_PRIM_TYPE_CYLINDER                  1
#define LSL_PRIM_TYPE_PRISM                     2
#define LSL_PRIM_TYPE_SPHERE                    3
#define LSL_PRIM_TYPE_TORUS                     4
#define LSL_PRIM_TYPE_TUBE                      5
#define LSL_PRIM_TYPE_RING                      6

#define LSL_PRIM_HOLE_DEFAULT                   0x00
#define LSL_PRIM_HOLE_CIRCLE                    0x10
#define LSL_PRIM_HOLE_SQUARE                    0x20
#define LSL_PRIM_HOLE_TRIANGLE                  0x30

#define LSL_PRIM_MATERIAL_STONE             0
#define LSL_PRIM_MATERIAL_METAL             1
#define LSL_PRIM_MATERIAL_GLASS             2
#define LSL_PRIM_MATERIAL_WOOD              3
#define LSL_PRIM_MATERIAL_FLESH             4
#define LSL_PRIM_MATERIAL_PLASTIC           5
#define LSL_PRIM_MATERIAL_RUBBER            6
#define LSL_PRIM_MATERIAL_LIGHT             7

#define LSL_PRIM_SHINY_NONE                 0
#define LSL_PRIM_SHINY_LOW                  1
#define LSL_PRIM_SHINY_MEDIUM               2
#define LSL_PRIM_SHINY_HIGH                 3

#define LSL_PRIM_BUMP_NONE                  0
#define LSL_PRIM_BUMP_BRIGHT                1
#define LSL_PRIM_BUMP_DARK                  2
#define LSL_PRIM_BUMP_WOOD                  3
#define LSL_PRIM_BUMP_BARK                  4
#define LSL_PRIM_BUMP_BRICKS                5
#define LSL_PRIM_BUMP_CHECKER               6
#define LSL_PRIM_BUMP_CONCRETE              7
#define LSL_PRIM_BUMP_TILE                  8
#define LSL_PRIM_BUMP_STONE                 9
#define LSL_PRIM_BUMP_DISKS                 10
#define LSL_PRIM_BUMP_GRAVEL                11
#define LSL_PRIM_BUMP_BLOBS                 12
#define LSL_PRIM_BUMP_SIDING                13
#define LSL_PRIM_BUMP_LARGETILE             14
#define LSL_PRIM_BUMP_STUCCO                15
#define LSL_PRIM_BUMP_SUCTION               16
#define LSL_PRIM_BUMP_WEAVE                 17

#define PERM_TRANSFER                   0x2000
#define PERM_MODIFY                     0x4000
#define PERM_COPY                       0x8000
#define PERM_MOVE                       0x80000
#define PERM_ALL                        0x7FFFFFFF

#define PARCEL_MEDIA_COMMAND_STOP           0
#define PARCEL_MEDIA_COMMAND_PAUSE          1
#define PARCEL_MEDIA_COMMAND_PLAY           2
#define PARCEL_MEDIA_COMMAND_LOOP           3
#define PARCEL_MEDIA_COMMAND_TEXTURE        4
#define PARCEL_MEDIA_COMMAND_URL            5
#define PARCEL_MEDIA_COMMAND_TIME           6
#define PARCEL_MEDIA_COMMAND_AGENT          7
#define PARCEL_MEDIA_COMMAND_UNLOAD         8
#define PARCEL_MEDIA_COMMAND_AUTO_ALIGN     9

#define LSL_PAY_HIDE                        -1
#define LSL_PAY_DEFAULT                     -2
