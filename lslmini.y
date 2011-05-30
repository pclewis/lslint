%{
    #include "lslmini.hh"
    #include "logger.hh"
    #include <stdio.h>
    #include <string.h>
    //int yylex(YYSTYPE *yylval_param, YYLTYPE *yylloc_param);
    extern int yylex (YYSTYPE * yylval_param,YYLTYPE * yylloc_param , void *yyscanner);

    LLScriptScript *script;
    int yyerror( YYLTYPE*, void *, const char * );
    #define MAKEID(type,id,pos) new LLScriptIdentifier(TYPE(type), (id), &(pos))
    #define EVENTERR(type,prototype) new LLScriptEvent((type), 0); LOG( LOG_CONTINUE, NULL, "event prototype must match: " # prototype);


    #define LSLINT_STACK_OVERFLOW_AT 150
    inline int _yylex( YYSTYPE * yylval, YYLTYPE *yylloc, void *yyscanner, int stack ) {
        if ( stack == LSLINT_STACK_OVERFLOW_AT ) {
            ERROR( yylloc, E_PARSER_STACK_DEPTH );
        }
        return yylex( yylval, yylloc, yyscanner );
    }
    #define yylex(a,b,c) _yylex(a, b, c,  (int)(yyssp - yyss))
        

    // Same as bison's default, but update global position so we don't have
    // to pass it in every time we make a branch
    # define YYLLOC_DEFAULT(Current, Rhs, N)                \
        ((Current).first_line   = (Rhs)[1].first_line,       \
         (Current).first_column = (Rhs)[1].first_column,     \
         (Current).last_line    = (Rhs)[N].last_line,        \
         (Current).last_column  = (Rhs)[N].last_column,      \
         LLASTNode::set_glloc(&(Current)))

%}

%error-verbose
%locations
%pure-parser
%parse-param { void *scanner }
%lex-param { void *scanner }

%union
{
	S32								ival;
	F32								fval;
	char							*sval;
	class LLScriptType				*type;
	class LLScriptConstant			*constant;
	class LLScriptIdentifier		*identifier;
	class LLScriptSimpleAssignable	*assignable;
	class LLScriptGlobalVariable	*global;
	class LLScriptEvent				*event;
	class LLScriptEventHandler		*handler;
	class LLScriptExpression		*expression;
	class LLScriptStatement			*statement;
	class LLScriptGlobalFunction	*global_funcs;
	class LLScriptFunctionDec		*global_decl;
	class LLScriptState				*state;
	class LLScriptGlobalStorage		*global_store;
	class LLScriptScript			*script;
};


%token					INTEGER
%token					FLOAT_TYPE
%token					STRING
%token					LLKEY
%token					VECTOR
%token					QUATERNION
%token					LIST

%token					STATE_DEFAULT
%token					STATE
%token					EVENT
%token					JUMP
%token					RETURN

%token					STATE_ENTRY
%token					STATE_EXIT
%token					TOUCH_START
%token					TOUCH
%token					TOUCH_END
%token					COLLISION_START
%token					COLLISION
%token					COLLISION_END
%token					LAND_COLLISION_START
%token					LAND_COLLISION
%token					LAND_COLLISION_END
%token					TIMER
%token					CHAT
%token					SENSOR
%token					NO_SENSOR
%token					CONTROL
%token					AT_TARGET
%token					NOT_AT_TARGET
%token					AT_ROT_TARGET
%token					NOT_AT_ROT_TARGET
%token					MONEY
%token					EMAIL
%token					RUN_TIME_PERMISSIONS
%token					INVENTORY
%token					ATTACH
%token					DATASERVER
%token					MOVING_START
%token					MOVING_END
%token					REZ
%token					OBJECT_REZ
%token					LINK_MESSAGE
%token					REMOTE_DATA
%token                  HTTP_RESPONSE

%token <sval>			IDENTIFIER
%token <sval>			STATE_DEFAULT

%token <ival>			INTEGER_CONSTANT
%token <ival>			INTEGER_TRUE
%token <ival>			INTEGER_FALSE

%token <fval>			FP_CONSTANT

%token <sval>			STRING_CONSTANT

%token					INC_OP
%token					DEC_OP
%token					ADD_ASSIGN
%token					SUB_ASSIGN
%token					MUL_ASSIGN
%token					DIV_ASSIGN
%token					MOD_ASSIGN

%token					EQ
%token					NEQ
%token					GEQ
%token					LEQ

%token					BOOLEAN_AND
%token					BOOLEAN_OR

%token					SHIFT_LEFT
%token					SHIFT_RIGHT

%token					IF
%token					ELSE
%token					FOR
%token					DO
%token					WHILE

%token					PRINT

%token					PERIOD

%token					ZERO_VECTOR
%token					ZERO_ROTATION

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%type <script>			lscript_program
%type <global_store>	globals
%type <global_store>	global
%type <global>			global_variable
%type <assignable>		simple_assignable
%type <assignable>		simple_assignable_no_list
%type <constant>		constant
%type <assignable>		special_constant
%type <assignable>		vector_constant
%type <assignable>		quaternion_constant
%type <assignable>		list_constant
%type <assignable>		list_entries
%type <assignable>		list_entry
%type <type>			typename
%type <global_funcs>	global_function
%type <global_decl>		function_parameters
%type <global_decl>		function_parameter
%type <state>			states
%type <state>			other_states
%type <state>			default
%type <state>			state
%type <handler>			state_body
%type <handler>			event
%type <event>			state_entry
%type <event>			state_exit
%type <event>			touch_start
%type <event>			touch
%type <event>			touch_end
%type <event>			collision_start
%type <event>			collision
%type <event>			collision_end
%type <event>			land_collision_start
%type <event>			land_collision
%type <event>			land_collision_end
%type <event>			at_target
%type <event>			not_at_target
%type <event>			at_rot_target
%type <event>			not_at_rot_target
%type <event>			money
%type <event>			email
%type <event>			run_time_permissions
%type <event>			inventory
%type <event>			attach
%type <event>			dataserver
%type <event>			moving_start
%type <event>			moving_end
%type <event>			rez
%type <event>			object_rez
%type <event>			remote_data
%type <event>			link_message
%type <event>			timer
%type <event>			chat
%type <event>			sensor
%type <event>			no_sensor
%type <event>			control
%type <event>           http_response
%type <statement>		compound_statement
%type <statement>		statement
%type <statement>		statements
%type <statement>		declaration
%type <statement>		';'
%type <statement>		'@'
%type <expression>		nextforexpressionlist
%type <expression>		forexpressionlist
%type <expression>		nextfuncexpressionlist
%type <expression>		funcexpressionlist
%type <expression>		nextlistexpressionlist
%type <expression>		listexpressionlist
%type <expression>		unarypostfixexpression
%type <expression>		vector_initializer
%type <expression>		quaternion_initializer
%type <expression>		list_initializer
%type <expression>		lvalue
%type <expression>		'-'
%type <expression>		'!'
%type <expression>		'~'
%type <expression>		'='
%type <expression>		'<'
%type <expression>		'>'
%type <expression>		'+'
%type <expression>		'*'
%type <expression>		'/'
%type <expression>		'%'
%type <expression>		'&'
%type <expression>		'|'
%type <expression>		'^'
%type <expression>		ADD_ASSIGN
%type <expression>		SUB_ASSIGN
%type <expression>		MUL_ASSIGN
%type <expression>		DIV_ASSIGN
%type <expression>		MOD_ASSIGN
%type <expression>		EQ
%type <expression>		NEQ
%type <expression>		LEQ
%type <expression>		GEQ
%type <expression>		BOOLEAN_AND
%type <expression>		BOOLEAN_OR
%type <expression>		SHIFT_LEFT
%type <expression>		SHIFT_RIGHT
%type <expression>		INC_OP
%type <expression>		DEC_OP
%type <expression>		'('
%type <expression>		')'
%type <expression>		PRINT
%type <identifier>		name_type
%type <expression>		expression
%type <expression>		unaryexpression
%type <expression>		typecast

%right '=' MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN
%left 	BOOLEAN_AND BOOLEAN_OR
%left	'|'
%left	'^'
%left	'&'
%left	EQ NEQ
%left	'<' LEQ '>' GEQ
%left	SHIFT_LEFT SHIFT_RIGHT
%left 	'+' '-'
%left	'*' '/' '%'
%right	'!' '~' INC_OP DEC_OP
%nonassoc INITIALIZER

%%

lscript_program
	: globals states		
	{
    script = new LLScriptScript($1, $2);
	}
	| states		
	{
    script = new LLScriptScript(NULL, $1);
	}
	;
	
globals
	: global																
	{
    DEBUG( LOG_DEBUG_SPAM, NULL, "** global\n");
    $$ = $1;
	}
	| global globals
	{
    if ( $1 ) {
        DEBUG( LOG_DEBUG_SPAM, NULL, "** global [%p,%p] globals [%p,%p]\n", $1->get_prev(), $1->get_next(), $2->get_prev(), $2->get_next());
        $1->add_next_sibling($2);
        $$ = $1;
    } else {
        $$ = $2;
    }
	}
	;

global
	: global_variable
	{
    $$ = new LLScriptGlobalStorage($1, NULL);
	}
	| global_function
	{
    $$ = new LLScriptGlobalStorage(NULL, $1);
	}
	;
	
name_type
	: typename IDENTIFIER
	{
    $$ = new LLScriptIdentifier($1, $2, &@2);
	}
	;

global_variable
	: name_type ';'	
	{
    $$ = new LLScriptGlobalVariable($1, NULL);
	}
	| name_type '=' simple_assignable ';'
	{
    $$ = new LLScriptGlobalVariable($1, $3);
	}
    | name_type '=' expression ';'
    {
    ERROR(&@3, E_GLOBAL_INITIALIZER_NOT_CONSTANT);
    $$ = NULL;
    }
    | name_type '=' error ';'
    {
    $$ = NULL;
    }
	;

simple_assignable
	: simple_assignable_no_list
	{
    $$ = $1;
	}
	| list_constant
	{
    $$ = $1;
	}
	;

simple_assignable_no_list
	: IDENTIFIER																	
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptIdentifier($1));
	}
	| constant																		
	{
    $$ = new LLScriptSimpleAssignable($1);
	}
	| special_constant	
	{
    $$ = $1; //new LLScriptSimpleAssignable($1);
	}
	;

constant
	: INTEGER_CONSTANT																
	{
    $$ = new LLScriptIntegerConstant($1);
	}
	| INTEGER_TRUE																	
	{
    $$ = new LLScriptIntegerConstant($1);
	}
	| INTEGER_FALSE																	
	{
    $$ = new LLScriptIntegerConstant($1);
	}
	| FP_CONSTANT																	
	{
    $$ = new LLScriptFloatConstant($1);
	}
	| STRING_CONSTANT
	{
    $$ = new LLScriptStringConstant($1);
	}
	;

special_constant
	: vector_constant
	{
    $$ = $1;
	}
	| quaternion_constant
	{
    $$ = $1;
	}
	;

vector_constant
	: '<' simple_assignable ',' simple_assignable ',' simple_assignable '>'
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptVectorConstant($2, $4, $6));
	}
	| ZERO_VECTOR
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptVectorConstant(0.0, 0.0, 0.0));
	}
	;
	
quaternion_constant
	: '<' simple_assignable ',' simple_assignable ',' simple_assignable ',' simple_assignable '>'
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptQuaternionConstant($2, $4, $6, $8));
	}
	| ZERO_ROTATION
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptQuaternionConstant(0.0, 0.0, 0.0, 0.0));
	}
	;

list_constant
	: '[' list_entries ']'
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptListConstant($2));
	}
	| '[' ']'
	{
    $$ = new LLScriptSimpleAssignable(new LLScriptListConstant((LLScriptSimpleAssignable*)NULL));
	}
	;

list_entries
	: list_entry																	
	{
    $$ = $1;
	}
	| list_entry ',' list_entries
	{
    if ( $1 ) {
        $1->add_next_sibling($3);
        $$ = $1;
    } else {
        $$ = $3;
    }
	}
	;

list_entry
	: simple_assignable_no_list
	{
    $$ = $1;
	}
	;	

typename
	: INTEGER																		
	{
    $$ = TYPE(LST_INTEGER);
	}
	| FLOAT_TYPE																			
	{
    $$ = TYPE(LST_FLOATINGPOINT);
	}
	| STRING																		
	{  
    $$ = TYPE(LST_STRING);
	}
	| LLKEY																		
	{  
    $$ = TYPE(LST_KEY);
	}
	| VECTOR																		
	{  
    $$ = TYPE(LST_VECTOR);
	}
	| QUATERNION																	
	{  
    $$ = TYPE(LST_QUATERNION);
	}
	| LIST																			
	{
    $$ = TYPE(LST_LIST);
	}
	;
	
global_function
	: IDENTIFIER '(' ')' compound_statement
	{  
    $$ = new LLScriptGlobalFunction( MAKEID(LST_NULL, $1, @1), NULL, $4 );
	}
	| name_type '(' ')' compound_statement
	{
    $$ = new LLScriptGlobalFunction( $1, NULL, $4 );
	}
	| IDENTIFIER '(' function_parameters ')' compound_statement
	{
    $$ = new LLScriptGlobalFunction( MAKEID(LST_NULL, $1, @1), $3, $5 );
	}
	| name_type '(' function_parameters ')' compound_statement
	{  
    $$ = new LLScriptGlobalFunction( $1, $3, $5 );
	}
	;
	
function_parameters
	: function_parameter															
	{  
    $$ = $1;
	}
	| function_parameter ',' function_parameters									
	{  
      if ( $1 ) {
          $1->push_child($3->get_children());
          delete $3;
          $$ = $1;
      } else {
          $$ = $3;
      }
	}
	;
	
function_parameter
	: typename IDENTIFIER															
	{  
    $$ = new LLScriptFunctionDec( new LLScriptIdentifier($1, $2, &@2) );
	}
	;

states
	: default																		
	{  
    $$ = $1;
	}
	| default other_states
	{  
    if ( $1 ) {
        DEBUG( LOG_DEBUG_SPAM, NULL, "---- default [%p,%p] other_states [%p,%p]\n", $1->get_prev(), $1->get_next(), $2->get_prev(), $2->get_next());
        $1->add_next_sibling($2);
        $$ = $1;
    } else {
        $$ = $2;
    }
	}
	;
	
other_states
	: state																			
	{  
    //DEBUG(200,"--(%d)-- state\n", yylloc.first_line);
    $$ = $1;
	}
	| state other_states 															
	{  
    //DEBUG(200,"--(%d)-- state other_states\n", yylloc.first_line);
    if ( $1 ) {
        $1->add_next_sibling($2);
        $$ = $1;
    } else {
        $$ = $2;
    }
	}
	;
	
default
	: STATE_DEFAULT '{' state_body '}'													
	{  
    $$ = new LLScriptState( NULL, $3 );
	}
    | STATE_DEFAULT '{' '}'
    {
    ERROR( &@1, E_NO_EVENT_HANDLERS );
    $$ = new LLScriptState( NULL, NULL );
    }
	;
	
state
	: STATE IDENTIFIER '{' state_body '}'											
	{  
    $$ = new LLScriptState( MAKEID(LST_NULL, $2, @2), $4 );
	}
    | STATE IDENTIFIER '{' '}'
    {
    ERROR( &@1, E_NO_EVENT_HANDLERS );
    $$ = new LLScriptState( NULL, NULL );
    }
	;
	
state_body	
	: event																			
	{  
    $$ = $1;
	}
	| event state_body															
	{  
    if ( $1 ) {
        $1->add_next_sibling($2);
        $$ = $1;
    } else {
        $$ = $2;
    }
	}
	;
	
event
	: state_entry compound_statement												
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| state_exit compound_statement													
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| touch_start compound_statement												
	{
    $$ = new LLScriptEventHandler($1, $2);
	}
	| touch compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| touch_end compound_statement													
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| collision_start compound_statement											
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| collision compound_statement													
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| collision_end compound_statement												
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| land_collision_start compound_statement											
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| land_collision compound_statement													
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| land_collision_end compound_statement												
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| timer compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| chat compound_statement														
	{
    $$ = new LLScriptEventHandler($1, $2);
	}
	| sensor compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| no_sensor compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| at_target compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| not_at_target compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| at_rot_target compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| not_at_rot_target compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| money compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| email compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| run_time_permissions compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| inventory compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| attach compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| dataserver compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| control compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| moving_start compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| moving_end compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| rez compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| object_rez compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| link_message compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
	| remote_data compound_statement														
	{  
    $$ = new LLScriptEventHandler($1, $2);
	}
    | http_response compound_statement
    {
    $$ = new LLScriptEventHandler($1, $2);
    }
	;
	
state_entry
	: STATE_ENTRY '(' ')'															
	{  
    $$ = new LLScriptEvent(EVENT_STATE_ENTRY, 0);
	}
    | STATE_ENTRY '(' error ')'
    {
    $$ = EVENTERR( EVENT_STATE_ENTRY, "state_entry()");
    }
	;

state_exit
	: STATE_EXIT '(' ')'															
	{  
    $$ = new LLScriptEvent(EVENT_STATE_EXIT, 0);
	}
    | STATE_EXIT '(' error ')'
    {
    $$ = EVENTERR( EVENT_STATE_EXIT, "state_exit()");
    }
	;

touch_start
	: TOUCH_START '(' INTEGER IDENTIFIER ')'					
	{  
    $$ = new LLScriptEvent(EVENT_TOUCH_START, 1, MAKEID(LST_INTEGER, $4, @4) );
	}
    | TOUCH_START '(' error ')'
    {
    $$ = EVENTERR( EVENT_TOUCH_START, "touch_start(integer)");
    }
	;

touch
	: TOUCH '(' INTEGER IDENTIFIER ')'					
	{  
    $$ = new LLScriptEvent(EVENT_TOUCH, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | TOUCH '(' error ')'
    {
    $$ = EVENTERR( EVENT_TOUCH, "touch(integer)");
    }
	;

touch_end
	: TOUCH_END '(' INTEGER IDENTIFIER ')'					
	{  
    $$ = new LLScriptEvent(EVENT_TOUCH_END, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | TOUCH_END '(' error ')'
    {
    $$ = EVENTERR( EVENT_TOUCH_END, "touch_end(integer)");
    }
	;

collision_start
	: COLLISION_START '(' INTEGER IDENTIFIER ')'					
	{  
    $$ = new LLScriptEvent(EVENT_COLLISION_START, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | COLLISION_START '(' error ')'
    {
    $$ = EVENTERR( EVENT_COLLISION_START, "collision_start(integer)");
    }
	;

collision
	: COLLISION '(' INTEGER IDENTIFIER ')'					
	{  
    $$ = new LLScriptEvent(EVENT_COLLISION, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | COLLISION '(' error ')'
    {
    $$ = EVENTERR( EVENT_COLLISION, "collision(integer)");
    }
	;

collision_end
	: COLLISION_END '(' INTEGER IDENTIFIER ')'					
	{  
    $$ = new LLScriptEvent(EVENT_COLLISION_END, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | COLLISION_END '(' error ')'
    {
    $$ = EVENTERR( EVENT_COLLISION_END, "collision_end(integer)");
    }
	;

land_collision_start
	: LAND_COLLISION_START '(' VECTOR IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_LAND_COLLISION_START, 1, MAKEID(LST_VECTOR, $4, @4));
	}
    | LAND_COLLISION_START '(' error ')'
    {
    $$ = EVENTERR( EVENT_LAND_COLLISION_START, "land_collision_start(vector)");
    }
	;

land_collision
	: LAND_COLLISION '(' VECTOR IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_LAND_COLLISION, 1, MAKEID(LST_VECTOR, $4, @4));
	}
    | LAND_COLLISION '(' error ')'
    {
    $$ = EVENTERR( EVENT_LAND_COLLISION, "land_collision(vector)");
    }
	;

land_collision_end
	: LAND_COLLISION_END '(' VECTOR IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_LAND_COLLISION_END, 1, MAKEID(LST_VECTOR, $4, @4));
	}
    | LAND_COLLISION_END '(' error ')'
    {
    $$ = EVENTERR( EVENT_LAND_COLLISION_END, "land_collision_end(vector)");
    }
	;

at_target
	: AT_TARGET '(' INTEGER IDENTIFIER ',' VECTOR IDENTIFIER ',' VECTOR IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_AT_TARGET, 3, MAKEID(LST_INTEGER, $4, @4), MAKEID(LST_VECTOR, $7, @7), MAKEID(LST_VECTOR, $10, @10));
	}
    | AT_TARGET '(' error ')'
    {
    $$ = EVENTERR( EVENT_AT_TARGET, "at_target(integer, vector, vector)");
    }
	;

not_at_target
	: NOT_AT_TARGET '(' ')'															
	{  
    $$ = new LLScriptEvent(EVENT_NOT_AT_TARGET, 0);
	}
    | NOT_AT_TARGET '(' error ')'
    {
    $$ = EVENTERR( EVENT_NOT_AT_TARGET, "not_at_target()" );
    }
	;

at_rot_target
	: AT_ROT_TARGET '(' INTEGER IDENTIFIER ',' QUATERNION IDENTIFIER ',' QUATERNION IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_AT_ROT_TARGET, 3, MAKEID(LST_INTEGER, $4, @4), MAKEID(LST_QUATERNION, $7, @7), MAKEID(LST_QUATERNION, $10, @10));
	}
    | AT_ROT_TARGET '(' error ')'
    {
    $$ = EVENTERR( EVENT_AT_ROT_TARGET, "at_rot_target(integer, rotation, rotation)");
    }
	;

not_at_rot_target
	: NOT_AT_ROT_TARGET '(' ')'															
	{  
    $$ = new LLScriptEvent(EVENT_NOT_AT_ROT_TARGET, 0);
	}
    | NOT_AT_ROT_TARGET '(' error ')'
    {
    $$ = EVENTERR( EVENT_NOT_AT_ROT_TARGET, "not_at_rot_target()" );
    }
	;

money
	: MONEY '(' LLKEY IDENTIFIER ',' INTEGER IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_MONEY, 2, MAKEID(LST_KEY, $4, @4), MAKEID(LST_INTEGER, $7, @7));
	}
    | MONEY '(' error ')'
    {
    $$ = EVENTERR( EVENT_MONEY, "money(key, integer)" );
    }
	;

email
	: EMAIL '(' STRING IDENTIFIER ',' STRING IDENTIFIER ',' STRING IDENTIFIER ',' STRING IDENTIFIER ',' INTEGER IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_EMAIL, 5, MAKEID(LST_STRING, $4, @4), MAKEID(LST_STRING, $7, @7), MAKEID(LST_STRING, $10, @10), MAKEID(LST_STRING, $13, @13), MAKEID(LST_INTEGER, $16, @16));
	}
    | EMAIL '(' error ')'
    {
    $$ = EVENTERR( EVENT_EMAIL, "email(string, string, string, string, integer)" );
    }
	;

run_time_permissions
	: RUN_TIME_PERMISSIONS '(' INTEGER IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_RUN_TIME_PERMISSIONS, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | RUN_TIME_PERMISSIONS '(' error ')'
    {
    $$ = EVENTERR( EVENT_RUN_TIME_PERMISSIONS, "run_time_permissions(integer)" );
    }
	;

inventory /* changed() */
	: INVENTORY '(' INTEGER IDENTIFIER ')'																	
	{  
    $$ = new LLScriptEvent(EVENT_INVENTORY, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | INVENTORY '(' error ')'
    {
    $$ = EVENTERR( EVENT_INVENTORY, "changed(integer)" );
    }
	;

attach
	: ATTACH '(' LLKEY IDENTIFIER ')'																	
	{  
    $$ = new LLScriptEvent(EVENT_ATTACH, 1, MAKEID(LST_KEY, $4, @4));
	}
    | ATTACH '(' error ')'
    {
    $$ = EVENTERR( EVENT_ATTACH, "attach(key)" );
    }
	;

dataserver
	: DATASERVER '(' LLKEY IDENTIFIER ',' STRING IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_DATASERVER, 2, MAKEID(LST_KEY, $4, @4), MAKEID(LST_STRING, $7, @7));
	}
    | DATASERVER '(' error ')'
    {
    $$ = EVENTERR( EVENT_DATASERVER, "dataserver(key, string)" );
    }
	;

moving_start
	: MOVING_START '(' ')'																	
	{  
    $$ = new LLScriptEvent(EVENT_MOVING_START, 0);
	}
    | MOVING_START '(' error ')'
    {
    $$ = EVENTERR( EVENT_MOVING_START, "moving_start()" );
    }
	;

moving_end
	: MOVING_END '(' ')'																	
	{  
    $$ = new LLScriptEvent(EVENT_MOVING_END, 0);
	}
    | MOVING_END '(' error ')'
    {
    $$ = EVENTERR( EVENT_MOVING_END, "moving_end()" );
    }
	;

timer
	: TIMER '(' ')'																	
	{  
    $$ = new LLScriptEvent(EVENT_TIMER, 0);
	}
    | TIMER '(' error ')'
    {
    $$ = EVENTERR( EVENT_TIMER, "timer()" );
    }
	;

chat /* listen() */
	: CHAT '(' INTEGER IDENTIFIER ',' STRING IDENTIFIER ',' LLKEY IDENTIFIER ',' STRING IDENTIFIER ')'							
	{  
    $$ = new LLScriptEvent(EVENT_LISTEN, 4, MAKEID(LST_INTEGER, $4, @4), MAKEID(LST_STRING, $7, @7), MAKEID(LST_KEY, $10, @10), MAKEID(LST_STRING, $13, @13));
	}
    | CHAT '(' error ')'
    {
    $$ = EVENTERR( EVENT_LISTEN, "listen(integer, string, key, string)" );
    }
	;

sensor
	: SENSOR '(' INTEGER IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_SENSOR, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | SENSOR '(' error ')'
    {
    $$ = EVENTERR( EVENT_SENSOR, "sensor(integer)" );
    }
	;

no_sensor
	: NO_SENSOR '(' ')'															
	{  
    $$ = new LLScriptEvent(EVENT_NO_SENSOR, 0);
	}
    | NO_SENSOR '(' error ')'
    {
    $$ = EVENTERR( EVENT_NO_SENSOR, "no_sensor()" );
    }
	;

control
	: CONTROL '(' LLKEY IDENTIFIER ',' INTEGER IDENTIFIER ',' INTEGER IDENTIFIER ')'	
	{  
    $$ = new LLScriptEvent(EVENT_CONTROL, 3, MAKEID(LST_KEY, $4, @4), MAKEID(LST_INTEGER, $7, @7), MAKEID(LST_INTEGER, $10, @10));
	}
    | CONTROL '(' error ')'
    {
    $$ = EVENTERR( EVENT_CONTROL, "control(key, integer, integer)") ;
    }
	;

rez /* on_rez() */
	: REZ '(' INTEGER IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_REZ, 1, MAKEID(LST_INTEGER, $4, @4));
	}
    | REZ '(' error ')'
    {
    $$ = EVENTERR( EVENT_REZ, "on_rez(integer)" );
    }
	;

object_rez
	: OBJECT_REZ '(' LLKEY IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_OBJECT_REZ, 1, MAKEID(LST_KEY, $4, @4) );
	}
    | OBJECT_REZ '(' error ')'
    {
    $$ = EVENTERR( EVENT_OBJECT_REZ, "object_rez(key)" );
    }
	;

link_message
	: LINK_MESSAGE '(' INTEGER IDENTIFIER ','  INTEGER IDENTIFIER ',' STRING IDENTIFIER ',' LLKEY IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_LINK_MESSAGE, 4, MAKEID(LST_INTEGER, $4, @4), MAKEID(LST_INTEGER, $7, @7), MAKEID(LST_STRING, $10, @10), MAKEID(LST_KEY, $13, @13));
	}
    | LINK_MESSAGE '(' error ')'
    {
    $$ = EVENTERR( EVENT_LINK_MESSAGE, "link_message(integer, integer, string, key)" );
    }
	;

remote_data
	: REMOTE_DATA '(' INTEGER IDENTIFIER ','  LLKEY IDENTIFIER ','  LLKEY IDENTIFIER ','  STRING IDENTIFIER ',' INTEGER IDENTIFIER ',' STRING IDENTIFIER ')'															
	{  
    $$ = new LLScriptEvent(EVENT_REMOTE_DATA, 6, MAKEID(LST_INTEGER, $4, @4), MAKEID(LST_KEY, $7, @7), MAKEID(LST_KEY, $10, @10), MAKEID(LST_STRING, $13, @13), MAKEID(LST_INTEGER, $16, @16), MAKEID(LST_STRING, $19, @19));
	}
    | REMOTE_DATA '(' error ')'
    {
    $$ = EVENTERR( EVENT_REMOTE_DATA, "remote_data(integer, key, key, string, integer, string)" );
    }
	;

http_response
    : HTTP_RESPONSE '(' LLKEY IDENTIFIER ',' INTEGER IDENTIFIER ',' LIST IDENTIFIER ',' STRING IDENTIFIER ')'
    {
    $$ = new LLScriptEvent( EVENT_HTTP_RESPONSE, 4, MAKEID(LST_KEY, $4, @4), MAKEID(LST_INTEGER, $7, @7), MAKEID(LST_LIST, $10, @10), MAKEID(LST_STRING, $13, @13) );
    }
    | HTTP_RESPONSE '(' error ')'
    {
    $$ = EVENTERR( EVENT_HTTP_RESPONSE, "http_response(key request_id, integer status, list metadata, string body)");
    }
    ;

compound_statement
	: '{' '}'																		
	{  
    $$ = new LLScriptStatement(0);
	}
	| '{' statements '}'															
	{  
    $$ = new LLScriptCompoundStatement($2);
	}
	;
	
statements
	: statement																		
	{  
    //DEBUG( LOG_DEBUG_SPAM, NULL, "statement %d\n", yylloc.first_line );
    $$ = $1;
	}
	| statements statement															
	{  
    if ( $1 ) {
        $1->add_next_sibling($2);
        $$ = $1;
    } else {
        $$ = $2;
    }
	}
	;
	
statement
	: ';'																			
	{  
    $$ = new LLScriptStatement(0);
	}
	| STATE IDENTIFIER ';'						
	{  
    $$ = new LLScriptStateStatement(MAKEID(LST_NULL, $2, @2));
	}
	| STATE STATE_DEFAULT ';'						
	{  
    $$ = new LLScriptStateStatement();
	}
	| JUMP IDENTIFIER ';'						
	{  
    $$ = new LLScriptJumpStatement(MAKEID(LST_NULL, $2, @2));
	}
	| '@' IDENTIFIER ';'						
	{  
    $$ = new LLScriptLabel(MAKEID(LST_NULL, $2, @2));
	}
	| RETURN expression ';'						
	{  
    $$ = new LLScriptReturnStatement($2);
	}
	| RETURN ';'								
	{  
    $$ = new LLScriptReturnStatement(NULL);
	}
	| expression ';'							
	{  
    $$ = new LLScriptStatement($1);
	}
	| declaration ';'
	{  
    $$ = $1;
	}
	| compound_statement						
	{ 
    $$ = $1;
	}
	| IF '(' expression ')' statement	%prec LOWER_THAN_ELSE			
	{  
    $$ = new LLScriptIfStatement($3, $5, NULL);
	}
	| IF '(' expression ')' statement ELSE statement					
	{  
    $$ = new LLScriptIfStatement($3, $5, $7);
	}
	| FOR '(' forexpressionlist ';' expression ';' forexpressionlist ')' statement	
	{  
    $$ = new LLScriptForStatement($3, $5, $7, $9);
	}
	| DO statement WHILE '(' expression ')' ';' 
	{  
    $$ = new LLScriptDoStatement($2, $5);
	}
	| WHILE '(' expression ')' statement		
	{  
    $$ = new LLScriptWhileStatement($3, $5);
	}
    | error ';'
    {
    $$ = new LLScriptStatement(0);
    }
	;
	
declaration
	: typename IDENTIFIER						
	{  
    $$ = new LLScriptDeclaration(new LLScriptIdentifier($1, $2, &@2), NULL);
	}
	| typename IDENTIFIER '=' expression		
	{  
    DEBUG( LOG_DEBUG_SPAM, NULL, "= %s\n", $4->get_node_name());
    $$ = new LLScriptDeclaration(new LLScriptIdentifier($1, $2, &@2), $4);
	}
	;

forexpressionlist
	: /* empty */								
	{  
    //$$ = new LLScriptExpression(0, NULL, NULL);
    $$ = NULL;
	}
	| nextforexpressionlist						
	{
    $$ = $1;
	}
	;

nextforexpressionlist
	: expression								
	{ 
    $$ = $1;
	}
	| expression ',' nextforexpressionlist		
	{
    if ( $1 ) {
        $1->add_next_sibling($3);
        $$ = $1;
    } else {
        $$ = $3;
    }
	}
	;

funcexpressionlist
	: /* empty */								
	{  
    //$$ = new LLScriptExpression(0);
    $$ = NULL;
	}
	| nextfuncexpressionlist						
	{
    $$ = $1;
	}
	;

nextfuncexpressionlist
	: expression								
	{  
    $$ = $1;
	}
	| expression ',' nextfuncexpressionlist		
	{
    if ( $1 ) {
        $1->add_next_sibling($3);
        $$ = $1;
    } else {
        $$ = $3;
    }
	}
	;

listexpressionlist
	: /* empty */								
	{  
    //$$ = new LLScriptExpression(0);
    //$$ = NULL;
    $$ = NULL;
	}
	| nextlistexpressionlist						
	{
    $$ = $1;
	}
	;

nextlistexpressionlist
	: expression								
	{  
    $$ = $1;
	}
	| expression ',' nextlistexpressionlist		
	{
    if ($1) {
        $1->add_next_sibling($3);
        $$ = $1;
    } else {
        $$ = $3;
    }
	}
	;

expression
	: unaryexpression							
	{  
    $$ = $1;
	}
	| lvalue '=' expression						
	{  
    $$ = new LLScriptExpression( $1, '=', $3 );
	}
	| lvalue ADD_ASSIGN expression				
	{  
    // TODO: clean these up
    $$ = new LLScriptExpression( $1,'=', new LLScriptExpression(new LLScriptLValueExpression(new LLScriptIdentifier((LLScriptIdentifier*)$1->get_child(0))), '+', $3) );
	}
	| lvalue SUB_ASSIGN expression				
	{  
    $$ = new LLScriptExpression( $1, '=', new LLScriptExpression(new LLScriptLValueExpression(new LLScriptIdentifier((LLScriptIdentifier*)$1->get_child(0))), '-', $3) );
	}
	| lvalue MUL_ASSIGN expression				
	{  
    $$ = new LLScriptExpression( $1, '=', new LLScriptExpression(new LLScriptLValueExpression(new LLScriptIdentifier((LLScriptIdentifier*)$1->get_child(0))), '*', $3) );
	}
	| lvalue DIV_ASSIGN expression				
	{  
    $$ = new LLScriptExpression( $1, '=', new LLScriptExpression(new LLScriptLValueExpression(new LLScriptIdentifier((LLScriptIdentifier*)$1->get_child(0))), '/', $3) );
	}
	| lvalue MOD_ASSIGN expression				
	{  
    $$ = new LLScriptExpression( $1, '=', new LLScriptExpression(new LLScriptLValueExpression(new LLScriptIdentifier((LLScriptIdentifier*)$1->get_child(0))), '%', $3) );
	}
	| expression EQ expression					
	{  
    $$ = new LLScriptExpression( $1, EQ, $3 );
	}
	| expression NEQ expression					
	{  
    $$ = new LLScriptExpression( new LLScriptExpression( $1, EQ, $3 ), '!' );
	}
	| expression LEQ expression					
	{  
    // if ( A <= B ) B > A
    $$ = new LLScriptExpression( $3, '>', $1 );
	}
	| expression GEQ expression					
	{  
    // if ( A >= B ) B < A
    $$ = new LLScriptExpression( $3, '<', $1 );
	}
	| expression '<' expression					
	{  
    $$ = new LLScriptExpression( $1, '<', $3 );
	}
	| expression '>' expression					
	{  
    $$ = new LLScriptExpression( $1, '>', $3 );
	}
	| expression '+' expression					
	{  
    $$ = new LLScriptExpression( $1, '+', $3 );
	}
	| expression '-' expression					
	{  
    $$ = new LLScriptExpression( $1, '-', $3 );
	}
	| expression '*' expression					
	{  
    $$ = new LLScriptExpression( $1, '*', $3 );
	}
	| expression '/' expression					
	{  
    $$ = new LLScriptExpression(  $1, '/',  $3  );
	}
	| expression '%' expression					
	{  
    $$ = new LLScriptExpression(  $1, '%',  $3  );
	}
	| expression '&' expression					
	{  
    $$ = new LLScriptExpression(  $1, '&',  $3  );
	}
	| expression '|' expression					
	{  
    $$ = new LLScriptExpression(  $1, '|',  $3  );
	}
	| expression '^' expression					
	{  
    $$ = new LLScriptExpression(  $1, '^',  $3  );
	}
	| expression BOOLEAN_AND expression			
	{  
    $$ = new LLScriptExpression(  $1, BOOLEAN_AND,  $3  );
	}
	| expression BOOLEAN_OR expression			
	{  
    $$ = new LLScriptExpression(  $1, BOOLEAN_OR,  $3  );
	}
	| expression SHIFT_LEFT expression
	{
    $$ = new LLScriptExpression(  $1, SHIFT_LEFT,  $3  );
	}
	| expression SHIFT_RIGHT expression
	{
    $$ = new LLScriptExpression(  $1, SHIFT_RIGHT,  $3  );
	}
    | expression INTEGER_CONSTANT
    {
    ERROR( &@2, E_NO_OPERATOR );
    if ( $2 < 0 ) { // if const is negative, assume they meant expr - const
        // - is included as part of the constant, so make sure to reverse it
        $$ = new LLScriptExpression( $1, '-', new LLScriptExpression( 1, new LLScriptIntegerConstant( - $2) ) );
    } else {
        $$ = NULL;
    }
    }
    | expression FP_CONSTANT
    {
    ERROR( &@2, E_NO_OPERATOR );
    if ( $2 < 0 ) {
        $$ = new LLScriptExpression( $1, '-', new LLScriptExpression( 1, new LLScriptFloatConstant( - $2) ) );
    } else {
        $$ = NULL;
    }
    }
     ;

unaryexpression
	: '-' expression						
	{  
    $$ = new LLScriptExpression( $2, '-' );
	}
	| '!' expression							
	{  
    $$ = new LLScriptExpression(  $2 , '!' );
	}
	| '~' expression							
	{  
    $$ = new LLScriptExpression(  $2 , '~' );
	}
	| INC_OP lvalue							
	{  
    $$ = new LLScriptExpression(  $2 , INC_OP );
	}
	| DEC_OP lvalue							
	{  
    $$ = new LLScriptExpression(  $2 , DEC_OP );
	}
	| typecast				
	{
    $$ = $1;
	}
	| unarypostfixexpression
	{  
    $$ = $1;
	}
	| '(' expression ')'						
	{  
    $$ = new LLScriptExpression($2, 0);
	}
    ;

typecast
	: '(' typename ')' lvalue				
	{
    $$ = new LLScriptTypecastExpression($2, $4);
	}
	| '(' typename ')' constant				
	{
    $$ = new LLScriptTypecastExpression($2, $4);
	}
	| '(' typename ')' unarypostfixexpression				
	{
    $$ = new LLScriptTypecastExpression($2, $4);
	}
	| '(' typename ')' '(' expression ')'				
	{
    $$ = new LLScriptTypecastExpression($2, $5);
	}
	;

unarypostfixexpression
	: vector_initializer 					
	{  
    DEBUG( LOG_DEBUG_SPAM, NULL, "vector intializer..");
    $$ = $1;
	}
	| quaternion_initializer					
	{
    $$ = $1;
	}
	| list_initializer							
	{  
    $$ = $1;
	}
	| lvalue									
	{  
    $$ = $1;
	}
	| lvalue INC_OP							
	{  
    $$ = new LLScriptExpression(  $1 , INC_OP );
	}
	| lvalue DEC_OP							
	{  
    $$ = new LLScriptExpression(  $1 , DEC_OP );
	}
	| IDENTIFIER '(' funcexpressionlist ')'			
	{  
    if ( $3 != NULL ) {
      $$ = new LLScriptFunctionExpression( new LLScriptIdentifier($1), $3 );
    } else {
      $$ = new LLScriptFunctionExpression( new LLScriptIdentifier($1) );
    }

	}
	| PRINT '(' expression ')'			
	{  
    /* FIXME: What does this do? */
	}
	| constant									
	{  
    $$ = new LLScriptExpression($1);
	}
	;

vector_initializer
	: '<' expression ',' expression ',' expression '>'	%prec INITIALIZER
	{
    $$ = new LLScriptVectorExpression($2, $4, $6);
	}
	| ZERO_VECTOR
	{
    $$ = new LLScriptVectorExpression();
	}
	;

quaternion_initializer
	: '<' expression ',' expression ',' expression ',' expression '>' %prec INITIALIZER
	{
    $$ = new LLScriptQuaternionExpression($2, $4, $6, $8);
	}
	| ZERO_ROTATION
	{
    $$ = new LLScriptQuaternionExpression();
	}
	;

list_initializer
	: '[' listexpressionlist ']' %prec INITIALIZER
	{  
    $$ = new LLScriptListExpression($2);
	}
	;

lvalue 
	: IDENTIFIER								
	{  
    $$ = new LLScriptLValueExpression(new LLScriptIdentifier($1));
	}
	| IDENTIFIER PERIOD IDENTIFIER
	{
    $$ = new LLScriptLValueExpression(new LLScriptIdentifier($1, $3));
	}
	;
		
%%

int yyerror( YYLTYPE *lloc, void *scanner, const char *message ) {
    ERROR( lloc, E_SYNTAX_ERROR, message );
    return 0;
}

