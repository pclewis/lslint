# Usage: perl builtins.pl < lscript_library.cpp > builtins.txt

# TODO FIX: this doesn't do the various constants and events.  Fix it!

my %typestr = (
  'i' => 'integer',
  's' => 'string',
  'v' => 'vector',
  'q' => 'rotation',
  'f' => 'float',
  'k' => 'key',
  'l' => 'list'
);

while (<STDIN>) {
  # addFunction(new LLScriptLibraryFunction(10.f, 0.f, dummy_func, "llGetParcelDetails", "l", "vl","list llGetParcelDetails(vector pos, list params)\nGets the parcel details specified in params for the parcel at pos.\nParams is one or more of: PARCEL_DETAILS_NAME, _DESC, _OWNER, _GROUP, _AREA"));
  if (/^\s*addFunction\(new\ LLScriptLibraryFunction\(
      [^,]+,[^,]+,[^,]+,          # ignore 10.f, 0.f, dummy_func (or whatever may be there)
      \s*  "([^"]+)"  \s*,        # function name
      \s*  (NULL|".") \s*,        # return type is either NULL or a single-letter string
      \s*  (NULL|"[a-z]*") \s*,   # arg types is either NULL or a string with 1 letter per arg
      \s*  "([^"]*)"/x)           # description
  {
    my $name = $1, $rtype = $2, $ptypes = $3, $desc = $4;
    printf "%-8s ",  (($rtype eq "NULL") ? "void" : $typestr{substr($rtype,1,1)});
    print $name;
    if ($ptypes eq "NULL" || $ptypes eq '""') {
      print "()";
    } else {
      print "(";
      if ($desc =~ /^
        [^(]+       # dont care about anything before open paren
        \(
          (.*?)
        (\)|\\n|$)  # Some descriptions are missing ), but they should have \n
        /x)
      {
        my $i = 0;
        foreach $param (split(/\s*,\s*/, $1)) {
          my $name;
          (undef, $name) = split(/\s+/, $param);
          print ", " if ( $i != 0 );
          print "$typestr{substr($ptypes, ++$i, 1)} $name";
        }
      }
      print ")";
    }
    print "\n";
  }
}
