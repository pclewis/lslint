// Reported By: Masakazu Kojima
// Date: 2006-02-13
// Version: 0.2.1
// Error: vector.s doesn't give an error, nor does vector.a, vector.house, ...
//        v.1 gives "expression and constant without operator" and makes a bad (- vector float) node

default {
    state_entry() {
        vector v;
        rotation r;

        // these are invalid
        [v.1,               // $[E10021]: expression constant (no operator)
         v.6.2.4,           // $[E10021] $[E10021] $[E10021] (parsed as: v .6 .2 .4)
         v.s,               // $[E10008] invalid member
         r.a,               // $[E10008] invalid member
         r.house,           // $[E10008] invalid member
         v.xample];         // $[E10008] invalid member

        // these are valid
        [v.x, v.y, v.z,
         r.x, r.y, r.z, r.s];
     }
}     
