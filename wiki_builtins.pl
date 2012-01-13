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
   $signature =~ s/^function //g;
   my @x = split / /, $signature;
   if ($x[0] ne lc($x[0])) {
      $signature = "void $signature";
   }
   $functions{"$signature\n"} = 1;
   print STDERR "#F# $signature\n";
}

sub do_constant($) {
   my $signature = shift(@_);
   $signature =~ s/^[ ]*//g;
   $signature = "const $signature";
   $constants{"$signature\n"} = 1;
   print STDERR "#C# $signature\n";
}

sub do_event($) {
   my $signature = shift(@_);
   $signature =~ s/^[ ]*//g;
   $signature =~ s/^event void /event /g;
   $events{"$signature\n"} = 1;
   print STDERR "#E# $signature\n";
}

sub parse_signature($) {
   my $signature = shift(@_);

   # generic cleanup
   $signature =~ s/\/\/.*//g;  # remove comments
   $signature =~ s/;.*//g;     # remove semicolons
   $signature =~ s/^\s*//g;    # leading whitespace
   $signature =~ s/\s*$//g;    # trailing whitespace

   if ($signature =~ /^event /) {
      do_event($signature);
   }
   elsif ($signature =~ /^function /) {
      do_function($signature);
   }
   elsif (length($signature)) {
      do_constant($signature);
   }
}

sub do_signature($) {
   my $signature = shift(@_);

#print STDERR "|||$signature|||";

   # common HTML escapes
   $signature =~ s/&lt;/</g;
   $signature =~ s/&gt;/>/g;
   $signature =~ s/&quot;/"/g;
   $signature =~ s/&amp;/&/g;

   # stupid stuff, errors in wiki templates?
   $signature =~ s/<span[^>]*>//g;
   $signature =~ s/<.span>//g;

   foreach my $sig (split /\n/, $signature) {
      parse_signature($sig);
   }
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
         $tmp =~ s/lsl-signature[^>]*>([^<]*)/do_signature($1)/gem;
         $tmp =~ s/<[^>]*>//g;
         $tmp =~ s/&lt;/</g;
         $tmp =~ s/&gt;/>/g;
         $tmp =~ s/&quot;/"/g;

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
   $ta =~ s/^function //g;

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
   $tb =~ s/^function //g;

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

print sort byname keys(%functions);
print sort byname keys(%constants);
print sort byname keys(%events);

