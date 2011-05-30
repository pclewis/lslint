integer number = 2+2;               // non constant                             $[E10020]
integer number = 3;                 // will only pass because above fails       $[E20009]
integer number = 4;                 // already declared                         $[E10001]

string unused()  {                  // warning: declared but never used         $[E20009]
    state default;                  // error: can't change state in function    $[E10014]
    if (1 == 1) {                   // always true                              $[E20011]
        state default;              // warning: hack that corrupts stack        $[E20004]
        return;                     // error: returning nothing in int function $[E10018]
    }
}

string test(integer a, vector v) {  // param a is never used                    $[E20009]
    string q;                       // warning: declared but never used         $[E20009]
    return v;                       // error: return vector in string function  $[E10018]
}

default {

    state_entry(integer param) {    // state_entry does not take params         $[E10019]
        integer number = "hello";   // type mismatch, warning: shadow decl      $[E10015] $[E20001]
        int q;                      // should point out int->integer typo maybe $[E10019]
        number = number-2;          // error: parsed as IDENTIFER INTEGER       $[E10021]
        number = 2-2;               // warning: 2-2 = 2                         $[E20008]
        [1] == [2];                 // warning: only compares length            $[E20010]
        number = number;            // warning: statement with no effect?
        str = "hi!";                // undeclared                               $[E10006]
        llSay(0, number.x);         // number is not a vector                   $[E10010]
        LLsay(0, llListToString([])); // typos; suggest llSay, llList2String    $[E10007] $[E10007]
        test(1, "hi");              // arg 2 should be vector not string        $[E10011]
        jump number;                // number is not a label                    $[E10005]
        jump label;                 // warning: when using multiple jumps to
        jump label;                 //    one label, all but last is ignored    $[E20006]
        @label;
        return number;              // returning a value in an event            $[E10017]
        state default;              // warning: state current acts like return  $[E20003]
                                    // warning: code is never reached?
    }

    touch_start() {                 // requires parameters                      $[E10019]
    }

    at_target(integer i, vector v, string s) { // third param should be vector  $[E10019]
    }

}
