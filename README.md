iPhotoDump
=======

iPhotoDump is a Perl script to dump/backup iPhoto/Aperture metadata. It will
retrieve:

 Full Path (relative to your iPhoto/Aperture Master location)<br>
 FileName<br>
 Name<br>
 Date (real date, not a crazyass Apple date)<br>
 Size<br>
 Event<br>
 Description (if exists)<br>
 Rating (if exists)<br>

This is helpful if you wish to leverage additional scripts to upload your
files to 3rd party services (i.e flickr - http://www.panix.com/~eli/flickr/), 
or simply backup your metadata. 

Limitations
-----------
I don't use Albums or Smart Albums for keeping track of things, so I didn't
include that here.  I'm sure you could fuzz some more and get that info. If
you're into that sort of thing, this may be helpful to dump your data to files:
<pre>  $ for i in `sqlite3 Library.apdb '.schema' | grep TABLE | awk '{print
$3}'`; do sqlite3 Library.apdb "select * from $i" > /tmp/$i.out ; done
 $ for i in `sqlite3 Properties.apdb '.schema' | grep TABLE | awk '{print
$3}'`; do sqlite3 Properties.apdb "select * from $i" > /tmp/$i.out ; done

Configuration 
-------------
Make sure you change the location of your iPhoto/Aperture database to reflect where it really is.  This will probably be "/Users/<you>/Pictures/iPhoto Library/Database/"


Bugs/Contact Info
-----------------
Bug me on Twitter at [@brianwilson](http://twitter.com/brianwilson) or email me [here](http://cronological.com/comment.php?ref=bubba).


