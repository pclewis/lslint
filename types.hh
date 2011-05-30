#ifndef _TYPES_HH
#define _TYPES_HH 1
#include "ast.hh"           // LLASTNode
#include <vector>

#define TYPE(t) LLScriptType::get(t)    // convenience

enum LST_TYPE {
  LST_ERROR         = -1,   // special value so processing can continue without throwing bogus errors
  LST_NULL          = 0,
  LST_INTEGER       = 1,
  LST_FLOATINGPOINT = 2,
  LST_STRING        = 3,
  LST_KEY           = 4,
  LST_VECTOR        = 5,
  LST_QUATERNION    = 6,
  LST_LIST          = 7,    // ??
};

class LLScriptType : public LLASTNode {
  public:
    LLScriptType(LST_TYPE type) : LLASTNode(0), itype(type) {};
    static LLScriptType *get( LST_TYPE type ) {
      std::vector<LLScriptType*>::iterator i;
      LLScriptType *t;
      for ( i = types.begin(); i != types.end(); ++i ) {
        if ( (*i)->get_itype() == type ) return *i;
      }
      t = new LLScriptType(type);
      types.push_back( t );
      return t;
    }
    bool can_coerce( LLScriptType *to );
    LLScriptType *get_result_type(int op,  LLScriptType *right);

    int get_itype() { return itype; } ;
    virtual char *get_node_name() {
      switch (itype) {
        case LST_ERROR:         return "error";
        case LST_INTEGER:       return "integer";
        case LST_FLOATINGPOINT: return "float";
        case LST_STRING:        return "string";
        case LST_KEY:           return "key";
        case LST_VECTOR:        return "vector";
        case LST_QUATERNION:    return "quaternion";
        case LST_LIST:          return "list";
        case LST_NULL:          return "none";
        default:                return "!invalid!";
      }
    }
    virtual char *get_cil_type() {
      switch (itype) {
        case LST_ERROR:         throw "trying to gen code for error type!";
        case LST_INTEGER:       return "int32";
        case LST_FLOATINGPOINT: return "float32";
        case LST_STRING:        return "string";
        case LST_KEY:           return "string";
        case LST_VECTOR:        return "class [lsl]Vector";
        case LST_QUATERNION:    return "class [lsl]Quaternion";
        case LST_LIST:          return "class [lsl]List";
        default:                throw "request for type of non-storage type";
      }
    };
  private:
    LST_TYPE itype;
    static std::vector<LLScriptType *> types;
};

#endif /* not _TYPES_HH */
