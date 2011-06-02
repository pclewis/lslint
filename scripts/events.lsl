boy(integer girl) {}


state_entry() {
}

default {
   state_entry() {
      boy("foo");
   }
   on_rez(integer paramie) {
   }
   on_rez(string paramie) {
   }
   object_rez(float s) {
   }
   listen(integer channel) {
   }
   changed(integer changed, integer extra) {
   }
   foo() {
   }
   bar(integer baz) {
   }
}
