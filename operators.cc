#include "lslmini.hh"

//////////////////////////////////////////////
// Integer Constants
LLScriptConstant *LLScriptIntegerConstant::operation(int operation, LLScriptConstant *other_const, YYLTYPE *lloc) {
   // unary op
   if ( other_const == NULL ) {
      int nv;
      switch (operation) {
         case INC_OP:  nv = value + 1; break;
         case DEC_OP:  nv = value - 1; break; 
         case '!':     nv = !value;    break;
         case '~':     nv = ~value;    break;
         case '-':     nv = -value;    break;
         default:      return NULL;
      }
      return new LLScriptIntegerConstant( nv );
   }

   // binary op
   switch (other_const->get_node_sub_type()) {
      case NODE_INTEGER_CONSTANT: {
                                     int ov = ((LLScriptIntegerConstant*)other_const)->get_value();
                                     int nv;
                                     switch (operation) {
                                        case '+':           nv = value + ov;    break;
                                        case '-':           nv = value - ov;    break;
                                        case '*':           nv = value * ov;    break;
                                        case '/':           nv = value / ov;    break;
                                        case '%':           nv = value % ov;    break;
                                        case '&':           nv = value & ov;    break;
                                        case '|':           nv = value | ov;    break;
                                        case '^':           nv = value ^ ov;    break;
                                        case '>':           nv = value > ov;    break;
                                        case '<':           nv = value < ov;    break;
                                        case SHIFT_LEFT:    nv = value << ov;   break;
                                        case SHIFT_RIGHT:   nv = value >> ov;   break;
                                        case BOOLEAN_AND:   nv = value && ov;   break;
                                        case BOOLEAN_OR:    nv = value || ov;   break;
                                        case EQ:            nv = value == ov;   break;
                                        default:            return NULL;
                                     }
                                     return new LLScriptIntegerConstant(nv);
                                  }
      case NODE_FLOAT_CONSTANT: {
                                   float ov = ((LLScriptFloatConstant*)other_const)->get_value();
                                   float nv;
                                   switch (operation) {
                                      case '+':           nv = value + ov;    break;
                                      case '-':           nv = value - ov;    break;
                                      case '*':           nv = value * ov;    break;
                                      case '/':           nv = value / ov;    break;
                                      case '>':           return new LLScriptIntegerConstant( value > ov );
                                      case '<':           return new LLScriptIntegerConstant( value < ov );
                                      case EQ:            return new LLScriptIntegerConstant( value == ov );
                                      default:            return NULL;
                                   }
                                   return new LLScriptFloatConstant(nv);
                                }
      default:
                                return NULL;
   }
}

//////////////////////////////////////////////
// Float Constants
LLScriptConstant *LLScriptFloatConstant::operation(int operation, LLScriptConstant *other_const, YYLTYPE *lloc) {
   // unary op
   if ( other_const == NULL ) {
      float nv;
      switch (operation) {
         case INC_OP:  nv = value + 1; break;
         case DEC_OP:  nv = value - 1; break; 
         case '-':     nv = -value;    break;
         default:      return NULL;
      }
      return new LLScriptFloatConstant( nv );
   }

   // binary op
   switch (other_const->get_node_sub_type()) {
      case NODE_INTEGER_CONSTANT: {
                                     int ov = ((LLScriptIntegerConstant*)other_const)->get_value();
                                     float nv;
                                     switch (operation) {
                                        case '+':           nv = value + ov;    break;
                                        case '-':           nv = value - ov;    break;
                                        case '*':           nv = value * ov;    break;
                                        case '/':           nv = value / ov;    break;
                                        case '>':           return new LLScriptIntegerConstant( value > ov );
                                        case '<':           return new LLScriptIntegerConstant( value < ov );
                                        case BOOLEAN_AND:   return new LLScriptIntegerConstant( value && ov );
                                        case BOOLEAN_OR:    return new LLScriptIntegerConstant( value || ov );
                                        case EQ:            return new LLScriptIntegerConstant( value == ov );
                                        default:            return NULL;
                                     }
                                     return new LLScriptFloatConstant(nv);
                                  }
      case NODE_FLOAT_CONSTANT: {
                                   float ov = ((LLScriptFloatConstant*)other_const)->get_value();
                                   float nv;
                                   switch (operation) {
                                      case '+':           nv = value + ov;    break;
                                      case '-':           nv = value - ov;    break;
                                      case '*':           nv = value * ov;    break;
                                      case '/':           nv = value / ov;    break;
                                      case '>':           return new LLScriptIntegerConstant( value > ov );
                                      case '<':           return new LLScriptIntegerConstant( value < ov );
                                      case EQ:            return new LLScriptIntegerConstant( value == ov );
                                      default:            return NULL;
                                   }
                                   return new LLScriptFloatConstant(nv);
                                }
      default:
                                return NULL;
   }
}

//////////////////////////////////////////////
// String Constants
inline char *join_string( char *left, char *right ) {
   char *ns = new char[ strlen(left) + strlen(right) + 1 ];
   strcpy( ns, left );
   strcat( ns, right );
   return ns;
}

LLScriptConstant *LLScriptStringConstant::operation(int operation, LLScriptConstant *other_const, YYLTYPE *lloc) {
   // unary op
   if ( other_const == NULL ) {
      return NULL;
   }

   // binary op
   switch (other_const->get_node_sub_type()) {
      case NODE_STRING_CONSTANT: {
                                    char *ov = ((LLScriptStringConstant*)other_const)->get_value();
                                    switch (operation) {
                                       case '+':           return new LLScriptStringConstant( join_string(value, ov) );
                                       case EQ:            return new LLScriptIntegerConstant( !strcmp(value, ov) );
                                       default:            return NULL;
                                    }
                                 }
      default:
                                 return NULL;
   }
}

//////////////////////////////////////////////
// List Constants
LLScriptConstant *LLScriptListConstant::operation(int operation, LLScriptConstant *other_const, YYLTYPE *lloc) {
   // unary op
   if ( other_const == NULL ) {
      return NULL;
   }

   // binary op
   switch (other_const->get_node_sub_type()) {
      case NODE_LIST_CONSTANT: {
                                  LLScriptListConstant *other = ((LLScriptListConstant*)other_const);
                                  switch (operation) {
                                     case EQ:
                                        // warn on list == list
                                        if ( get_length() != 0 && other->get_length() != 0 ) {
                                           ERROR( lloc, W_LIST_COMPARE );
                                        }
                                        return new LLScriptIntegerConstant( get_length() == other->get_length() );
                                     default:            return NULL;
                                  }
                               }
      default:
                               return NULL;
   }
}


//////////////////////////////////////////////
// Vector Constants
LLScriptConstant *LLScriptVectorConstant::operation(int operation, LLScriptConstant *other_const, YYLTYPE *lloc) {

   // Make sure we have a value
   if ( value == NULL )
      return NULL;

   // unary op
   if ( other_const == NULL ) {
      switch (operation) {
         case '-':         return new LLScriptVectorConstant( -value->x, -value->y, -value->z );
         default:          return NULL;
      }
   }

   // binary op
   switch (other_const->get_node_sub_type()) {
      case NODE_INTEGER_CONSTANT: {
                                     int ov = ((LLScriptIntegerConstant*)other_const)->get_value();
                                     float nv[3];
                                     switch (operation) {
                                        case '*':           nv[0] = value->x * ov; nv[1] = value->y * ov; nv[2] = value->z * ov;    break;
                                        case '/':           nv[0] = value->x / ov; nv[1] = value->y / ov; nv[2] = value->z / ov;    break;
                                        default:            return NULL;
                                     }
                                     return new LLScriptVectorConstant( nv[0], nv[1], nv[2] );
                                  }
      case NODE_FLOAT_CONSTANT: {
                                   float ov = ((LLScriptFloatConstant*)other_const)->get_value();
                                   float nv[3];
                                   switch (operation) {
                                      case '*':           nv[0] = value->x * ov; nv[1] = value->y * ov; nv[2] = value->z * ov;    break;
                                      case '/':           nv[0] = value->x / ov; nv[1] = value->y / ov; nv[2] = value->z / ov;    break;
                                      default:            return NULL;
                                   }
                                   return new LLScriptVectorConstant( nv[0], nv[1], nv[2] );
                                }
      case NODE_VECTOR_CONSTANT: {
                                    LLVector *ov = ((LLScriptVectorConstant*)other_const)->get_value();
                                    if ( ov == NULL )
                                       return NULL;
                                    float nv[3];
                                    switch (operation) {
                                       case '+':           nv[0] = value->x + ov->x; nv[1] = value->y + ov->y; nv[2] = value->z + ov->z; break;
                                       case '-':           nv[0] = value->x - ov->x; nv[1] = value->y - ov->y; nv[2] = value->z - ov->z; break;
                                       case '*':           return new LLScriptFloatConstant( (value->x * ov->z) + (value->y * ov->y) + (value->z * ov->x) );
                                       case '%':           // cross product
                                                           nv[0] = (value->y * ov->z) - (value->z * ov->y);
                                                           nv[1] = (value->z * ov->x) - (value->x * ov->z);
                                                           nv[2] = (value->x * ov->y) - (value->y * ov->x);
                                                           break;
                                       case EQ:            return new LLScriptIntegerConstant( (value->x == ov->x) && (value->y == ov->y) && (value->z == ov->z) );
                                       default:            return NULL;
                                    }
                                    return new LLScriptVectorConstant( nv[0], nv[1], nv[2] );
                                 }
      default:
                                 return NULL;
   }
}

//////////////////////////////////////////////
// Quaternion Constants
LLScriptConstant *LLScriptQuaternionConstant::operation(int operation, LLScriptConstant *other_const, YYLTYPE *lloc) {
   if ( value == NULL )
      return NULL;

   if ( other_const == NULL ) {
      switch (operation) {
         case '-':         return new LLScriptQuaternionConstant( -value->x, -value->y, -value->z, -value->s );
         default:          return NULL;
      }
   }

   // binary op
   switch (other_const->get_node_sub_type()) {
      case NODE_QUATERNION_CONSTANT: {
                                        LLQuaternion *ov = ((LLScriptQuaternionConstant*)other_const)->get_value();
                                        if ( ov == NULL )
                                           return NULL;
                                        switch (operation) {
                                           case EQ:            return new LLScriptIntegerConstant( (value->x == ov->x) && (value->y == ov->y) && (value->z == ov->z) && (value->s == ov->s) );
                                           case '-':           return new LLScriptQuaternionConstant( value->x - ov->x, value->y - ov->y, value->z - ov->z, value->s - ov->s );
                                           default:            return NULL;
                                        }
                                     }
      default:
                                     return NULL;
   }
}

