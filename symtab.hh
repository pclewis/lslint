#ifndef _SYMTAB_HH
#define _SYMTAB_HH 1

#include <vector>
#include "lslmini.tab.h"

enum LLSymbolType       { SYM_ANY = -1, SYM_VARIABLE, SYM_FUNCTION, SYM_STATE, SYM_LABEL, SYM_EVENT };
enum LLSymbolSubType    { SYM_LOCAL, SYM_GLOBAL, SYM_BUILTIN, SYM_FUNCTION_PARAMETER, SYM_EVENT_PARAMETER };

class LLScriptSymbol {
  public:
    LLScriptSymbol( char *name, class LLScriptType *type, LLSymbolType symbol_type, LLSymbolSubType sub_type, YYLTYPE *lloc, class LLScriptFunctionDec *function_decl = NULL )
      : name(name), type(type), symbol_type(symbol_type), sub_type(sub_type), lloc(*lloc), function_decl(function_decl),
      constant_value(NULL), references(0), assignments(0), cur_references(0) {};

    LLScriptSymbol( char *name, class LLScriptType *type, LLSymbolType symbol_type, LLSymbolSubType sub_type, class LLScriptFunctionDec *function_decl = NULL )
      : name(name), type(type), symbol_type(symbol_type), sub_type(sub_type), function_decl(function_decl),
      constant_value(NULL), references(0), assignments(0), cur_references(0) {};


    char                *get_name()         { return name; }
    class LLScriptType  *get_type()         { return type; }

    int                  get_references()   { return references; }
    int                  add_reference()    { return ++references; }
    int                  get_assignments()  { return assignments; }
    int                  add_assignment()   { return ++assignments; }

    LLSymbolType         get_symbol_type()  { return symbol_type; }
    LLSymbolSubType      get_sub_type()     { return sub_type;    }
    static char         *get_type_name(LLSymbolType t)    {
      switch (t) {
        case SYM_VARIABLE:  return "variable";
        case SYM_FUNCTION:  return "function";
        case SYM_STATE:     return "state";
        case SYM_LABEL:     return "label";
        case SYM_ANY:       return "any";
        default:            return "invalid";
      }
    }

    YYLTYPE             *get_lloc()         { return &lloc; }
    class LLScriptFunctionDec *get_function_decl() { return function_decl; }

    class LLScriptConstant *get_constant_value()                            { return constant_value;    };
    void                    set_constant_value(class LLScriptConstant *v)   { constant_value = v;       };

  private:
    char                *name;
    class LLScriptType  *type;
    LLSymbolType         symbol_type;
    LLSymbolSubType      sub_type;
    YYLTYPE              lloc;
    class LLScriptFunctionDec *function_decl;
    class LLScriptConstant *constant_value;
    int                  references;            // how many times this symbol is referred to
    int                  assignments;           // how many times it is assigned to
    int                  cur_references;        // how many times the current const_value was referred to
};

class LLScriptSymbolTable {
  public:
    LLScriptSymbol *lookup( char *name, LLSymbolType type = SYM_ANY, bool is_case_sensitive = true );
    void            define( LLScriptSymbol *symbol );
    void            check_symbols();

  private:
    // Vector to hold our symbols
    std::vector<LLScriptSymbol *>    symbols;

};

#endif /* not _SYMTAB_HH */
