// Reported By: Strife Onizuka
// Date: 2006-02-06
// Version: v0.1.2
// Error: warn about multiple handlers for the same event

default {
    state_entry() { }
    state_entry() { } // don't warn about
    state_entry() { } //    these two
    state_entry() { } // just this one    $[E20013]
}


