//63ad9d1f8a8ba7aac3da2ec99a5b1f50  -




integer world_channel = 0x0114A945;
integer my_channel = 0;
integer my_role;
list others;
integer countdown = 0;
list replace;
list rezme;
list adds;
integer handle;
integer worldhandle;
integer lastchange;
integer pscd = 0;
key want_renew = NULL_KEY;

key original_key;
string original_name;





quaternion point_at(key id) {
   llParticleSystem([
         PSYS_PART_FLAGS, PSYS_PART_TARGET_POS_MASK | PSYS_PART_TARGET_LINEAR_MASK | PSYS_PART_EMISSIVE_MASK,
         PSYS_SRC_TARGET_KEY, id,
         PSYS_PART_MAX_AGE, 2.0,
         PSYS_SRC_BURST_RATE, .2,
         PSYS_SRC_BURST_PART_COUNT, 1
         ]);
   pscd = 5;
}

quaternion llSayAll(integer c, string s) {
   llRegionSay(c, s);
   if ((-1 != llSubStringIndex(llGetObjectDesc(), "{"+("debug:pkg")+"}"))) {
      llOwnerSay("/" + (string)c + " " + s);
   }
}

integer channelof(key id) {
   return ((((integer)("0x" + llGetSubString((string)id,0,7))) & 0x7FFFFFFF) | 0x40000000);
}

integer role() {
   integer max = llGetInventoryNumber(INVENTORY_ALL);
   integer i;
   string s;

   if (llGetInventoryNumber(INVENTORY_CLOTHING)) {

      return 0;
   }

   for (i = 0; i < max; i++) {
      s = llGetInventoryName(INVENTORY_ALL, i);
      if (llGetScriptName() != s) {
         if (llSubStringIndex(s, "~pkg~") == 0) {

            return 2;
         }
      }
   }


   llSetText(llGetObjectName(), <1,1,1>, 1);
   return 1;
}

quaternion handle_anything() {
   integer max;
   integer i;
   integer j;
   key k;
   string si;
   string sj;
   list l;


   l = [];
   max = llGetInventoryNumber(INVENTORY_ALL);
   for (i = 0; i < max; i++) {
      si = llGetInventoryName(INVENTORY_ALL, i);
      if (-1 != llSubStringIndex(si, " ")) {
         l = l + [ si ];
      }
   }
   max = (l != []);
   for (i = 0; i < max; i++) {
      if (llGetInventoryType(llList2String(l,i)) == INVENTORY_SCRIPT) {
         llSetScriptState(llList2String(l,i), 0);
      }
      llRemoveInventory(llList2String(l, i));
   }


   if ((rezme != []) == 0 && (replace != []) == 0 &&
         (adds != []) == 0 && my_role != 0) {



      max = llGetInventoryNumber(INVENTORY_OBJECT);
      for (i = 0; i < max; i++) {
         si = llGetInventoryName(INVENTORY_OBJECT, i);
         if (0 == llSubStringIndex(si, "~pkg~")) {
            list li = llParseString2List(si, ["~"], []);
            for (j = i + 1; j < max; j++) {
               sj = llGetInventoryName(INVENTORY_OBJECT, j);
               if (0 == llSubStringIndex(sj, "~pkg~")) {
                  list lj = llParseString2List(sj, ["~"], []);
                  if (llList2String(li, 1) == llList2String(lj, 1)) {
                     integer inum = (integer) llList2String(li, 2);
                     integer jnum = (integer) llList2String(lj, 2);
                     if (inum < jnum) {
                        replace = [ sj, si ] + replace;
                        rezme = [ sj, si ] + rezme;
                        llOwnerSay("adding " + sj);
                     }
                     else if (jnum < inum) {
                        replace = [ si, sj ] + replace;
                        rezme = [ si, sj ] + rezme;
                        llOwnerSay("adding " + si);
                     }
                  }
               }
            }
         }
      }
   }

   for (i = 0; i < (rezme != []); i += 2) {
      if (NULL_KEY != llGetInventoryKey(llList2String(rezme, i))) {
         if (llStringLength(llList2String(rezme, i + 1))) {
            llRezObject(llList2String(rezme, i + 1), llGetPos(), ZERO_VECTOR, ZERO_ROTATION, -my_channel);
         }
         else {

            llRezObject(llList2String(rezme, i), llGetPos(), ZERO_VECTOR, ZERO_ROTATION, my_channel);
            j = llListFindList(replace, [ llList2String(rezme, i) ]);
            if (j != -1) {
               replace = llDeleteSubList(replace, j, j + 1);
            }
         }

         rezme = llDeleteSubList(rezme, i, i + 1);
         i -= 2;
      }
   }

   for (i = 0; i < (adds != []); i += 3) {
      k = llGetInventoryKey(llList2String(adds, i + 2));
      if (k == (key) llList2String(adds, i + 1)) {
         adds = llDeleteSubList(adds, i, i + 2);
         i -= 3;
      }
   }
}

default {
   state_entry() {
      if ((-1 != llSubStringIndex(llGetObjectDesc(), "{"+("debug:pkg")+"}"))) {
         llOwnerSay("debug on");
      }

      llParticleSystem([]);
      original_name = llGetScriptName();
      original_key = llGetInventoryKey(original_name);

      my_channel = channelof(llGetKey());
      llSetRemoteScriptAccessPin(my_channel);
      my_role = role();
      worldhandle = llListen(world_channel, "", NULL_KEY, "");
      handle = llListen(my_channel, "", NULL_KEY, "");

      if ((-1 != llSubStringIndex(llGetObjectDesc(), "{"+("debug:pkg")+"}"))) {
         llOwnerSay((string)my_role + " " + (string) worldhandle + " " + (string) handle);
      }

      if (my_role == 0) {
         llSayAll(world_channel,
               "DELIVERY " + (string) 0x20110602 + " " + (string) 0x221554);
      }







      llSetTimerEvent(1);

      if (my_role != 0) {
         handle_anything();
      }
   }

   touch_start(integer n) {
      if ((-1 != llSubStringIndex(llGetObjectDesc(), "{"+("debug:pkg")+"}"))) {
         integer max;
         integer i;
         string s;
         max = llGetInventoryNumber(INVENTORY_SCRIPT);
         for (i = 0; i < max; i++) {
            s = llGetInventoryName(INVENTORY_SCRIPT, i);
            if (llGetScriptState(s)) {
               s = s + ":ok";
            }
            else {
               s = s + ":FAIL";
            }
            llOwnerSay("script " + s);
         }
      }
   }

   timer() {
      integer i;

      if (my_role == 1) {

         llSetText(llGetObjectName(), <1,1,1>, 1);
      }

      if (want_renew != NULL_KEY &&
            !(replace != []) &&
            !(rezme != []) &&
            !(adds != [])) {

         llSayAll(channelof(want_renew), "RENEW");
      }

      if (pscd) {
         pscd--;
         if (!pscd) {
            llParticleSystem([]);
         }
      }
      if (my_role == 0) {
         llSayAll(world_channel,
               "DELIVERY " + (string) 0x20110602 + " " + (string) 0x221554);
      }
      if (countdown > 0) {
         countdown--;
         if (!countdown) {
            llAllowInventoryDrop(FALSE);
         }
      }
      if ((llGetUnixTime() - lastchange) > 120) {
         if ((adds != [])) {
            for (i = 0; i < (adds != []); i += 3) {
               llRezObject(llList2String(adds, i), llGetPos(), ZERO_VECTOR, ZERO_ROTATION, my_channel);
            }
         }
         else if (my_role != 0) {
            handle_anything();
         }
         others = [];
         lastchange = llGetUnixTime();
      }
   }
   on_rez(integer param) {
      integer i;
      integer max;
      string s;
      llListenRemove(handle);
      my_channel = channelof(llGetKey());
      llSetRemoteScriptAccessPin(my_channel);
      my_role = role();
      handle = llListen(my_channel, "", NULL_KEY, "");
      if (param < 0) {
         max = llGetInventoryNumber(INVENTORY_ALL);
         for (i = 0; i < max; i++) {
            s = llGetInventoryName(INVENTORY_ALL, i);
            if (s != llGetScriptName()) {
               llSayAll(-param, "REMOVE|" + (string) llGetInventoryKey(s) + "|" + s);
            }
         }
         llSayAll(-param, "FINI");
         llDie();
      }
      else if (param > 0) {
         if (llGetInventoryNumber(INVENTORY_ALL) - llGetInventoryNumber(INVENTORY_SCRIPT)) {
            llSayAll(param, "BULK");
         }
         max = llGetInventoryNumber(INVENTORY_SCRIPT);
         for (i = 0; i < max; i++) {
            s = llGetInventoryName(INVENTORY_SCRIPT, i);
            if (s != llGetScriptName()) {
               llSayAll(param, "ADD|" + (string) llGetInventoryKey(s) + "|" + s);
            }
         }
         llSayAll(world_channel,
               "PKG " + (string) 0x20110602 + " " + (string) 0x221554);
         llSetAlpha(0.0, ALL_SIDES);
         llSetText("", ZERO_VECTOR, 0.0);
         llSetPrimitiveParams([ PRIM_TEMP_ON_REZ, TRUE ]);
      }
      else {
         llResetScript();
      }
   }
   listen(integer channel, string name, key id, string msg) {
      integer i;
      integer i1;
      integer max;
      list l;
      string s1;
      string s2;
      string s3;
      string s4;
      integer mine;
      integer theirs;
      if (msg == "CHANGED") {
         i = llListFindList(others, [ id ]);
         if (i != -1) {
            others = llDeleteSubList(others, i, i);
         }
      }
      if (llSubStringIndex(msg, "DELIVERY ") == 0 || llSubStringIndex(msg, "PKG ") == 0) {
         if (my_role != 0) {
            l = llParseString2List(msg, [" "], []);
            if ((l != []) > 1) {
               if ((integer) llList2String(l,1) > 0x20110602 ||
                     ((integer) llList2String(l,1) == 0x20110602 &&
                      (integer) llList2String(l,2) > 0x221554)) {
                  want_renew = id;
               }
            }
         }
      }
      if (llSubStringIndex(msg, "DELIVERY ") == 0) {
         if (my_role == 2) {
            if (-1 == llListFindList(others, [ id ])) {
               others = [ id ] + others;
               llSayAll(channelof(id), "WHAT");
            }
         }
      }
      if (msg == "WHAT") {
         max = llGetInventoryNumber(INVENTORY_OBJECT);
         for (i = 0; i < max; i++) {
            llSayAll(channelof(id), "HAVE" + llGetInventoryName(INVENTORY_OBJECT, i));
         }
      }
      if (0 == llSubStringIndex(msg, "HAVE")) {
         l = llParseString2List(msg, ["~"], []);
         s1 = llList2String(l, 2);
         s2 = llGetSubString(msg, 4, -1);
         s3 = "";
         theirs = (integer) llList2String(l, 3);
         mine = -1;
         max = llGetInventoryNumber(INVENTORY_OBJECT);
         for (i = 0; i < max; i++) {
            s4 = llGetInventoryName(INVENTORY_OBJECT, i);
            if (0 == llSubStringIndex(s4, "~pkg~")) {
               l = llParseString2List(s4, [ "~" ], []);
               i1 = llListFindList(l, [ s1 ]);
               if (i1 != -1) {
                  if (i1 == 1) {
                     mine = (integer) llList2String(l, 2);
                     s3 = s4;
                  }
                  else if (mine == -1) {
                     mine = 0;
                  }
               }
            }
         }
         if (mine >= 0 && mine < theirs) {
            llAllowInventoryDrop(TRUE);
            countdown = 120;
            llSayAll(channelof(id), "WANT" + s2);
            replace = [ s2, s3 ] + replace;
            rezme = [ s2, s3] + rezme;
         }
      }
      if (0 == llSubStringIndex(msg, "WANT")) {
         s1 = llGetSubString(msg, 4, -1);
         point_at(id);
         llGiveInventory(id, s1);
      }
      if (msg == "BULK") {
         llSayAll(channelof(id), "DUMP");
      }
      if (msg == "DUMP") {
         l = [];
         max = llGetInventoryNumber(INVENTORY_ALL);
         for (i = 0; i < max; i++) {
            s1 = llGetInventoryName(INVENTORY_ALL, i);
            if (llGetInventoryType(s1) != INVENTORY_SCRIPT) {
               l += s1;
            }
         }
         point_at(id);
         llGiveInventoryList(id, "null", l);
      }
      if (0 == llSubStringIndex(msg, "REMOVE|")) {
         l = llParseString2List(msg, ["|"], []);
         s1 = llList2String(l, 1);
         s2 = llList2String(l, 2);
         if (NULL_KEY != llGetInventoryKey(s2)) {
            if ((key) s1 != llGetInventoryKey(s2)) {
               llOwnerSay("WARNING: expected key " + (string) s1 +
                  " for '" + s2 + "' but found key " + (string) llGetInventoryKey(s2));
            }
            if (llGetInventoryType(s2) == INVENTORY_SCRIPT) {
               llSetScriptState(s2, 0);
            }
            llRemoveInventory(s2);
         }
      }
      if (0 == llSubStringIndex(msg, "ADD|")) {
         l = llParseString2List(msg, ["|"], []);
         s1 = llList2String(l, 1);
         s2 = llList2String(l, 2);
         adds = [ name, s1, s2 ] + adds;
         if ((key) s1 != llGetInventoryKey(s2)) {
            llSayAll(channelof(id), "TAKE|" + s2);
         }
      }
      if (msg == "RENEW") {
         if (llGetOwnerKey(id) == llGetOwner()) {
            point_at(id);
            llRemoteLoadScriptPin(id, llGetScriptName(), channelof(id), 1, 0);
         }
      }
      if (0 == llSubStringIndex(msg, "TAKE|")) {
         l = llParseString2List(msg, ["|"], []);
         s1 = llList2String(l, 1);
         point_at(id);
         if (llGetInventoryType(s1) == INVENTORY_SCRIPT) {
            llRemoteLoadScriptPin(id, s1, channelof(id), 1, 0);
         }
         else {
            llGiveInventory(id, s1);
         }
      }
      if (msg == "FINI") {
         i = llListFindList(replace, [ name ]);
         if (i != -1) {
            llRezObject(llList2String(replace, i - 1), llGetPos(), ZERO_VECTOR, ZERO_ROTATION, my_channel);
            replace = llDeleteSubList(replace, i - 1, i);
         }
         llRemoveInventory(name);
      }
   }
   changed(integer change) {
      if ((-1 != llSubStringIndex(llGetObjectDesc(), "{"+("debug:pkg")+"}"))) {
         llOwnerSay("changed " + (string) change);
      }
      if (change & (CHANGED_INVENTORY | CHANGED_ALLOWED_DROP)) {
         lastchange = llGetUnixTime();
         if ((-1 != llSubStringIndex(llGetObjectDesc(), "{"+("debug:pkg")+"}"))) {
            llOwnerSay("inventory " + (string) my_role);
         }
         if (my_role == 0) {
            llSayAll(world_channel, "CHANGED");
            return;
         }
         handle_anything();
      }
   }
}
