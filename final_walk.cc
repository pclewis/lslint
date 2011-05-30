#include "lslmini.hh"

void LLASTNode::final_pre_walk() {
  LLASTNode *node;
  final_pre_checks();
  for ( node = get_children(); node; node = node->get_next() )
    node->final_pre_walk();
}

void LLASTNode::final_pre_checks() {
  // none
}

void LLScriptIfStatement::final_pre_checks() {
  // see if expression is constant
  if ( get_child(0)->get_constant_value() != NULL ) {
    // TODO: can conditions be something other than integer?
    if ( get_child(0)->get_constant_value()->get_node_sub_type() == NODE_INTEGER_CONSTANT ) {
      if ( ((LLScriptIntegerConstant*)get_child(0)->get_constant_value())->get_value() ) {
        ERROR(IN(get_child(0)), W_CONDITION_ALWAYS_TRUE);
      } else {
        ERROR(IN(get_child(0)), W_CONDITION_ALWAYS_FALSE);
      }
    }
  }

  // set if expression is an assignment
  if ( get_child(0)->get_node_type() == NODE_EXPRESSION ) {
    LLScriptExpression *expr = (LLScriptExpression *)get_child(0);
    if ( expr->get_operation() == '=' ) {
      ERROR(IN(expr), W_ASSIGNMENT_IN_COMPARISON);
    }
  }
}

void LLScriptEventHandler::final_pre_checks() {
  int found_before = 0, found_after = 0;
  EventId event_id = ((LLScriptEvent*)get_child(0))->get_event_id();
  bool found_self = false;
  LLASTNode *node = NULL; 
  LLASTNode *first = NULL;

  // check all of our siblings
  for ( node = get_parent()->get_children(); node; node = node->get_next() ) {
    // see if we found ourself
    if ( node == this ) {
      found_self = true;
      continue;
    }

    // ignore anything that's not an event handler
    if ( node->get_node_type() != NODE_EVENT_HANDLER )
      continue;

    if ( ((LLScriptEvent*)node->get_child(0))->get_event_id() == event_id ) {
      if (found_self) {
        ++found_after;  // we only want to know if we're last, so short circuit here
        break;
      } else {
        if ( first == NULL )
          first = node;
        ++found_before;
      }
    }
  }

  if ( found_before > 0 && found_after == 0 ) {
    ERROR( HERE, W_MULTIPLE_EVENT_HANDLERS, event_names[event_id] );
  }
}
