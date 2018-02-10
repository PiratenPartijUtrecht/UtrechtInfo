#!/usr/bin/perl
##################
## Read, filter and push content of rss
## feed to a sqlite db for further processing
##
## 2017-09-10 - Sjoerd de Boer - Initial Version
#
use XML::RSSLite;
use LWP::UserAgent;
use DBI;
use Data::Dumper;

require HTTP::Cookies;

my $ua = new LWP::UserAgent;
$ua->agent('PirateBot/1.0');
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
$ua->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);

## db info
my $driver = "SQLite";
my $database = "/home/pi/PPU/rss.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;

my @keywords = qw(Utrecht Piraten PPNL privacy);

my $rss_uri = "http://zoek.officielebekendmakingen.nl/gemeenteblad/rss";
my $req = new HTTP::Request('GET',$rss_uri);

my $res = $ua->request($req);
##print $res->code,\"n";
#print $res->message;

$content = $res->content;

# parse
my %result;
parseRSS(\%result, \$content);

#build regex
my $re = join "|", @keywords;
$re = qr/\b(?:$re)\b/i;

#print matching items
foreach my $item (@{ $result{items} }) {

  my $title = $item->{title};
  $title =~ s{\s+}{ };  $title =~ s{^\s+}{  }; $title =~ s{\s+$}{  };

  my $descr = $item->{description};
  $descr =~ s{\s+}{ }; $descr =~ s{^\s+}{  }; $descr =~ s{\s+$}{  }; $descr =~ s/  / /g;
  $descr =~ s/'//g;

  if ($title =~ /$re/) {
     my $link=$item->{link};
     $link =~ s/.html//g;
     my $TMP=`wget --no-check-certificate -qO - $link | grep postcode | grep content`;
     chomp ($TMP);
     #print "S: $TMP\n";
     @TMP1 = split /=/, $TMP;
     my $postcode= substr $TMP1[2],1,4;
     if ( length($postcode) < 4 ) { $postcode="0000"; };
     #print "P: $postcode\n";
     my $insert = qq(insert into messages (POSTCODE, NAME, DESCR, LINK, SEND) values ($postcode,'$title','$descr','$item->{link}', 0));
     #print "T: $title\n";
     #print "L: $link\n";
     #print "D: $descr\n";
     #print "I: $insert\n";
     my $rc = $dbh->do($insert) or die "T: $title\n $L: $link\n D: $descr\n E: $DBI::errstr";
  }
}

