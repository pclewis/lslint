%option bison-locations
%option bison-bridge
%option reentrant
%option noyywrap
%option nounput

%{
#include <stdlib.h>
#include "lslmini.hh"
#include "lslmini.tab.h"
//#include "llconstants.hh"

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

