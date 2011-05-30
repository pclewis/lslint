%option bison-locations
%option bison-bridge
%option reentrant
%option noyywrap
%option nounput

%{
#include <stdlib.h>
#include "lslmini.hh"
#include "lslmini.tab.h"
#include "llconstants.hh"

#ifdef WIN32
#include <io.h>
#define isatty _isatty
#endif /* WIN32 */

#define LLOC_RESET()    yylloc->first_column = yylloc->first_line = yylloc->last_column = yylloc->last_line = 1;
#define LLOC_LINES(num) yylloc->last_column = 1; yylloc->last_line += (num);
#define LLOC_STEP()     yylloc->first_column = yylloc->last_column; yylloc->first_line = yylloc->last_line;
#define YY_USER_ACTION  yylloc->last_column += yyleng;
#define YY_USER_INIT    LLOC_RESET()

char *parse_string(char *input);

%}


D           [0-9]
BD			[-]?[0-9]
N			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F)

 /* exclusive state to eat comments of any length without overflowing any buffers */
%x COMMENT

%%
%{
  /* HACK */
  yylloc = yylloc_param;
  LLOC_STEP();
%}
"//"                { BEGIN COMMENT; }
<COMMENT>"$[E"{D}{5}"]" {
    ErrorCode e = (ErrorCode) strtoul( yytext+3, NULL, 10 );
    LOG( LOG_INFO, yylloc, "Adding assertion for E%d.", (int)e );
    Logger::get()->add_assertion( yylloc->first_line, e );
}
<COMMENT>.          { /* eat comments */ }
<COMMENT>\n         { BEGIN 0; LLOC_LINES(1); LLOC_STEP(); } 

"integer"			{ return(INTEGER); }
"float"				{ return(FLOAT_TYPE); }
"string"			{ return(STRING); }
"key"				{ return(LLKEY); }
"vector"			{ return(VECTOR); }
"quaternion"		{ return(QUATERNION); }
"rotation"			{ return(QUATERNION); }
"list"				{ return(LIST); }

"default"			{ yylval->sval = new char[strlen(yytext) + 1]; strcpy(yylval->sval, yytext); return(STATE_DEFAULT); }
"state"				{ return(STATE); }
"event"				{ return(EVENT); }
"jump"				{ return(JUMP); }
"return"			{ return(RETURN); }
"if"				{ return(IF); }
"else"				{ return(ELSE); }
"for"				{ return(FOR); }
"do"				{ return(DO); }
"while"				{ return(WHILE); }

"state_entry"			{ return(STATE_ENTRY); }
"state_exit"			{ return(STATE_EXIT); }
"touch_start"			{ return(TOUCH_START); }
"touch"					{ return(TOUCH); }
"touch_end"				{ return(TOUCH_END); }
"collision_start"		{ return(COLLISION_START); }
"collision"				{ return(COLLISION); }
"collision_end"			{ return(COLLISION_END); }
"land_collision_start"	{ return(LAND_COLLISION_START); }
"land_collision"		{ return(LAND_COLLISION); }
"land_collision_end"	{ return(LAND_COLLISION_END); }
"timer"					{ return(TIMER); }
"listen"				{ return(CHAT); }
"sensor"				{ return(SENSOR); }
"no_sensor"				{ return(NO_SENSOR); }
"control"				{ return(CONTROL); }
"print"					{ return(PRINT); }
"at_target"				{ return(AT_TARGET); }
"not_at_target"			{ return(NOT_AT_TARGET); }
"at_rot_target"			{ return(AT_ROT_TARGET); }
"not_at_rot_target"		{ return(NOT_AT_ROT_TARGET); }
"money"					{ return(MONEY); }
"email"					{ return(EMAIL); }
"run_time_permissions"	{ return(RUN_TIME_PERMISSIONS); }
"changed"				{ return(INVENTORY); }
"attach"				{ return(ATTACH); }
"dataserver"			{ return(DATASERVER); }
"moving_start"			{ return(MOVING_START); }
"moving_end"			{ return(MOVING_END); }
"link_message"			{ return(LINK_MESSAGE); }
"on_rez"				{ return(REZ); }
"object_rez"			{ return(OBJECT_REZ); }
"remote_data"			{ return(REMOTE_DATA); }
"http_response"         { return(HTTP_RESPONSE); }
"."						{ return(PERIOD); }


0[xX]{H}+			{ yylval->ival = strtoul(yytext, NULL, 0);  return(INTEGER_CONSTANT); }
[-]?{D}+            { yylval->ival = strtoul(yytext, NULL, 10); return(INTEGER_CONSTANT); }
{BD}+				{
    yylval->ival = strtoul(yytext, NULL, 10); 
    ERROR( yylloc, W_BAD_DECIMAL_LEX, yytext, yylval->ival);
    return(INTEGER_CONSTANT);
}
"TRUE"				{ yylval->ival = 1; return(INTEGER_TRUE); }
"FALSE"				{ yylval->ival = 0; return(INTEGER_FALSE); }

"STATUS_PHYSICS"		{ yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"STATUS_ROTATE_X"		{ yylval->ival = 0x2; return(INTEGER_CONSTANT); }
"STATUS_ROTATE_Y"		{ yylval->ival = 0x4; return(INTEGER_CONSTANT); }
"STATUS_ROTATE_Z"		{ yylval->ival = 0x8; return(INTEGER_CONSTANT); }
"STATUS_PHANTOM"		{ yylval->ival = 0x10; return(INTEGER_CONSTANT); }
"STATUS_SANDBOX"		{ yylval->ival = 0x20; return(INTEGER_CONSTANT); }
"STATUS_BLOCK_GRAB"		{ yylval->ival = 0x40; return(INTEGER_CONSTANT); }
"STATUS_DIE_AT_EDGE"	{ yylval->ival = 0x80; return(INTEGER_CONSTANT); }
"STATUS_RETURN_AT_EDGE"	{ yylval->ival = 0x100; return(INTEGER_CONSTANT); }

"AGENT_FLYING"			{ yylval->ival = AGENT_FLYING; return(INTEGER_CONSTANT); }
"AGENT_ATTACHMENTS"		{ yylval->ival = AGENT_ATTACHMENTS; return(INTEGER_CONSTANT); }
"AGENT_SCRIPTED"		{ yylval->ival = AGENT_SCRIPTED; return(INTEGER_CONSTANT); }
"AGENT_MOUSELOOK"		{ yylval->ival = AGENT_MOUSELOOK; return(INTEGER_CONSTANT); }
"AGENT_SITTING"			{ yylval->ival = AGENT_SITTING; return(INTEGER_CONSTANT); }
"AGENT_ON_OBJECT"		{ yylval->ival = AGENT_ON_OBJECT; return(INTEGER_CONSTANT); }
"AGENT_AWAY"			{ yylval->ival = AGENT_AWAY; return(INTEGER_CONSTANT); }
"AGENT_WALKING"			{ yylval->ival = AGENT_WALKING; return(INTEGER_CONSTANT); }
"AGENT_IN_AIR"			{ yylval->ival = AGENT_IN_AIR; return(INTEGER_CONSTANT); }
"AGENT_TYPING"			{ yylval->ival = AGENT_TYPING; return(INTEGER_CONSTANT); }
"AGENT_CROUCHING"		{ yylval->ival = AGENT_CROUCHING; return(INTEGER_CONSTANT); }
"AGENT_BUSY"			{ yylval->ival = AGENT_BUSY; return(INTEGER_CONSTANT); }
"AGENT_ALWAYS_RUN"		{ yylval->ival = AGENT_ALWAYS_RUN; return(INTEGER_CONSTANT); }

"ANIM_ON"				{ yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"LOOP"					{ yylval->ival = 0x2; return(INTEGER_CONSTANT); }
"REVERSE"				{ yylval->ival = 0x4; return(INTEGER_CONSTANT); }
"PING_PONG"				{ yylval->ival = 0x8; return(INTEGER_CONSTANT); }
"SMOOTH"				{ yylval->ival = 0x10; return(INTEGER_CONSTANT); }
"ROTATE"				{ yylval->ival = 0x20; return(INTEGER_CONSTANT); }
"SCALE"					{ yylval->ival = 0x40; return(INTEGER_CONSTANT); }

"ALL_SIDES"				{ yylval->ival = LSL_ALL_SIDES; return(INTEGER_CONSTANT); }
"LINK_ROOT"				{ yylval->ival = LSL_LINK_ROOT; return(INTEGER_CONSTANT); }
"LINK_SET"				{ yylval->ival = LSL_LINK_SET; return(INTEGER_CONSTANT); }
"LINK_ALL_OTHERS"		{ yylval->ival = LSL_LINK_ALL_OTHERS; return(INTEGER_CONSTANT); }
"LINK_ALL_CHILDREN"		{ yylval->ival = LSL_LINK_ALL_CHILDREN; return(INTEGER_CONSTANT); }
"LINK_THIS"				{ yylval->ival = LSL_LINK_THIS; return(INTEGER_CONSTANT); }

"AGENT"					{ yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"ACTIVE"				{ yylval->ival = 0x2; return(INTEGER_CONSTANT); }
"PASSIVE"				{ yylval->ival = 0x4; return(INTEGER_CONSTANT); }
"SCRIPTED"				{ yylval->ival = 0x8; return(INTEGER_CONSTANT); }

"CONTROL_FWD"			{ yylval->ival = AGENT_CONTROL_AT_POS; return(INTEGER_CONSTANT); }
"CONTROL_BACK"			{ yylval->ival = AGENT_CONTROL_AT_NEG; return(INTEGER_CONSTANT); }
"CONTROL_LEFT"			{ yylval->ival = AGENT_CONTROL_LEFT_POS; return(INTEGER_CONSTANT); }
"CONTROL_RIGHT"			{ yylval->ival = AGENT_CONTROL_LEFT_NEG; return(INTEGER_CONSTANT); }
"CONTROL_ROT_LEFT"		{ yylval->ival = AGENT_CONTROL_YAW_POS; return(INTEGER_CONSTANT); }
"CONTROL_ROT_RIGHT"		{ yylval->ival = AGENT_CONTROL_YAW_NEG; return(INTEGER_CONSTANT); }
"CONTROL_UP"			{ yylval->ival = AGENT_CONTROL_UP_POS; return(INTEGER_CONSTANT); }
"CONTROL_DOWN"			{ yylval->ival = AGENT_CONTROL_UP_NEG; return(INTEGER_CONSTANT); }
"CONTROL_LBUTTON"		{ yylval->ival = AGENT_CONTROL_LBUTTON_DOWN; return(INTEGER_CONSTANT); }
"CONTROL_ML_LBUTTON"	{ yylval->ival = AGENT_CONTROL_ML_LBUTTON_DOWN; return(INTEGER_CONSTANT); }

"PERMISSION_DEBIT"				{ yylval->ival = SCRIPT_PERMISSION_DEBIT; return(INTEGER_CONSTANT); }
"PERMISSION_TAKE_CONTROLS"		{ yylval->ival = SCRIPT_PERMISSION_TAKE_CONTROLS; return(INTEGER_CONSTANT); }
"PERMISSION_REMAP_CONTROLS"		{ yylval->ival = SCRIPT_PERMISSION_REMAP_CONTROLS; return(INTEGER_CONSTANT); }
"PERMISSION_TRIGGER_ANIMATION"	{ yylval->ival = SCRIPT_PERMISSION_TRIGGER_ANIMATION; return(INTEGER_CONSTANT); }
"PERMISSION_ATTACH"				{ yylval->ival = SCRIPT_PERMISSION_ATTACH; return(INTEGER_CONSTANT); }
"PERMISSION_RELEASE_OWNERSHIP"	{ yylval->ival = SCRIPT_PERMISSION_RELEASE_OWNERSHIP; return(INTEGER_CONSTANT); }
"PERMISSION_CHANGE_LINKS"		{ yylval->ival = SCRIPT_PERMISSION_CHANGE_LINKS; return(INTEGER_CONSTANT); }
"PERMISSION_CHANGE_JOINTS"		{ yylval->ival = SCRIPT_PERMISSION_CHANGE_JOINTS; return(INTEGER_CONSTANT); }
"PERMISSION_CHANGE_PERMISSIONS"	{ yylval->ival = SCRIPT_PERMISSION_CHANGE_PERMISSIONS; return(INTEGER_CONSTANT); }
"PERMISSION_TRACK_CAMERA"       { yylval->ival = SCRIPT_PERMISSION_TRACK_CAMERA; return(INTEGER_CONSTANT); }
"PERMISSION_CONTROL_CAMERA"     { yylval->ival = 0x800; return(INTEGER_CONSTANT); }

"INVENTORY_TEXTURE"					{ yylval->ival = LLAssetType::AT_TEXTURE; return(INTEGER_CONSTANT); }
"INVENTORY_SOUND"					{ yylval->ival = LLAssetType::AT_SOUND; return(INTEGER_CONSTANT); }
"INVENTORY_OBJECT"					{ yylval->ival = LLAssetType::AT_OBJECT; return(INTEGER_CONSTANT); }
"INVENTORY_SCRIPT"					{ yylval->ival = LLAssetType::AT_LSL_TEXT; return(INTEGER_CONSTANT); }
"INVENTORY_LANDMARK"				{ yylval->ival = LLAssetType::AT_LANDMARK; return(INTEGER_CONSTANT); }
"INVENTORY_CLOTHING"				{ yylval->ival = LLAssetType::AT_CLOTHING; return(INTEGER_CONSTANT); }
"INVENTORY_NOTECARD"				{ yylval->ival = LLAssetType::AT_NOTECARD; return(INTEGER_CONSTANT); }
"INVENTORY_BODYPART"				{ yylval->ival = LLAssetType::AT_BODYPART; return(INTEGER_CONSTANT); }
"INVENTORY_ANIMATION"				{ yylval->ival = LLAssetType::AT_ANIMATION; return(INTEGER_CONSTANT); }
"INVENTORY_GESTURE"					{ yylval->ival = LLAssetType::AT_GESTURE; return(INTEGER_CONSTANT); }
"INVENTORY_ALL"						{ yylval->ival = LLAssetType::AT_NONE; return(INTEGER_CONSTANT); }
"INVENTORY_NONE"                    { yylval->ival = LLAssetType::AT_NONE; return(INTEGER_CONSTANT); }

"CHANGED_INVENTORY"		{ yylval->ival = 0x1; return(INTEGER_CONSTANT); }	
"CHANGED_COLOR"			{ yylval->ival = 0x2; return(INTEGER_CONSTANT); }	
"CHANGED_SHAPE"			{ yylval->ival = 0x4; return(INTEGER_CONSTANT); }	
"CHANGED_SCALE"			{ yylval->ival = 0x8; return(INTEGER_CONSTANT); }	
"CHANGED_TEXTURE"		{ yylval->ival = 0x10; return(INTEGER_CONSTANT); }	
"CHANGED_LINK"			{ yylval->ival = 0x20; return(INTEGER_CONSTANT); }	
"CHANGED_ALLOWED_DROP"	{ yylval->ival = 0x40; return(INTEGER_CONSTANT); }	
"CHANGED_OWNER"			{ yylval->ival = 0x80; return(INTEGER_CONSTANT); }	
"CHANGED_REGION"        { yylval->ival = 0x100; return(INTEGER_CONSTANT); }
"CHANGED_TELEPORT"      { yylval->ival = 0x200; return(INTEGER_CONSTANT); }

"CAMERA_ACTIVE" { yylval->ival = 12; return(INTEGER_CONSTANT); }
"CAMERA_BEHINDNESS_ANGLE" { yylval->ival = 8; return(INTEGER_CONSTANT); }
"CAMERA_BEHINDNESS_LAG" { yylval->ival = 9; return(INTEGER_CONSTANT); }
"CAMERA_DISTANCE" { yylval->ival = 7; return(INTEGER_CONSTANT); }
"CAMERA_FOCUS" { yylval->ival = 17; return(INTEGER_CONSTANT); }
"CAMERA_FOCUS_LAG" { yylval->ival = 6; return(INTEGER_CONSTANT); }
"CAMERA_FOCUS_LOCKED" { yylval->ival = 22; return(INTEGER_CONSTANT); }
"CAMERA_FOCUS_OFFSET" { yylval->ival = 1; return(INTEGER_CONSTANT); }
"CAMERA_FOCUS_THRESHOLD" { yylval->ival = 11; return(INTEGER_CONSTANT); }
"CAMERA_PITCH" { yylval->ival = 0; return(INTEGER_CONSTANT); }
"CAMERA_POSITION" { yylval->ival = 13; return(INTEGER_CONSTANT); }
"CAMERA_POSITION_LAG" { yylval->ival = 5; return(INTEGER_CONSTANT); }
"CAMERA_POSITION_LOCKED" { yylval->ival = 21; return(INTEGER_CONSTANT); }
"CAMERA_POSITION_THRESHOLD" { yylval->ival = 10; return(INTEGER_CONSTANT); }

"REGION_FLAG_ALLOW_DAMAGE" { yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"REGION_FLAG_FIXED_SUN" { yylval->ival = 0x10; return(INTEGER_CONSTANT); }
"REGION_FLAG_BLOCK_TERRAFORM" { yylval->ival = 0x40; return(INTEGER_CONSTANT); }
"REGION_FLAG_SANDBOX" { yylval->ival = 0x100; return(INTEGER_CONSTANT); }
"REGION_FLAG_DISABLE_COLLISIONS" { yylval->ival = 0x1000; return(INTEGER_CONSTANT); }
"REGION_FLAG_DISABLE_PHYSICS" { yylval->ival = 0x4000; return(INTEGER_CONSTANT); }
"REGION_FLAG_BLOCK_FLY" { yylval->ival = 0x80000; return(INTEGER_CONSTANT); }
"REGION_FLAG_ALLOW_DIRECT_TELEPORT" { yylval->ival = 0x100000; return(INTEGER_CONSTANT); }
"REGION_FLAG_RESTRICT_PUSHOBJECT" { yylval->ival = 0x400000; return(INTEGER_CONSTANT); }

"LIST_STAT_MAX" { yylval->ival = 2; return(INTEGER_CONSTANT); }
"LIST_STAT_MIN" { yylval->ival = 1; return(INTEGER_CONSTANT); }
"LIST_STAT_MEAN" { yylval->ival = 3; return(INTEGER_CONSTANT); }
"LIST_STAT_MEDIAN" { yylval->ival = 4; return(INTEGER_CONSTANT); }
"LIST_STAT_STD_DEV" { yylval->ival = 5; return(INTEGER_CONSTANT); }
"LIST_STAT_SUM" { yylval->ival = 6; return(INTEGER_CONSTANT); }
"LIST_STAT_SUM_SQUARES" { yylval->ival = 7; return(INTEGER_CONSTANT); }
"LIST_STAT_NUM_COUNT" { yylval->ival = 8; return(INTEGER_CONSTANT); }
"LIST_STAT_GEOMETRIC_MEAN" { yylval->ival = 9; return(INTEGER_CONSTANT); }
"LIST_STAT_RANGE" { yylval->ival = 0; return(INTEGER_CONSTANT); }

"DEBUG_CHANNEL"         { yylval->ival = 2147483647; return(INTEGER_CONSTANT); }

"HTTP_METHOD"           { yylval->ival = 0; return(INTEGER_CONSTANT); }
"HTTP_MIMETYPE"         { yylval->ival = 1; return(INTEGER_CONSTANT); }
"HTTP_BODY_MAXLENGTH"   { yylval->ival = 2; return(INTEGER_CONSTANT); }
"HTTP_VERIFY_CERT"      { yylval->ival = 3; return(INTEGER_CONSTANT); }
"HTTP_BODY_TRUNCATED"   { yylval->ival = 0; return(INTEGER_CONSTANT); }

"OBJECT_UNKNOWN_DETAIL" { yylval->ival = -1; return(INTEGER_CONSTANT); }
"OBJECT_NAME"           { yylval->ival = 1; return(INTEGER_CONSTANT); }
"OBJECT_DESC"           { yylval->ival = 2; return(INTEGER_CONSTANT); }
"OBJECT_POS"            { yylval->ival = 3; return(INTEGER_CONSTANT); }
"OBJECT_ROT"            { yylval->ival = 4; return(INTEGER_CONSTANT); }
"OBJECT_VELOCITY"       { yylval->ival = 5; return(INTEGER_CONSTANT); }
"OBJECT_OWNER"          { yylval->ival = 6; return(INTEGER_CONSTANT); }
"OBJECT_GROUP"          { yylval->ival = 7; return(INTEGER_CONSTANT); }
"OBJECT_CREATOR"        { yylval->ival = 8; return(INTEGER_CONSTANT); }

"TYPE_INTEGER"			{ yylval->ival = LST_INTEGER; return(INTEGER_CONSTANT); }	
"TYPE_FLOAT"			{ yylval->ival = LST_FLOATINGPOINT; return(INTEGER_CONSTANT); }	
"TYPE_STRING"			{ yylval->ival = LST_STRING; return(INTEGER_CONSTANT); }	
"TYPE_KEY"				{ yylval->ival = LST_KEY; return(INTEGER_CONSTANT); }	
"TYPE_VECTOR"			{ yylval->ival = LST_VECTOR; return(INTEGER_CONSTANT); }	
"TYPE_ROTATION"			{ yylval->ival = LST_QUATERNION; return(INTEGER_CONSTANT); }	
"TYPE_INVALID"			{ yylval->ival = LST_NULL; return(INTEGER_CONSTANT); }	

"NULL_KEY"				{ yylval->sval = new char[UUID_STR_LENGTH]; strcpy(yylval->sval, "00000000-0000-0000-0000-000000000000"); return(STRING_CONSTANT); }
"EOF"					{ yylval->sval = new char[UUID_STR_LENGTH]; strcpy(yylval->sval, "\n\n\n"); return(STRING_CONSTANT); }

"PI"					{ yylval->fval = F_PI; return(FP_CONSTANT); }
"TWO_PI"				{ yylval->fval = F_TWO_PI; return(FP_CONSTANT); }
"PI_BY_TWO"				{ yylval->fval = F_PI_BY_TWO; return(FP_CONSTANT); }
"DEG_TO_RAD"			{ yylval->fval = DEG_TO_RAD; return(FP_CONSTANT); }
"RAD_TO_DEG"			{ yylval->fval = RAD_TO_DEG; return(FP_CONSTANT); }
"SQRT2"					{ yylval->fval = F_SQRT2; return(FP_CONSTANT); }

"ZERO_VECTOR"			{ return(ZERO_VECTOR); }
"ZERO_ROTATION"			{ return(ZERO_ROTATION); }

"ATTACH_CHEST"		{ yylval->ival = 1; return(INTEGER_CONSTANT); }
"ATTACH_HEAD"		{ yylval->ival = 2; return(INTEGER_CONSTANT); }
"ATTACH_LSHOULDER"	{ yylval->ival = 3; return(INTEGER_CONSTANT); }
"ATTACH_RSHOULDER"	{ yylval->ival = 4; return(INTEGER_CONSTANT); }
"ATTACH_LHAND"		{ yylval->ival = 5; return(INTEGER_CONSTANT); }
"ATTACH_RHAND"		{ yylval->ival = 6; return(INTEGER_CONSTANT); }
"ATTACH_LFOOT"		{ yylval->ival = 7; return(INTEGER_CONSTANT); }
"ATTACH_RFOOT"		{ yylval->ival = 8; return(INTEGER_CONSTANT); }
"ATTACH_BACK"		{ yylval->ival = 9; return(INTEGER_CONSTANT); }
"ATTACH_PELVIS"		{ yylval->ival = 10; return(INTEGER_CONSTANT); }
"ATTACH_MOUTH"		{ yylval->ival = 11; return(INTEGER_CONSTANT); }
"ATTACH_CHIN"		{ yylval->ival = 12; return(INTEGER_CONSTANT); }
"ATTACH_LEAR"		{ yylval->ival = 13; return(INTEGER_CONSTANT); }
"ATTACH_REAR"		{ yylval->ival = 14; return(INTEGER_CONSTANT); }
"ATTACH_LEYE"		{ yylval->ival = 15; return(INTEGER_CONSTANT); }
"ATTACH_REYE"		{ yylval->ival = 16; return(INTEGER_CONSTANT); }
"ATTACH_NOSE"		{ yylval->ival = 17; return(INTEGER_CONSTANT); }
"ATTACH_RUARM"		{ yylval->ival = 18; return(INTEGER_CONSTANT); }
"ATTACH_RLARM"		{ yylval->ival = 19; return(INTEGER_CONSTANT); }
"ATTACH_LUARM"		{ yylval->ival = 20; return(INTEGER_CONSTANT); }
"ATTACH_LLARM"		{ yylval->ival = 21; return(INTEGER_CONSTANT); }
"ATTACH_RHIP"		{ yylval->ival = 22; return(INTEGER_CONSTANT); }
"ATTACH_RULEG"		{ yylval->ival = 23; return(INTEGER_CONSTANT); }
"ATTACH_RLLEG"		{ yylval->ival = 24; return(INTEGER_CONSTANT); }
"ATTACH_LHIP"		{ yylval->ival = 25; return(INTEGER_CONSTANT); }
"ATTACH_LULEG"		{ yylval->ival = 26; return(INTEGER_CONSTANT); }
"ATTACH_LLLEG"		{ yylval->ival = 27; return(INTEGER_CONSTANT); }
"ATTACH_BELLY"		{ yylval->ival = 28; return(INTEGER_CONSTANT); }
"ATTACH_RPEC"		{ yylval->ival = 29; return(INTEGER_CONSTANT); }
"ATTACH_LPEC"		{ yylval->ival = 30; return(INTEGER_CONSTANT); }

"LAND_LEVEL"		{ yylval->ival = E_LANDBRUSH_LEVEL; return(INTEGER_CONSTANT); }
"LAND_RAISE"		{ yylval->ival = E_LANDBRUSH_RAISE; return(INTEGER_CONSTANT); }
"LAND_LOWER"		{ yylval->ival = E_LANDBRUSH_LOWER; return(INTEGER_CONSTANT); }
"LAND_SMOOTH"		{ yylval->ival = E_LANDBRUSH_SMOOTH; return(INTEGER_CONSTANT); }
"LAND_NOISE"		{ yylval->ival = E_LANDBRUSH_NOISE; return(INTEGER_CONSTANT); }
"LAND_REVERT"		{ yylval->ival = E_LANDBRUSH_REVERT; return(INTEGER_CONSTANT); }

"LAND_SMALL_BRUSH"	{ yylval->ival = 1; return(INTEGER_CONSTANT); }
"LAND_MEDIUM_BRUSH"	{ yylval->ival = 2; return(INTEGER_CONSTANT); }
"LAND_LARGE_BRUSH"	{ yylval->ival = 3; return(INTEGER_CONSTANT); }
	
"DATA_ONLINE"		{ yylval->ival = 1; return(INTEGER_CONSTANT); }
"DATA_NAME"			{ yylval->ival = 2; return(INTEGER_CONSTANT); }
"DATA_BORN"			{ yylval->ival = 3; return(INTEGER_CONSTANT); }
"DATA_RATING"		{ yylval->ival = 4; return(INTEGER_CONSTANT); }
"DATA_SIM_POS"		{ yylval->ival = 5; return(INTEGER_CONSTANT); }
"DATA_SIM_STATUS"	{ yylval->ival = 6; return(INTEGER_CONSTANT); }
"DATA_SIM_RATING"   { yylval->ival = 7; return(INTEGER_CONSTANT); }
"DATA_PAYINFO"   { yylval->ival = 8; return(INTEGER_CONSTANT); }

"REMOTE_DATA_CHANNEL"	{ yylval->ival = 1; return(INTEGER_CONSTANT); }
"REMOTE_DATA_REQUEST"	{ yylval->ival = 2; return(INTEGER_CONSTANT); }
"REMOTE_DATA_REPLY"		{ yylval->ival = 3; return(INTEGER_CONSTANT); }

"PSYS_PART_FLAGS"		{ yylval->ival = LLPS_PART_FLAGS; return(INTEGER_CONSTANT); }
"PSYS_PART_START_COLOR"	{ yylval->ival = LLPS_PART_START_COLOR; return (INTEGER_CONSTANT); }
"PSYS_PART_START_ALPHA"	{ yylval->ival = LLPS_PART_START_ALPHA; return (INTEGER_CONSTANT); }
"PSYS_PART_START_SCALE"	{ yylval->ival = LLPS_PART_START_SCALE; return (INTEGER_CONSTANT); }
"PSYS_PART_END_COLOR"	{ yylval->ival = LLPS_PART_END_COLOR; return (INTEGER_CONSTANT); }
"PSYS_PART_END_ALPHA"	{ yylval->ival = LLPS_PART_END_ALPHA; return (INTEGER_CONSTANT); }
"PSYS_PART_END_SCALE"	{ yylval->ival = LLPS_PART_END_SCALE; return (INTEGER_CONSTANT); }
"PSYS_PART_MAX_AGE"		{ yylval->ival = LLPS_PART_MAX_AGE; return (INTEGER_CONSTANT); }


"PSYS_PART_WIND_MASK"				{ yylval->ival = LLPartData::LL_PART_WIND_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_INTERP_COLOR_MASK"		{ yylval->ival = LLPartData::LL_PART_INTERP_COLOR_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_INTERP_SCALE_MASK"		{ yylval->ival = LLPartData::LL_PART_INTERP_SCALE_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_BOUNCE_MASK"				{ yylval->ival = LLPartData::LL_PART_BOUNCE_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_FOLLOW_SRC_MASK"			{ yylval->ival = LLPartData::LL_PART_FOLLOW_SRC_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_FOLLOW_VELOCITY_MASK"	{ yylval->ival = LLPartData::LL_PART_FOLLOW_VELOCITY_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_TARGET_POS_MASK"			{ yylval->ival = LLPartData::LL_PART_TARGET_POS_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_EMISSIVE_MASK"			{ yylval->ival = LLPartData::LL_PART_EMISSIVE_MASK; return(INTEGER_CONSTANT); }
"PSYS_PART_TARGET_LINEAR_MASK"		{ yylval->ival = LLPartData::LL_PART_TARGET_LINEAR_MASK; return(INTEGER_CONSTANT); }


"PSYS_SRC_MAX_AGE"					{ yylval->ival = LLPS_SRC_MAX_AGE; return(INTEGER_CONSTANT); }
"PSYS_SRC_PATTERN"					{ yylval->ival = LLPS_SRC_PATTERN; return(INTEGER_CONSTANT); }
"PSYS_SRC_INNERANGLE"				{ yylval->ival = LLPS_SRC_INNERANGLE; return(INTEGER_CONSTANT); }
"PSYS_SRC_OUTERANGLE"				{ yylval->ival = LLPS_SRC_OUTERANGLE; return(INTEGER_CONSTANT); }
"PSYS_SRC_ANGLE_BEGIN"				{ yylval->ival = LLPS_SRC_ANGLE_BEGIN; return(INTEGER_CONSTANT); }
"PSYS_SRC_ANGLE_END"				{ yylval->ival = LLPS_SRC_ANGLE_END; return(INTEGER_CONSTANT); }
"PSYS_SRC_BURST_RATE"				{ yylval->ival = LLPS_SRC_BURST_RATE; return(INTEGER_CONSTANT); }
"PSYS_SRC_BURST_PART_COUNT"			{ yylval->ival = LLPS_SRC_BURST_PART_COUNT; return(INTEGER_CONSTANT); }
"PSYS_SRC_BURST_RADIUS"				{ yylval->ival = LLPS_SRC_BURST_RADIUS; return(INTEGER_CONSTANT); }
"PSYS_SRC_BURST_SPEED_MIN"			{ yylval->ival = LLPS_SRC_BURST_SPEED_MIN; return(INTEGER_CONSTANT); }
"PSYS_SRC_BURST_SPEED_MAX"			{ yylval->ival = LLPS_SRC_BURST_SPEED_MAX; return(INTEGER_CONSTANT); }
"PSYS_SRC_ACCEL"					{ yylval->ival = LLPS_SRC_ACCEL; return(INTEGER_CONSTANT); }
"PSYS_SRC_TEXTURE"					{ yylval->ival = LLPS_SRC_TEXTURE; return(INTEGER_CONSTANT); }
"PSYS_SRC_TARGET_KEY"				{ yylval->ival = LLPS_SRC_TARGET_UUID; return(INTEGER_CONSTANT); }
"PSYS_SRC_OMEGA"					{ yylval->ival = LLPS_SRC_OMEGA; return(INTEGER_CONSTANT); }

 /* "PSYS_SRC_OBJ_REL_MASK"				{ yylval->ival = LLPartSysData::LL_PART_SRC_OBJ_REL_MASK; return(INTEGER_CONSTANT); } */

"PSYS_SRC_PATTERN_DROP"				{ yylval->ival = LLPartSysData::LL_PART_SRC_PATTERN_DROP; return(INTEGER_CONSTANT); }
"PSYS_SRC_PATTERN_EXPLODE"			{ yylval->ival = LLPartSysData::LL_PART_SRC_PATTERN_EXPLODE; return(INTEGER_CONSTANT); }
"PSYS_SRC_PATTERN_ANGLE"			{ yylval->ival = LLPartSysData::LL_PART_SRC_PATTERN_ANGLE; return(INTEGER_CONSTANT); }
"PSYS_SRC_PATTERN_ANGLE_CONE"		{ yylval->ival = LLPartSysData::LL_PART_SRC_PATTERN_ANGLE_CONE; return(INTEGER_CONSTANT); }
"PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY"	{ yylval->ival = LLPartSysData::LL_PART_SRC_PATTERN_ANGLE_CONE_EMPTY; return(INTEGER_CONSTANT); }


"VEHICLE_TYPE_NONE"		{ yylval->ival = VEHICLE_TYPE_NONE; return(INTEGER_CONSTANT); }
"VEHICLE_TYPE_SLED"		{ yylval->ival = VEHICLE_TYPE_SLED; return(INTEGER_CONSTANT); }
"VEHICLE_TYPE_CAR"		{ yylval->ival = VEHICLE_TYPE_CAR; return(INTEGER_CONSTANT); }
"VEHICLE_TYPE_BOAT"		{ yylval->ival = VEHICLE_TYPE_BOAT; return(INTEGER_CONSTANT); }
"VEHICLE_TYPE_AIRPLANE"	{ yylval->ival = VEHICLE_TYPE_AIRPLANE; return(INTEGER_CONSTANT); }
"VEHICLE_TYPE_BALLOON"	{ yylval->ival = VEHICLE_TYPE_BALLOON; return(INTEGER_CONSTANT); }

"VEHICLE_REFERENCE_FRAME"			{ yylval->ival = VEHICLE_REFERENCE_FRAME; return(INTEGER_CONSTANT); }
"VEHICLE_LINEAR_FRICTION_TIMESCALE"	{ yylval->ival = VEHICLE_LINEAR_FRICTION_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_ANGULAR_FRICTION_TIMESCALE" { yylval->ival = VEHICLE_ANGULAR_FRICTION_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_LINEAR_MOTOR_DIRECTION"	{ yylval->ival = VEHICLE_LINEAR_MOTOR_DIRECTION; return(INTEGER_CONSTANT); }
"VEHICLE_ANGULAR_MOTOR_DIRECTION"	{ yylval->ival = VEHICLE_ANGULAR_MOTOR_DIRECTION; return(INTEGER_CONSTANT); }
"VEHICLE_LINEAR_MOTOR_OFFSET"	    { yylval->ival = VEHICLE_LINEAR_MOTOR_OFFSET; return(INTEGER_CONSTANT); }



"VEHICLE_HOVER_HEIGHT"		{ yylval->ival = VEHICLE_HOVER_HEIGHT; return(INTEGER_CONSTANT); }
"VEHICLE_HOVER_EFFICIENCY"	{ yylval->ival = VEHICLE_HOVER_EFFICIENCY; return(INTEGER_CONSTANT); }
"VEHICLE_HOVER_TIMESCALE"	{ yylval->ival = VEHICLE_HOVER_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_BUOYANCY"			{ yylval->ival = VEHICLE_BUOYANCY; return(INTEGER_CONSTANT); }

"VEHICLE_LINEAR_DEFLECTION_EFFICIENCY"	{ yylval->ival = VEHICLE_LINEAR_DEFLECTION_EFFICIENCY; return(INTEGER_CONSTANT); }
"VEHICLE_LINEAR_DEFLECTION_TIMESCALE"	{ yylval->ival = VEHICLE_LINEAR_DEFLECTION_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_LINEAR_MOTOR_TIMESCALE"		{ yylval->ival = VEHICLE_LINEAR_MOTOR_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE"	{ yylval->ival = VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE; return(INTEGER_CONSTANT); }

"VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY" { yylval->ival = VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY; return(INTEGER_CONSTANT); }
"VEHICLE_ANGULAR_DEFLECTION_TIMESCALE"	{ yylval->ival = VEHICLE_ANGULAR_DEFLECTION_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_ANGULAR_MOTOR_TIMESCALE"		{ yylval->ival = VEHICLE_ANGULAR_MOTOR_TIMESCALE; return(INTEGER_CONSTANT); }
"VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE"	{ yylval->ival = VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE; return(INTEGER_CONSTANT); }

"VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY"	{ yylval->ival = VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY; return(INTEGER_CONSTANT); }
"VEHICLE_VERTICAL_ATTRACTION_TIMESCALE"		{ yylval->ival = VEHICLE_VERTICAL_ATTRACTION_TIMESCALE; return(INTEGER_CONSTANT); }

"VEHICLE_BANKING_EFFICIENCY"	{ yylval->ival = VEHICLE_BANKING_EFFICIENCY; return(INTEGER_CONSTANT); }
"VEHICLE_BANKING_MIX"			{ yylval->ival = VEHICLE_BANKING_MIX; return(INTEGER_CONSTANT); }
"VEHICLE_BANKING_TIMESCALE"		{ yylval->ival = VEHICLE_BANKING_TIMESCALE; return(INTEGER_CONSTANT); }

"VEHICLE_FLAG_NO_FLY_UP"			{ yylval->ival = VEHICLE_FLAG_NO_DEFLECTION_UP; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_NO_DEFLECTION_UP"			{ yylval->ival = VEHICLE_FLAG_NO_DEFLECTION_UP; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_LIMIT_ROLL_ONLY"		{ yylval->ival = VEHICLE_FLAG_LIMIT_ROLL_ONLY; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_HOVER_WATER_ONLY"		{ yylval->ival = VEHICLE_FLAG_HOVER_WATER_ONLY; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_HOVER_TERRAIN_ONLY"	{ yylval->ival = VEHICLE_FLAG_HOVER_TERRAIN_ONLY; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT"	{ yylval->ival = VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_HOVER_UP_ONLY"		{ yylval->ival = VEHICLE_FLAG_HOVER_UP_ONLY; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_LIMIT_MOTOR_UP"		{ yylval->ival = VEHICLE_FLAG_LIMIT_MOTOR_UP; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_MOUSELOOK_STEER"		{ yylval->ival = VEHICLE_FLAG_MOUSELOOK_STEER; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_MOUSELOOK_BANK"		{ yylval->ival = VEHICLE_FLAG_MOUSELOOK_BANK; return(INTEGER_CONSTANT); }
"VEHICLE_FLAG_CAMERA_DECOUPLED"		{ yylval->ival = VEHICLE_FLAG_CAMERA_DECOUPLED; return(INTEGER_CONSTANT); }

"PRIM_TYPE"				{ yylval->ival = LSL_PRIM_TYPE; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL"			{ yylval->ival = LSL_PRIM_MATERIAL; return(INTEGER_CONSTANT); }
"PRIM_PHYSICS"			{ yylval->ival = LSL_PRIM_PHYSICS; return(INTEGER_CONSTANT); }
"PRIM_TEMP_ON_REZ"		{ yylval->ival = LSL_PRIM_TEMP_ON_REZ; return(INTEGER_CONSTANT); }
"PRIM_PHANTOM"			{ yylval->ival = LSL_PRIM_PHANTOM; return(INTEGER_CONSTANT); }
"PRIM_POSITION"			{ yylval->ival = LSL_PRIM_POSITION; return(INTEGER_CONSTANT); }
"PRIM_SIZE"				{ yylval->ival = LSL_PRIM_SIZE; return(INTEGER_CONSTANT); }
"PRIM_ROTATION"			{ yylval->ival = LSL_PRIM_ROTATION; return(INTEGER_CONSTANT); }
"PRIM_TEXTURE"			{ yylval->ival = LSL_PRIM_TEXTURE; return(INTEGER_CONSTANT); }
"PRIM_COLOR"			{ yylval->ival = LSL_PRIM_COLOR; return(INTEGER_CONSTANT); }
"PRIM_BUMP_SHINY"		{ yylval->ival = LSL_PRIM_BUMP_SHINY; return(INTEGER_CONSTANT); }
"PRIM_FULLBRIGHT"       { yylval->ival = LSL_PRIM_FULLBRIGHT; return(INTEGER_CONSTANT); }
"PRIM_FLEXIBLE"         { yylval->ival = 21; return(INTEGER_CONSTANT); }
"PRIM_TEXGEN"           { yylval->ival = 22; return(INTEGER_CONSTANT); }
"PRIM_POINT_LIGHT"      { yylval->ival = 23; return(INTEGER_CONSTANT); }

"PRIM_TEXGEN_DEFAULT" { yylval->ival = 0; return(INTEGER_CONSTANT); }
"PRIM_TEXGEN_PLANAR" { yylval->ival = 1; return(INTEGER_CONSTANT); }

"PRIM_TYPE_BOX"			{ yylval->ival = LSL_PRIM_TYPE_BOX; return(INTEGER_CONSTANT); }
"PRIM_TYPE_CYLINDER"	{ yylval->ival = LSL_PRIM_TYPE_CYLINDER; return(INTEGER_CONSTANT); }
"PRIM_TYPE_PRISM"		{ yylval->ival = LSL_PRIM_TYPE_PRISM; return(INTEGER_CONSTANT); }
"PRIM_TYPE_SPHERE"		{ yylval->ival = LSL_PRIM_TYPE_SPHERE; return(INTEGER_CONSTANT); }
"PRIM_TYPE_TORUS"		{ yylval->ival = LSL_PRIM_TYPE_TORUS; return(INTEGER_CONSTANT); }
"PRIM_TYPE_TUBE"		{ yylval->ival = LSL_PRIM_TYPE_TUBE; return(INTEGER_CONSTANT); }
"PRIM_TYPE_RING"		{ yylval->ival = LSL_PRIM_TYPE_RING; return(INTEGER_CONSTANT); }

"PRIM_HOLE_DEFAULT"		{ yylval->ival = LSL_PRIM_HOLE_DEFAULT; return(INTEGER_CONSTANT); }
"PRIM_HOLE_CIRCLE"		{ yylval->ival = LSL_PRIM_HOLE_CIRCLE; return(INTEGER_CONSTANT); }
"PRIM_HOLE_SQUARE"		{ yylval->ival = LSL_PRIM_HOLE_SQUARE; return(INTEGER_CONSTANT); }
"PRIM_HOLE_TRIANGLE"	{ yylval->ival = LSL_PRIM_HOLE_TRIANGLE; return(INTEGER_CONSTANT); }

"PRIM_MATERIAL_STONE"	{ yylval->ival = LSL_PRIM_MATERIAL_STONE; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_METAL"	{ yylval->ival = LSL_PRIM_MATERIAL_METAL; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_GLASS"	{ yylval->ival = LSL_PRIM_MATERIAL_GLASS; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_WOOD"	{ yylval->ival = LSL_PRIM_MATERIAL_WOOD; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_FLESH"	{ yylval->ival = LSL_PRIM_MATERIAL_FLESH; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_PLASTIC"	{ yylval->ival = LSL_PRIM_MATERIAL_PLASTIC; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_RUBBER"	{ yylval->ival = LSL_PRIM_MATERIAL_RUBBER; return(INTEGER_CONSTANT); }
"PRIM_MATERIAL_LIGHT"	{ yylval->ival = LSL_PRIM_MATERIAL_LIGHT; return(INTEGER_CONSTANT); }

"PRIM_SHINY_NONE"		{ yylval->ival = LSL_PRIM_SHINY_NONE; return(INTEGER_CONSTANT); }
"PRIM_SHINY_LOW"		{ yylval->ival = LSL_PRIM_SHINY_LOW; return(INTEGER_CONSTANT); }
"PRIM_SHINY_MEDIUM"		{ yylval->ival = LSL_PRIM_SHINY_MEDIUM; return(INTEGER_CONSTANT); }
"PRIM_SHINY_HIGH"		{ yylval->ival = LSL_PRIM_SHINY_HIGH; return(INTEGER_CONSTANT); }

"PRIM_BUMP_NONE"		{ yylval->ival = LSL_PRIM_BUMP_NONE; return(INTEGER_CONSTANT); }
"PRIM_BUMP_BRIGHT"		{ yylval->ival = LSL_PRIM_BUMP_BRIGHT; return(INTEGER_CONSTANT); }
"PRIM_BUMP_DARK"		{ yylval->ival = LSL_PRIM_BUMP_DARK; return(INTEGER_CONSTANT); }
"PRIM_BUMP_WOOD"		{ yylval->ival = LSL_PRIM_BUMP_WOOD; return(INTEGER_CONSTANT); }
"PRIM_BUMP_BARK"		{ yylval->ival = LSL_PRIM_BUMP_BARK; return(INTEGER_CONSTANT); }
"PRIM_BUMP_BRICKS"		{ yylval->ival = LSL_PRIM_BUMP_BRICKS; return(INTEGER_CONSTANT); }
"PRIM_BUMP_CHECKER"		{ yylval->ival = LSL_PRIM_BUMP_CHECKER; return(INTEGER_CONSTANT); }
"PRIM_BUMP_CONCRETE"	{ yylval->ival = LSL_PRIM_BUMP_CONCRETE; return(INTEGER_CONSTANT); }
"PRIM_BUMP_TILE"		{ yylval->ival = LSL_PRIM_BUMP_TILE; return(INTEGER_CONSTANT); }
"PRIM_BUMP_STONE"		{ yylval->ival = LSL_PRIM_BUMP_STONE; return(INTEGER_CONSTANT); }
"PRIM_BUMP_DISKS"		{ yylval->ival = LSL_PRIM_BUMP_DISKS; return(INTEGER_CONSTANT); }
"PRIM_BUMP_GRAVEL"		{ yylval->ival = LSL_PRIM_BUMP_GRAVEL; return(INTEGER_CONSTANT); }
"PRIM_BUMP_BLOBS"		{ yylval->ival = LSL_PRIM_BUMP_BLOBS; return(INTEGER_CONSTANT); }
"PRIM_BUMP_SIDING"		{ yylval->ival = LSL_PRIM_BUMP_SIDING; return(INTEGER_CONSTANT); }
"PRIM_BUMP_LARGETILE"	{ yylval->ival = LSL_PRIM_BUMP_LARGETILE; return(INTEGER_CONSTANT); }
"PRIM_BUMP_STUCCO"		{ yylval->ival = LSL_PRIM_BUMP_STUCCO; return(INTEGER_CONSTANT); }
"PRIM_BUMP_SUCTION"		{ yylval->ival = LSL_PRIM_BUMP_SUCTION; return(INTEGER_CONSTANT); }
"PRIM_BUMP_WEAVE"		{ yylval->ival = LSL_PRIM_BUMP_WEAVE; return(INTEGER_CONSTANT); }

"MASK_BASE"				{ yylval->ival = 0; return(INTEGER_CONSTANT); }
"MASK_OWNER"			{ yylval->ival = 1; return(INTEGER_CONSTANT); }
"MASK_GROUP"			{ yylval->ival = 2; return(INTEGER_CONSTANT); }
"MASK_EVERYONE"			{ yylval->ival = 3; return(INTEGER_CONSTANT); }
"MASK_NEXT"				{ yylval->ival = 4; return(INTEGER_CONSTANT); }

"PERM_TRANSFER"			{ yylval->ival = PERM_TRANSFER; return(INTEGER_CONSTANT); }
"PERM_MODIFY"			{ yylval->ival = PERM_MODIFY; return(INTEGER_CONSTANT); }
"PERM_COPY"				{ yylval->ival = PERM_COPY; return(INTEGER_CONSTANT); }
"PERM_MOVE"				{ yylval->ival = PERM_MOVE; return(INTEGER_CONSTANT); }
"PERM_ALL"				{ yylval->ival = PERM_ALL; return(INTEGER_CONSTANT); }
 
"PARCEL_MEDIA_COMMAND_STOP"		{ yylval->ival = PARCEL_MEDIA_COMMAND_STOP; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_PAUSE"	{ yylval->ival = PARCEL_MEDIA_COMMAND_PAUSE; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_PLAY"		{ yylval->ival = PARCEL_MEDIA_COMMAND_PLAY; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_LOOP"		{ yylval->ival = PARCEL_MEDIA_COMMAND_LOOP; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_TEXTURE"	{ yylval->ival = PARCEL_MEDIA_COMMAND_TEXTURE; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_URL"		{ yylval->ival = PARCEL_MEDIA_COMMAND_URL; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_TIME"		{ yylval->ival = PARCEL_MEDIA_COMMAND_TIME; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_AGENT"	{ yylval->ival = PARCEL_MEDIA_COMMAND_AGENT; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_UNLOAD"	{ yylval->ival = PARCEL_MEDIA_COMMAND_UNLOAD; return(INTEGER_CONSTANT); }
"PARCEL_MEDIA_COMMAND_AUTO_ALIGN"	{ yylval->ival = PARCEL_MEDIA_COMMAND_AUTO_ALIGN; return(INTEGER_CONSTANT); }

"PAY_HIDE"          { yylval->ival = LSL_PAY_HIDE; return(INTEGER_CONSTANT); }
"PAY_DEFAULT"       { yylval->ival = LSL_PAY_DEFAULT; return(INTEGER_CONSTANT); }

"PARCEL_FLAG_ALLOW_FLY" { yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_ALLOW_SCRIPTS" { yylval->ival = 0x2; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_ALLOW_LANDMARK" { yylval->ival = 0x8; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_ALLOW_TERRAFORM" { yylval->ival = 0x10; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_ALLOW_DAMAGE" { yylval->ival = 0x20; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_ALLOW_CREATE_OBJECTS" { yylval->ival = 0x40; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_USE_ACCESS_GROUP" { yylval->ival = 0x100; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_USE_ACCESS_LIST" { yylval->ival = 0x200; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_USE_BAN_LIST" { yylval->ival = 0x400; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_USE_LAND_PASS_LIST" { yylval->ival = 0x800; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_LOCAL_SOUND_ONLY" { yylval->ival = 0x8000; return(INTEGER_CONSTANT); }
"PARCEL_FLAG_RESTRICT_PUSHOBJECT" { yylval->ival = 0x200000; return(INTEGER_CONSTANT); }

"PARCEL_COUNT_TOTAL" { yylval->ival = 0x0; return(INTEGER_CONSTANT); }
"PARCEL_COUNT_OWNER" { yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"PARCEL_COUNT_GROUP" { yylval->ival = 0x2; return(INTEGER_CONSTANT); }
"PARCEL_COUNT_OTHER" { yylval->ival = 0x3; return(INTEGER_CONSTANT); }
"PARCEL_COUNT_SELECTED" { yylval->ival = 0x4; return(INTEGER_CONSTANT); }
"PARCEL_COUNT_TEMP" { yylval->ival = 0x5; return(INTEGER_CONSTANT); }

"PARCEL_DETAILS_NAME" { yylval->ival = 0x0; return(INTEGER_CONSTANT); }
"PARCEL_DETAILS_DESC" { yylval->ival = 0x1; return(INTEGER_CONSTANT); }
"PARCEL_DETAILS_OWNER" { yylval->ival = 0x2; return(INTEGER_CONSTANT); }
"PARCEL_DETAILS_GROUP" { yylval->ival = 0x3; return(INTEGER_CONSTANT); }
"PARCEL_DETAILS_AREA" { yylval->ival = 0x4; return(INTEGER_CONSTANT); }

"STRING_TRIM_HEAD" { yylval->ival = 0x01; return (INTEGER_CONSTANT); }
"STRING_TRIM_TAIL" { yylval->ival = 0x02; return (INTEGER_CONSTANT); }
"STRING_TRIM" { yylval->ival = 0x03; return (INTEGER_CONSTANT); }

{L}({L}|{N})*		{ yylval->sval = new char[strlen(yytext) + 1]; strcpy(yylval->sval, yytext); return(IDENTIFIER); }

[-]?{D}+{E}					{ yylval->fval = (F32)atof(yytext); return(FP_CONSTANT); }
[-]?{D}*"."{D}+({E})?{FS}?	{ yylval->fval = (F32)atof(yytext); return(FP_CONSTANT); }
[-]?{D}+"."{D}*({E})?{FS}?	{ yylval->fval = (F32)atof(yytext); return(FP_CONSTANT); }

L?\"(\\.|[^\\"])*\"	{ yylval->sval = parse_string(yytext); return(STRING_CONSTANT); }

"++"				{ return(INC_OP); }
"--"				{ return(DEC_OP); }
"+="				{ return(ADD_ASSIGN); }
"-="				{ return(SUB_ASSIGN); }
"*="				{ return(MUL_ASSIGN); }
"/="				{ return(DIV_ASSIGN); }
"%="				{ return(MOD_ASSIGN); }
";"					{ return(';'); }
"{"					{ return('{'); }
"}"					{ return('}'); }
","					{ return(','); }
"="					{ return('='); }
"("					{ return('('); }
")"					{ return(')'); }
"-"					{ return('-'); }
"+"					{ return('+'); }
"*"					{ return('*'); }
"/"					{ return('/'); }
"%"					{ return('%'); }
"@"					{ return('@'); }
":"					{ return(':'); }
">"					{ return('>'); }
"<"					{ return('<'); }
"]"					{ return(']'); }
"["					{ return('['); }
"=="				{ return(EQ);  }
"!="				{ return(NEQ);  }
">="				{ return(GEQ);  }
"<="				{ return(LEQ);  }
"&"					{ return('&');  }
"|"					{ return('|');  }
"^"					{ return('^');  }
"~"					{ return('~');  }
"!"					{ return('!');  }
"&&"				{ return(BOOLEAN_AND);	}
"||"				{ return(BOOLEAN_OR);	}
"<<"				{ return(SHIFT_LEFT);  }
">>"				{ return(SHIFT_RIGHT); }


\n                  { LLOC_LINES(1); LLOC_STEP(); } 
.					{ LLOC_STEP(); /* ignore bad characters */ }

%%

char *parse_string(char *input) {
  char *str = new char[strlen(input) + 1 - 2];
  char *yp  = input + 1;
  char *sp  = str;
  while ( *yp ) {
    if ( *yp == '\\' ) {
      switch ( *++yp ) { 
          case 'n':  *sp++ = '\n'; break;
          case 't':  *sp++ = '\t'; break; // TODO: should this be \t or 4 spaces?
          case '\\': *sp++ = '\\'; break;
          case '"':  *sp++ = '"';  break;
          default:   *sp++ = '\\'; *sp++ = *yp; break;
      }
      yp++;
    } else {
      *sp++ = *yp++;
    }
  }
  *--sp = 0;
  return str;
}

