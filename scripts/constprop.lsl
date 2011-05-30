// Constant propogation test

default {
    state_entry() {
        integer  i = 1;
        float    f = 1.0;
        vector   v = <1,2,3>;
        rotation r = <3,2,1,0>;
        list     l = [1,2,3];
        string   s = "hello";

        if ( i == f ) return;                   // $[E20011]
        if ( i != f ) return;                   // $[E20012]
        if ( i == (f+1) ) return;               // $[E20012]
        if ( (i+1) == (f+1) ) return;           // $[E20011]
        if ( f == 1.0 ) return;                 // $[E20011]
        if ( f == 1.1 ) return;                 // $[E20012]

        if ( v == <1,2,3> ) return;             // $[E20011]
        if ( v == <r.z, r.y, r.x> ) return;     // $[E20011]
        if ( v.x == v.y ) return;               // $[E20012]
        if ( r == <v.z, v.y, v.x, 0> ) return;  // $[E20011]

        if ( l == [6,5,2] ) return;             // $[E20011] $[E20010]
        if ( l == [r.z, r.y, r.x] ) return;     // $[E20011] $[E20010]
        if ( l == [] ) return;                  // $[E20012]

        if ( s == "hello" ) return;             // $[E20011]
        if ( s + " world" == "h" + "e" + "llo" + " wo" + "rld" ) return;    // $[E20011]
    }
}   
