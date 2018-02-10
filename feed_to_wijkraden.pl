#!/usr/bin/perl
##################
## Read from sqlite3 db and send messages
## to the CMT api on localhost:8080i
##
## 2016-10-28 - Sjoerd de Boer - Initial Version
#
## Channel 1001138079024 - PPU Utrecht Aankondigingen
## Channel 1001103155828 - PPU Binnenstad
## Channel 1001100122742 - LeidscheRijn
## Channel 1001146121824 - PPU Overvecht
## Channel 1001133420624 - PPU Noordwest
## Channel 1001120871059 - PPU Noordoost
## Channel 1001131298771 - PPU Oost
## Channel 1001121898354 - PPU VleutenDeMeern
## Channel 1001129333130 - PPU West
## Channel 1001109818074 - PPU Zuid
## Channel 1001147084574 - PPU Zuidwest

my @wijken = < Binnenstad Overvecht Noordwest Noordoost Zuid Zuidwest Oost West LeidscheRijn VleutenDeMeern >;
my @ChanID = < -1001103155828 -1001146121824 -1001133420624 -1001120871059 -1001109818074 -1001147084574 -1001131298771 -1001129333130 -1001100122742 -1001121898354 >;

use DBI;
use Data::Dumper;
use WWW::Telegram::BotAPI;

## db info
my $driver = "SQLite";
my $database = "/home/pi/PPU/rss.db";
my $dsn = "DBI:$driver:dbname=$database";
my $userid = "";
my $password = "";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;

## telegram connect
my ($api) = WWW::Telegram::BotAPI->new (
    token => 'Zet hier je eigen Telegram API key neer'
);

for (my $i = 0;$i < @wijken; $i++) {
 
    print "Bezig met wijk $wijken[$i] \n";
    my $select = qq(select * from messages where postcode in (select postcode from postcodes where wijk = '$wijken[$i]') and send=1;);
    my $sth = $dbh->prepare($select);
    my $rc = $sth->execute() or die $DBI::errstr;
    if ($rc < 0){
        print $DBI::errstr;
    } 

    while(my @row = $sth->fetchrow_array()) {
      my $title=$row[2]; 
      my $descr=$row[3];
      my $link=$row[4];
      my $update = qq(update messages set SEND=2 where ID=$row[0];);
      my $sth = $dbh->prepare($update);
      my $rc = $sth->execute() or die $DBI::errstr;
      if ($rc < 0){
         print $DBI::errstr;
      } else {
         $title =~ s/&#xA0;/ /g;
         $title =~ s/&#x26;/&/g;
         $title =~ s/&#x27;//g;
         $title =~ s/&#039;//g;
         $title =~ s/&#x2026;/. /g;
         print "Zenden naar Channel $ChanID[$i] : $title\n";
         my $chatmsg = "$title => $descr => $link";
         $api->sendMessage ({
               chat_id => $ChanID[$i],
               text    => $chatmsg
         });
      }
    }
}

$dbh->disconnect();

