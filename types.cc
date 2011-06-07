#include "lslmini.hh"
#include "types.hh"

#define  LST_ANY        -1
#define  LST_NONE       -2
#define  LST_BOOLEAN    LST_INTEGER     // for clarity


// TODO: use structs or something here

const static int coercion_table[][2] = {
   // wanted type            acceptable type
   { LST_FLOATINGPOINT,      LST_INTEGER },
   { LST_STRING,             LST_KEY     },
   { LST_KEY,                LST_STRING  },
   { -1,                     -1          },
};

const static int operator_result_table[][4] = {

   // operator   left type           right type          result type
   // ++
   { INC_OP,     LST_INTEGER,        LST_NONE,           LST_INTEGER         },
   { INC_OP,     LST_FLOATINGPOINT,  LST_NONE,           LST_FLOATINGPOINT   },

   // --
   { DEC_OP,     LST_INTEGER,        LST_NONE,           LST_INTEGER         },
   { DEC_OP,     LST_FLOATINGPOINT,  LST_NONE,           LST_FLOATINGPOINT   },

   // =
   { '=',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '=',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '=',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_FLOATINGPOINT   },
   { '=',        LST_STRING,         LST_STRING,         LST_STRING          },
   { '=',        LST_STRING,         LST_KEY,            LST_STRING          },
   { '=',        LST_KEY,            LST_STRING,         LST_KEY             },
   { '=',        LST_KEY,            LST_KEY,            LST_KEY             },
   { '=',        LST_VECTOR,         LST_VECTOR,         LST_VECTOR          },
   { '=',        LST_QUATERNION,     LST_QUATERNION,     LST_QUATERNION      },
   { '=',        LST_LIST,           LST_LIST,           LST_LIST            },

   // -
   { '-',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '-',		LST_INTEGER,		LST_FLOATINGPOINT,	LST_FLOATINGPOINT   },
   { '-',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_FLOATINGPOINT   },
   { '-',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '-',        LST_VECTOR,         LST_VECTOR,         LST_VECTOR          },
   { '-',        LST_QUATERNION,     LST_QUATERNION,     LST_QUATERNION      },

   // unary -
   { '-',        LST_INTEGER,        LST_NONE,           LST_INTEGER         },
   { '-',        LST_FLOATINGPOINT,  LST_NONE,           LST_FLOATINGPOINT   },
   { '-',        LST_VECTOR,         LST_NONE,           LST_VECTOR          },
   { '-',        LST_QUATERNION,     LST_NONE,           LST_QUATERNION      },
   // TODO: does (rotation - rotation) work ?

   // +
   { '+',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '+',        LST_INTEGER,        LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '+',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_FLOATINGPOINT   },
   { '+',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '+',        LST_STRING,         LST_STRING,         LST_STRING          },
   { '+',        LST_KEY,            LST_STRING,         LST_KEY             },
   { '+',        LST_VECTOR,         LST_VECTOR,         LST_VECTOR          },
   { '+',        LST_QUATERNION,     LST_QUATERNION,     LST_QUATERNION      },
   { '+',        LST_LIST,           LST_ANY,            LST_LIST            },
   { '+',        LST_ANY,            LST_LIST,           LST_LIST            },

   // *
   { '*',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '*',        LST_INTEGER,        LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '*',		LST_INTEGER,		LST_VECTOR,			LST_VECTOR			}, // scale vector
   { '*',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_FLOATINGPOINT   },
   { '*',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '*',        LST_FLOATINGPOINT,  LST_VECTOR,         LST_VECTOR          }, // scale vector
   { '*',		LST_VECTOR,			LST_INTEGER,		LST_VECTOR			}, // scale vector
   { '*',        LST_VECTOR,         LST_FLOATINGPOINT,  LST_VECTOR          }, // scale vector
   { '*',        LST_VECTOR,         LST_VECTOR,         LST_FLOATINGPOINT   }, // dot product
   { '*',        LST_VECTOR,         LST_QUATERNION,     LST_VECTOR          }, // rotate
   { '*',        LST_QUATERNION,     LST_QUATERNION,     LST_QUATERNION      },

   // /
   { '/',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '/',        LST_INTEGER,        LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '/',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_FLOATINGPOINT   },
   { '/',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_FLOATINGPOINT   },
   { '/',        LST_VECTOR,         LST_INTEGER,        LST_VECTOR          }, // scale vector
   { '/',        LST_VECTOR,         LST_FLOATINGPOINT,  LST_VECTOR          }, // scale vector
   { '/',        LST_VECTOR,         LST_QUATERNION,     LST_VECTOR          }, // TODO: what does this do
   { '/',        LST_QUATERNION,     LST_QUATERNION,     LST_QUATERNION      }, // TODO: what does this do

   // %
   { '%',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '%',        LST_VECTOR,         LST_VECTOR,         LST_VECTOR          }, // cross product

   // >
   { '>',        LST_INTEGER,        LST_INTEGER,        LST_BOOLEAN         }, 
   { '>',        LST_INTEGER,        LST_FLOATINGPOINT,  LST_BOOLEAN         },
   { '>',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_BOOLEAN         },
   { '>',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_BOOLEAN         },

   // <
   { '<',        LST_INTEGER,        LST_INTEGER,        LST_BOOLEAN         }, 
   { '<',        LST_INTEGER,        LST_FLOATINGPOINT,  LST_BOOLEAN         },
   { '<',        LST_FLOATINGPOINT,  LST_INTEGER,        LST_BOOLEAN         },
   { '<',        LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_BOOLEAN         },

   // ==
   { EQ,         LST_INTEGER,        LST_INTEGER,        LST_BOOLEAN         }, 
   { EQ,         LST_INTEGER,        LST_FLOATINGPOINT,  LST_BOOLEAN         },
   { EQ,         LST_FLOATINGPOINT,  LST_INTEGER,        LST_BOOLEAN         },
   { EQ,         LST_FLOATINGPOINT,  LST_FLOATINGPOINT,  LST_BOOLEAN         },
   { EQ,         LST_VECTOR,         LST_VECTOR,         LST_BOOLEAN         },
   { EQ,         LST_QUATERNION,     LST_QUATERNION,     LST_BOOLEAN         },
   { EQ,         LST_STRING,         LST_STRING,         LST_BOOLEAN         },
   { EQ,         LST_STRING,         LST_KEY,            LST_BOOLEAN         },
   { EQ,         LST_KEY,            LST_STRING,         LST_BOOLEAN         },
   { EQ,         LST_KEY,            LST_KEY,            LST_BOOLEAN         },
   { EQ,         LST_LIST,           LST_LIST,           LST_BOOLEAN         }, // compares list lengths

   // != -- converted to ! EQ by parser

   // bitwise operators
   { '&',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '|',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '^',        LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { '~',        LST_INTEGER,        LST_NONE,           LST_INTEGER         },

   // boolean opeartors
   { '!',        LST_INTEGER,        LST_NONE,           LST_BOOLEAN         },
   { BOOLEAN_AND,LST_INTEGER,        LST_INTEGER,        LST_BOOLEAN         },
   { BOOLEAN_OR, LST_INTEGER,        LST_INTEGER,        LST_BOOLEAN         },

   // shift operators
   { SHIFT_LEFT, LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },
   { SHIFT_RIGHT,LST_INTEGER,        LST_INTEGER,        LST_INTEGER         },

   // end
   { -1,         -1,                 -1,                 -1                  },
};

std::vector<LLScriptType*> LLScriptType::types;

bool LLScriptType::can_coerce( LLScriptType *to ) {
   int i;

   // error type matches anything
   if ( get_itype() == LST_ERROR || to->get_itype() == LST_ERROR )
      return true;

   // if we're already of the target type, then of course we can be used for it
   if ( get_itype() == to->get_itype() )
      return true;

   for ( i = 0; coercion_table[i][1] != -1; i++ ) {
      if ( coercion_table[i][1] == get_itype() && coercion_table[i][0] == to->get_itype() ) {
         return true;
      }
   }
   return false;
}

class LLScriptType *LLScriptType::get_result_type(int op,  LLScriptType *right) {
   int i;

   // error on either side is always error
   if ( get_itype() == LST_ERROR || (right != NULL && right->get_itype() == LST_ERROR) )
      return TYPE(LST_ERROR);

   // go through each entry in the operator result table
   for ( i = 0; operator_result_table[i][0] != -1; i++ ) {

      // if the operator is the one we're looking for
      if ( operator_result_table[i][0] == op ) {

         // if the left side matches our left side
         if ( operator_result_table[i][1] == get_itype() || operator_result_table[i][1] == LST_ANY ) {

            // right isn't empty and matches our side
            if ( ( right != NULL &&
                     (operator_result_table[i][2] == LST_ANY ||
                      operator_result_table[i][2] == (int)right->get_itype())
                 ) || // or right IS empty and matches nothing
                  ( right == NULL &&
                    (operator_result_table[i][2] == LST_NONE)
                  )
               )
            {   // send back the type
               return TYPE((LST_TYPE)operator_result_table[i][3]);
            }
         }
      }
   }
   return NULL;
}

