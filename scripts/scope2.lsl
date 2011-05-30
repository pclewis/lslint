integer test = 1;                       // $[E20009] unused
test() { }                              // $[E10001] already declared
default { state_entry() { test(); } }   // $[E10005] test is variable, not function
