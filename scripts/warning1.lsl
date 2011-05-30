default {
    state_entry() {
        integer a;
        integer b;
        if ( a = 1 );           // $[E20002] $[E20007] $[E20011] assign as comparison, empty if, always true
        if ( (a = 1) ) {}       // don't want about assignment. always true, empty if: $[E20007] $[E20011]

        if ( (b = 1) == 2 );    // don't warn about these (always true: $[E20012])
        else if ( b == 2 );     // don't warn about these
        else a = 2;             // don't warn about these
    }
}
