#!/usr/bin/perl
##################
## Read, filter and push content of rss
## feed to a sqlite db for further processing
##
## 2017-09-10 - Sjoerd de Boer - Initial Version
#
use XML::RSSLite;
use LWP::Simple;
use DBI;
use Data::Dumper;


## db info
my $driver = "SQLite";
my $database = "rss.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;

my @keywords = qw(Utrecht Piraten PPNL privacy);

my $rss_uri = "https://zoek.officielebekendmakingen.nl/staatsblad/rss";
my $content = get($rss_uri);

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

  if ($title =~ /$re/) {
     my $chatmsg= "$title $item->{link}";
     my $insert = qq(insert into messages (NAME, LINK, SEND) values ('$title','$item->{link}', 0));
     my $rc = $dbh->do($insert) or die $DBI::errstr;
  }
}

