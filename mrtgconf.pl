#!/usr/bin/perl
#Database module
use DBI;
#print "\nPlease run the code as  root. If you haven't run the code as sudo please quit the program by pressing CRTL+C\n";
sleep 10;
#Retrieve config file parameters
do '../db.conf';
$mrtgDir = "/var/www/mrtg";
print "\nDevice monitoring information can be accessed from $mrtgDir/ \n";
sleep 1;
#Connect to database
our $Connect = DBI->connect( "DBI:mysql:database=$database;host=$host;port=$port",$username,$password ) or die $DBI::errstr;
#Extract ID,IP,PORT,COMMUNTIY
my $extract = $Connect->prepare("select id,IP,Port,Community from DEVICES");
$extract->execute() or die print $DBI::errstr;
#Create directory
eval{`mkdir -p $mrtgDir`};
sleep 1;
print "\nCreating config files in $mrtgDir directory\n";
#for each ID,IP,PORT ,COMMUNITY Create cfg file, demonize mrtg, create an index page
# Genarating Configuration files
while (my ($ID,$IP,$PORT,$COMMUNITYSTRING) = $extract->fetchrow_array()){
$dev = $dev."$COMMUNITYSTRING\@$IP:$PORT ";
}
print "device $dev\n";
eval{`cfgmaker --global "RunAsDaemon: Yes " --global "Options[_]: growright" --output=$mrtgDir/mrtg.cfg $dev`}; 
eval{`indexmaker --output=$mrtgDir/index.html $mrtgDir/mrtg.cfg`};
eval{`env LANG=C /usr/bin/mrtg $mrtgDir/mrtg.cfg`};
print "\nType localhost/mrtg to view graphs\n";
