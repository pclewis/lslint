#include "lslmini.hh"

void LLASTNode::propogate_values() {
   LLASTNode             *node = get_children();
   if ( node != NULL ) {
      /*
         while ( node->get_next() )
         node = node->get_next(); // start with last node

         while ( node )  {
         node->propogate_values();
         node = node->get_prev();
         }
         */
      while ( node ) {
         node->propogate_values();
         node = node->get_next();
      }
   }

   determine_value();
}

void LLASTNode::determine_value() {
   // none
}

void LLScriptDeclaration::determine_value() {
   LLScriptIdentifier *id = (LLScriptIdentifier *) get_child(0);
   LLASTNode *node = get_child(1);
   if ( node == NULL || node->get_node_type() == NODE_NULL ) return;
   DEBUG( LOG_DEBUG_SPAM, NULL, "set %s const to %p\n", id->get_name(), node->get_constant_value() );
   id->get_symbol()->set_constant_value( node->get_constant_value() );
}

void LLScriptExpression::determine_value() {
   DEBUG( LOG_DEBUG_SPAM, NULL, "expression.determine_value() op=%d cv=%s st=%d\n", operation, constant_value ? constant_value->get_node_name() : NULL, get_node_sub_type() );
   if ( constant_value != NULL )
      return; // we already have a value

   if ( get_node_sub_type() != NODE_NO_SUB_TYPE && get_node_sub_type() != NODE_LVALUE_EXPRESSION )
      return; // only check normal and lvalue expressions

   if ( operation == 0 )
      constant_value = get_child(0)->get_constant_value();
   else if ( operation == '=' )
      constant_value = get_child(1)->get_constant_value();
   else {

      LLScriptConstant *left  = get_child(0)->get_constant_value();
      LLScriptConstant *right = get_child(1) ? get_child(1)->get_constant_value() : NULL;

      // we need a constant value from the left, and if we have a right side, it MUST have a constant value too
      if ( left && (get_child(1) == NULL || right != NULL) )
         constant_value = left->operation( operation, right, get_lloc() );
      else
         constant_value = NULL;

   }
}

void LLScriptSimpleAssignable::determine_value() {
   if ( get_child(0) )
      constant_value = get_child(0)->get_constant_value();
}

void LLScriptVectorConstant::determine_value() {
   if ( get_value() != NULL )
      return;

   LLASTNode                 *node       = get_children();
   float                     v[3];
   int                       cv = 0;

   for ( node = get_children(); node; node = node->get_next() ) {
      // if we have too many children, make sure we don't overflow cv
      if ( cv >= 3 )
         return;

      // all children must be constant
      if ( !node->is_constant() )
         return;

      // all children must be float/int constants - get their val or bail if they're wrong
      switch( node->get_constant_value()->get_type()->get_itype() ) {
         case LST_FLOATINGPOINT:
            v[cv++] = ((LLScriptFloatConstant*)node->get_constant_value())->get_value();
            break;
         case LST_INTEGER:
            v[cv++] = ((LLScriptIntegerConstant*)node->get_constant_value())->get_value();
            break;
         default:
            return;
      }

   }

   if ( cv < 3 )  // not enough children
      return;

   value = new LLVector( v[0], v[1], v[2] );

}

void LLScriptQuaternionConstant::determine_value() {
   if ( get_value() != NULL )
      return;

   LLASTNode                 *node       = get_children();
   float                     v[4];
   int                       cv = 0;

   for ( node = get_children(); node; node = node->get_next() ) {
      // if we have too many children, make sure we don't overflow cv
      if ( cv >= 4 )
         return;

      // all children must be constant
      if ( !node->is_constant() )
         return;

      // all children must be float/int constants - get their val or bail if they're wrong
      switch( node->get_constant_value()->get_type()->get_itype() ) {
         case LST_FLOATINGPOINT:
            v[cv++] = ((LLScriptFloatConstant*)node->get_constant_value())->get_value();
            break;
         case LST_INTEGER:
            v[cv++] = ((LLScriptIntegerConstant*)node->get_constant_value())->get_value();
            break;
         default:
            return;
      }

   }

   if ( cv < 4 ) // not enough children;
   return;

   value = new LLQuaternion( v[0], v[1], v[2], v[3] );

}


void LLScriptIdentifier::determine_value() {
   // can't determine value if we don't have a symbol
   if ( symbol == NULL )
      return;

   DEBUG( LOG_DEBUG_SPAM, NULL, "id %s assigned %d times\n", get_name(), symbol->get_assignments() );
   if ( symbol->get_assignments() == 0 ) {
      constant_value = symbol->get_constant_value();
      if ( constant_value != NULL && member != NULL ) { // getting a member
         switch ( constant_value->get_type()->get_itype() ) {
            case LST_VECTOR: {
                                LLScriptVectorConstant *c = (LLScriptVectorConstant *)constant_value;
                                LLVector *v = (LLVector *) c->get_value();
                                if ( v == NULL ) {
                                   constant_value = NULL;
                                   break;
                                }
                                switch ( member[0] ) {
                                   case 'x': constant_value = new LLScriptFloatConstant( v->x ); break;
                                   case 'y': constant_value = new LLScriptFloatConstant( v->y ); break;
                                   case 'z': constant_value = new LLScriptFloatConstant( v->z ); break;
                                   default:  constant_value = NULL;
                                }
                                break;
                             }
            case LST_QUATERNION: {
                                    LLScriptQuaternionConstant *c = (LLScriptQuaternionConstant *)constant_value;
                                    LLQuaternion *v = (LLQuaternion *) c->get_value();
                                    if ( v == NULL ) {
                                       constant_value = NULL;
                                       break;
                                    }
                                    switch ( member[0] ) {
                                       case 'x': constant_value = new LLScriptFloatConstant( v->x ); break;
                                       case 'y': constant_value = new LLScriptFloatConstant( v->y ); break;
                                       case 'z': constant_value = new LLScriptFloatConstant( v->z ); break;
                                       case 's': constant_value = new LLScriptFloatConstant( v->s ); break;
                                       default:  constant_value = NULL;
                                    }
                                    break;
                                 }
            default: constant_value = NULL; break;
         }
      }
   }
}

void LLScriptListExpression::determine_value() {
   LLASTNode                 *node       = get_children();
   LLScriptSimpleAssignable  *assignable = NULL;

   // if we have children
   if ( node->get_node_type() != NODE_NULL ) {
      // make sure they are all constant
      for ( node = get_children(); node; node = node->get_next() ) {
         if ( !node->is_constant() )
            return;
      }

      // create assignables for them
      for ( node = get_children(); node; node = node->get_next() ) {
         if ( assignable == NULL ) {
            assignable = new LLScriptSimpleAssignable( node->get_constant_value() );
         } else {
            assignable->add_next_sibling( new LLScriptSimpleAssignable(node->get_constant_value()) );
         }
      }
   }

   // create constant value
   constant_value = new LLScriptListConstant( assignable );

}

void LLScriptVectorExpression::determine_value() {
   LLASTNode                 *node       = get_children();
   float                     v[3];
   int                       cv = 0;

   // don't need to figure out a value if we already have one
   if ( constant_value != NULL )
      return;

   for ( node = get_children(); node; node = node->get_next() ) {
      // if we have too many children, make sure we don't overflow cv
      if ( cv >= 3 )
         return;

      // all children must be constant
      if ( !node->is_constant() )
         return;

      // all children must be float/int constants - get their val or bail if they're wrong
      switch( node->get_constant_value()->get_type()->get_itype() ) {
         case LST_FLOATINGPOINT:
            v[cv++] = ((LLScriptFloatConstant*)node->get_constant_value())->get_value();
            break;
         case LST_INTEGER:
            v[cv++] = ((LLScriptIntegerConstant*)node->get_constant_value())->get_value();
            break;
         default:
            return;
      }
   }

   // make sure we had enough children
   if ( cv < 3 )
      return;

   // create constant value
   constant_value = new LLScriptVectorConstant( v[0], v[1], v[2] );

}

// FIXME: duped code
void LLScriptQuaternionExpression::determine_value() {
   LLASTNode                 *node       = get_children();
   float                     v[4];
   int                       cv = 0;

   if ( constant_value != NULL )
      return;

   for ( node = get_children(); node; node = node->get_next() ) {
      // if we have too many children, make sure we don't overflow cv
      if ( cv >= 4 )
         return;

      // all children must be constant
      if ( !node->is_constant() )
         return;

      // all children must be float/int constants - get their val or bail if they're wrong
      switch( node->get_constant_value()->get_type()->get_itype() ) {
         case LST_FLOATINGPOINT:
            v[cv++] = ((LLScriptFloatConstant*)node->get_constant_value())->get_value();
            break;
         case LST_INTEGER:
            v[cv++] = ((LLScriptIntegerConstant*)node->get_constant_value())->get_value();
            break;
         default:
            return;
      }

   }

   if ( cv < 4 )
      return;

   // create constant value
   constant_value = new LLScriptQuaternionConstant( v[0], v[1], v[2], v[3] );

}
