#!/usr/bin/perl

# Usage: cat lscript_library.cpp indra.l indra.y | perl builtins.pl > builtins.txt

# this is automated, but slightly less desireable because we lose the names of params
# in some cases and have to change them to arg1...
# it also loses some constant values (which we don't check now, but may in the future)

my %typestr = (
  'i' => 'integer',
  's' => 'string',
  'v' => 'vector',
  'q' => 'rotation',
  'f' => 'float',
  'k' => 'key',
  'l' => 'list'
);

sub beginevent($) {
   my $arg = shift @_;
   foreach my $key (keys(%events)) {
      if ($arg =~ /^$key/) {
         return 1;
      }
   }
   return 0;
}

while (<STDIN>) {
  # old style...
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
  # new style
  # addFunction(10.f, 0.f, dummy_func, "llReleaseURL", NULL, "s");
  elsif (/^\s*addFunction\(
      [^,]+,[^,]+,[^,]+,          # ignore 10.f, 0.f, dummy_func (or whatever may be there)
      \s*  "([^"]+)"  \s*,        # function name
      \s*  (NULL|".") \s*,        # return type is either NULL or a single-letter string
      \s*  (NULL|"[a-z]*")/x)     # arg types is either NULL or a string with 1 letter per arg
  {
    my $name = $1, $rtype = $2, $ptypes = $3;
    printf "%-8s ",  (($rtype eq "NULL") ? "void" : $typestr{substr($rtype,1,1)});
    print $name;
    if ($ptypes eq "NULL" || $ptypes eq '""') {
      print "()";
    } else {
      print "(";

      # bunch of savages in this town!
      my $i = 0;
      foreach $param (split(//, $ptypes)) {
        if ($param ne '"') {
          if ( $i != 0 ) { print ", " };
          $i++;
          print "$typestr{$param} arg$i";
        }
      }

      print ")";
    }
    print "\n";
  }
  elsif (/<event>/) {
     my $tmp = $_;
     $tmp =~ s/^.*<event>\s*//g;
     chomp $tmp;
     $events{$tmp} = 1;
  }
  elsif (beginevent($_)) {
     $estate = 1;
  }
  elsif ($estate) {
     my $tmp = $_;
     my $i = 1;
     $tmp =~ s/[':]//g;
     $tmp =~ s/LLKEY/key/g;
     $tmp = "event " . $tmp;
     $tmp = lc($tmp);
     $tmp =~ s/\s+/ /g;
     $tmp =~ s/identifier/argidentifier/g;
     $tmp =~ s/identifier/$i++/ge;
     print "$tmp\n";
     $estate = 0;
  }
  elsif (/^\".*_CONSTANT/) {
     if (!$cheat) {
        $cheat = 1;
        print "const vector TOUCH_INVALID_TEXCOORD = <-1.0,-1.0,0.0>\n";
        print "const vector ZERO_VECTOR = <0.0,0.0,0.0>\n";
        print "const rotation ZERO_ROTATION = <0.0,0.0,0.0,1.0>\n";
     }

     # "STATUS_PHYSICS"                { count(); yylval.ival = 0x1; return(INTEGER_CONSTANT); }
     if (/^\"([^"]*)\"[^=]*=\s*([^;]*);.*INTEGER_CONSTANT/) {
           print "const integer $1 = $2\n";
     }
     # "NULL_KEY"                              { yylval.sval = new char[UUID_STR_LENGTH]; strcpy(yylval.sval, "00000000-0000-0000-0000-000000000000"); return(STRING_CONSTANT); }
     # "URL_REQUEST_GRANTED"   { yylval.sval = new char[UUID_STR_LENGTH]; strcpy(yylval.sval, URL_REQUEST_GRANTED); return(STRING_CONSTANT); }
     elsif (/^\"([^"]*)\"[^"]*strcpy[^,]*,\s*([^)]*).*STRING_CONSTANT/) {
        print "const string $1 = $2\n";
     }
     # "PI"                                    { count(); yylval.fval = F_PI; return(FP_CONSTANT); }
     elsif (/^\"([^"]*)\"[^=]*=\s*([^;]*);.*FP_CONSTANT/) {
           print "const float $1 = $2\n";
     }
     else {
     print $_;
     }
  }

}
