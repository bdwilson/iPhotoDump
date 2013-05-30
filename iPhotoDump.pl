#!/usr/bin/perl
#
# Dump iPhoto/Aperture Info (Full Path/FileName/Name/Date/Size/Event/Description/Rating)
#
# This is helpful if you wish to leverage additional scripts to upload your
# files to 3rd party services, or simply backup your metadata. Make sure you
# change the location of your iPhoto/Aperture database to reflect where it
# really is. 
#
# 5/29/2013 - bubba@bubba.org
#
# Fuzzing DB fun... 
# To get Image data:
# 
# in RKVersion 'select modelId, fileName, name, projectUuid, mainRating from RKVersion';
# 
# To get Event data:
# 
# select uuid, name from RKFolder where uuid=projectUuid;
#
# Descriptions:
# 
# in Properties.apdb:
# 
# select versionId from RKIptcProperty where stringId=33927

# select modelId, stringProperty from RKUniqueString 
# 33927|Thursday - the calmest day of the week!
# 

use DBD::SQLite;
use POSIX qw(strftime);

$library_db="/tmp/Library.apdb";
$prop_db   ="/tmp/Properties.apdb";

# I made this shit up. just kidding.
# http://www.ipadforums.net/ipad-help/84074-ipad-internal-date-format.html
$unixOffset=978307200; 

my $dbl = DBI->connect("dbi:SQLite:dbname=$library_db","","");

my $database = "attach database \"$library_db\" as L";
$dbl->do($database);
my $database = "attach database \"$prop_db\" as P";
$dbl->do($database);

#$query ="select V.modelId, V.fileName, V.name, (select name from L.RKFolder as
#F where V.projectUuid=F.uuid),(select stringProperty from P.RKUniqueString as U
#where U.modelId=(select stringId from P.RKIptcProperty as I where
#I.versionId=V.modelId and I.propertyKey='Caption/Abstract')), V.mainRating from
#L.RKVersion as V where 1"; 
$query = "select M.imagePath, V.imageDate, M.fileSize, V.fileName, V.name,
(select name from L.RKFolder
as F where V.projectUuid=F.uuid),(select stringProperty from P.RKUniqueString
as U where U.modelId=(select stringId from P.RKIptcProperty as I where
I.versionId=V.modelId and I.propertyKey='Caption/Abstract')), V.mainRating from
L.RKVersion as V inner join L.RKMaster as M on V.masterUuid=M.uuid order by
V.imageDate";

my $stl = $dbl->prepare($query);
$stl->execute();
      
while(my ($imagePath, $imagedate, $filesize, $filename, $name, $eventname, $description, $rating) = $stl->fetchrow()) {
	        next if ($filename =~ /\d{10}\_[a-z0-9]+\_o/);  # ignore temporary? images created from flickr syncing process
		$imagedate = strftime "%a %b %e %H:%M:%S %Y", localtime($imagedate+$unixOffset);
		$items{"$imagePath"}{'imagedate'}=$imagedate;
		$items{"$imagePath"}{'filesize'}=$filesize;
		$items{"$imagePath"}{'filename'}=$filename;
		$items{"$imagePath"}{'name'}=$name;
		$items{"$imagePath"}{'event'}=$eventname;
		if ($description) {
			$items{"$imagePath"}{'description'}=$description;
	        }
		if ($rating > 0) { 
			$items{"$imagePath"}{'rating'}=$rating;
		}
}


foreach $item (sort keys %items) {
	print "FilePath: $item\n";
	foreach $val (keys %{$items{$item}}) {
		print "\t$val => $items{$item}{$val}\n";
	}
}

