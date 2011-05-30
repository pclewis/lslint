test() { }
default {
    state_entry() {
        integer test = 1; // works fine
        test();
        test = 2;
    }
}
