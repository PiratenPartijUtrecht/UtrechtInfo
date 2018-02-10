#!/usr/bin/perl
##################
## Read from sqlite3 db and send messages
## to the CMT api on localhost:8080i
##
## 2016-10-28 - Sjoerd de Boer - Initial Version
#
## Channel is 1001138079024 - PPU Utrecht Aankondigingen

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

my $select = qq(select ID, NAME, DESCR, LINK from messages where SEND=0;);
my $sth = $dbh->prepare($select);
my $rc = $sth->execute() or die $DBI::errstr;
if ($rc < 0){
    print $DBI::errstr;
} 

## telegram connect
my ($api) = WWW::Telegram::BotAPI->new (
    token => 'Zet hier je eigen Telegram API key'
);

while(my @row = $sth->fetchrow_array()) {
    my $title=$row[1]; 
    my $descr=$row[2];
    my $link=$row[3];
    my $update = qq(update messages set SEND=1 where ID=$row[0];);
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
         ##print "T: $title\n";
         my $chatmsg = "$title => $descr => $link";
         $api->sendMessage ({
               ##chat_id => '-229153649',
               chat_id => '-1001138079024',
               text    => $chatmsg
         });
    }
}

$dbh->disconnect();

