#!/usr/bin/perl

# Usage: builtins_wiki.pl > builtins.txt

# a list of seed URLs
my %urls = (
      "http://wiki.secondlife.com/wiki/Category:LSL_Functions" => "",
      "http://wiki.secondlife.com/wiki/Category:LSL_Events" => "",
      "http://wiki.secondlife.com/wiki/Category:LSL_Constants" => ""
      );

sub do_function($) {
   my $signature = shift(@_);
   $signature =~ s/^[ ]*//g;
   my @x = split / /, $signature;
   if ($x[0] ne lc($x[0])) {
      $signature = "void $signature";
   }
   push @functions, "$signature\n";
   print STDERR "#F# $signature\n";
}

sub do_constant($) {
   my $signature = shift(@_);
   $signature =~ s/^[ ]*//g;
   $signature = "const $signature";
   push @constants, "$signature\n";
   print STDERR "#C# $signature\n";
}

sub do_event($) {
   my $signature = shift(@_);
   $signature =~ s/^[ ]*//g;
   $signature =~ s/\{.*//g;
   $signature = "event $signature";
   push @events, "$signature\n";
   print STDERR "#E# $signature\n";
}

# try each one gather new ones and try them too.

my $counter = 0;
my $changed = 1;

sub queue($) {
   my $url = shift(@_);

   if ($url =~ /^\//) {
      $url = "http://wiki.secondlife.com$url";
   }
   $url =~ s/\&amp;/\&/g;

   # stay on site
   if (!($url =~ /wiki.secondlife.com/)) {
      return;
   }

   if (!defined($urls{$url})) {
      $urls{$url} = "";
      $changed = 1;
   }
}

while ($changed) {
   $changed = 0;

   foreach $key (keys(%urls)) {
      if (length($urls{$key}) == 0) {
         $changed = 1;

         $counter++;
         @keylist = keys(%urls);
         push @keylist, ""; # kludge to bump up keylist counter
         print STDERR "$counter/$#keylist $key\n";

         open FILE, "wget \"$key\" -O - 2>/dev/null |";
         $urls{$key} = join("", <FILE>);
         close FILE;

         # look for a "next 200" link

         $tmp = $urls{$key};
         $tmp =~ s/<a href=\"([^"]*)\"[^>]*>next 200/queue($1)/gem;

         # look for links in lists

         $tmp = $urls{$key};
         $tmp =~ s/<li><a href=\"([^"]*)\"/queue($1)/gem;

         # look for functions, constants, and events

         $tmp = $urls{$key};
         $tmp =~ s/<[^>]*>//g;
         $tmp =~ s/&lt;/</g;
         $tmp =~ s/&gt;/>/g;
         $tmp =~ s/&quot;/"/g;
         $tmp =~ s/Function:([^;\n]*);/do_function($1)/gem;
         $tmp =~ s/Constant:([^;\n]*);/do_constant($1)/gem;
         $tmp =~ s/Event:([^;\n]*);/do_event($1)/gem;

         # free up some memory

         $urls{$key} = "*COMPLETE*";
      }
   }
}

sub byname {
   $ta = $a;
   $tb = $b;

   $ta =~ s/^const //g;
   $ta =~ s/^event //g;
   $ta =~ s/^integer //g;
   $ta =~ s/^float //g;
   $ta =~ s/^string //g;
   $ta =~ s/^vector //g;
   $ta =~ s/^void //g;
   $ta =~ s/^rotation //g;
   $ta =~ s/^quaternion //g;
   $ta =~ s/^list //g;
   $ta =~ s/^key //g;

   $tb =~ s/^const //g;
   $tb =~ s/^event //g;
   $tb =~ s/^integer //g;
   $tb =~ s/^float //g;
   $tb =~ s/^string //g;
   $tb =~ s/^vector //g;
   $tb =~ s/^void //g;
   $tb =~ s/^rotation //g;
   $tb =~ s/^quaternion //g;
   $tb =~ s/^list //g;
   $tb =~ s/^key //g;

   $ta cmp $tb;
}

print sort byname @functions;
print sort byname @constants;
print sort byname @events;

###   # this is automated, but slightly less desireable because we lose the names of params
###   # in some cases and have to change them to arg1...
###   # it also loses some constant values (which we don't check now, but may in the future)
###   
###   my %typestr = (
###     'i' => 'integer',
###     's' => 'string',
###     'v' => 'vector',
###     'q' => 'rotation',
###     'f' => 'float',
###     'k' => 'key',
###     'l' => 'list'
###   );
###   
###   sub beginevent($) {
###      my $arg = shift @_;
###      foreach my $key (keys(%events)) {
###         if ($arg =~ /^$key/) {
###            return 1;
###         }
###      }
###      return 0;
###   }
###   
###   while (<STDIN>) {
###     # old style...
###     # addFunction(new LLScriptLibraryFunction(10.f, 0.f, dummy_func, "llGetParcelDetails", "l", "vl","list llGetParcelDetails(vector pos, list params)\nGets the parcel details specified in params for the parcel at pos.\nParams is one or more of: PARCEL_DETAILS_NAME, _DESC, _OWNER, _GROUP, _AREA"));
###     if (/^\s*addFunction\(new\ LLScriptLibraryFunction\(
###         [^,]+,[^,]+,[^,]+,          # ignore 10.f, 0.f, dummy_func (or whatever may be there)
###         \s*  "([^"]+)"  \s*,        # function name
###         \s*  (NULL|".") \s*,        # return type is either NULL or a single-letter string
###         \s*  (NULL|"[a-z]*") \s*,   # arg types is either NULL or a string with 1 letter per arg
###         \s*  "([^"]*)"/x)           # description
###     {
###       my $name = $1, $rtype = $2, $ptypes = $3, $desc = $4;
###       printf "%-8s ",  (($rtype eq "NULL") ? "void" : $typestr{substr($rtype,1,1)});
###       print $name;
###       if ($ptypes eq "NULL" || $ptypes eq '""') {
###         print "()";
###       } else {
###         print "(";
###         if ($desc =~ /^
###           [^(]+       # dont care about anything before open paren
###           \(
###             (.*?)
###           (\)|\\n|$)  # Some descriptions are missing ), but they should have \n
###           /x)
###         {
###           my $i = 0;
###           foreach $param (split(/\s*,\s*/, $1)) {
###             my $name;
###             (undef, $name) = split(/\s+/, $param);
###             print ", " if ( $i != 0 );
###             print "$typestr{substr($ptypes, ++$i, 1)} $name";
###           }
###         }
###         print ")";
###       }
###       print "\n";
###     }
###     # new style
###     # addFunction(10.f, 0.f, dummy_func, "llReleaseURL", NULL, "s");
###     elsif (/^\s*addFunction\(
###         [^,]+,[^,]+,[^,]+,          # ignore 10.f, 0.f, dummy_func (or whatever may be there)
###         \s*  "([^"]+)"  \s*,        # function name
###         \s*  (NULL|".") \s*,        # return type is either NULL or a single-letter string
###         \s*  (NULL|"[a-z]*")/x)     # arg types is either NULL or a string with 1 letter per arg
###     {
###       my $name = $1, $rtype = $2, $ptypes = $3;
###       printf "%-8s ",  (($rtype eq "NULL") ? "void" : $typestr{substr($rtype,1,1)});
###       print $name;
###       if ($ptypes eq "NULL" || $ptypes eq '""') {
###         print "()";
###       } else {
###         print "(";
###   
###         # bunch of savages in this town!
###         my $i = 0;
###         foreach $param (split(//, $ptypes)) {
###           if ($param ne '"') {
###             if ( $i != 0 ) { print ", " };
###             $i++;
###             print "$typestr{$param} arg$i";
###           }
###         }
###   
###         print ")";
###       }
###       print "\n";
###     }
###     elsif (/<event>/) {
###        my $tmp = $_;
###        $tmp =~ s/^.*<event>\s*//g;
###        chomp $tmp;
###        $events{$tmp} = 1;
###     }
###     elsif (beginevent($_)) {
###        $estate = 1;
###     }
###     elsif ($estate) {
###        my $tmp = $_;
###        my $i = 1;
###        $tmp =~ s/[':]//g;
###        $tmp =~ s/LLKEY/key/g;
###        $tmp = "event " . $tmp;
###        $tmp = lc($tmp);
###        $tmp =~ s/\s+/ /g;
###        $tmp =~ s/identifier/argidentifier/g;
###        $tmp =~ s/identifier/$i++/ge;
###        print "$tmp\n";
###        $estate = 0;
###     }
###     elsif (/^\".*_CONSTANT/) {
###        if (!$cheat) {
###           $cheat = 1;
###           print "const vector TOUCH_INVALID_TEXCOORD = <-1.0,-1.0,0.0>\n";
###           print "const vector ZERO_VECTOR = <0.0,0.0,0.0>\n";
###           print "const rotation ZERO_ROTATION = <0.0,0.0,0.0,1.0>\n";
###        }
###   
###        # "STATUS_PHYSICS"                { count(); yylval.ival = 0x1; return(INTEGER_CONSTANT); }
###        if (/^\"([^"]*)\"[^=]*=\s*([^;]*);.*INTEGER_CONSTANT/) {
###              print "const integer $1 = $2\n";
###        }
###        # "NULL_KEY"                              { yylval.sval = new char[UUID_STR_LENGTH]; strcpy(yylval.sval, "00000000-0000-0000-0000-000000000000"); return(STRING_CONSTANT); }
###        # "URL_REQUEST_GRANTED"   { yylval.sval = new char[UUID_STR_LENGTH]; strcpy(yylval.sval, URL_REQUEST_GRANTED); return(STRING_CONSTANT); }
###        elsif (/^\"([^"]*)\"[^"]*strcpy[^,]*,\s*([^)]*).*STRING_CONSTANT/) {
###           print "const string $1 = $2\n";
###        }
###        # "PI"                                    { count(); yylval.fval = F_PI; return(FP_CONSTANT); }
###        elsif (/^\"([^"]*)\"[^=]*=\s*([^;]*);.*FP_CONSTANT/) {
###              print "const float $1 = $2\n";
###        }
###        else {
###        print $_;
###        }
###     }
###   
###   }
