#!/usr/bin/perl
=Purpose
Takes the input folder of data files and creates gnuplot graph file as an output
ARGV[0] : directory from where input files for plotting have to be picked up
 ARGV[1] : pdf file name without extention
=cut

if (@ARGV!=2){
    print "Usage: ./client-plot-generator.pl <input data directory> <output pdf filename>.pdf \n" ;
    exit(1);
}

$filename= "'". $ARGV[1] . ".pdf'";
$a="
set terminal pdfcairo enhanced font \"Gill Sans,4\" linewidth 3 rounded
set output $filename 

# Line style for axes
set style line 80 lt rgb \"\#808080\"

# Line style for grid
#set style line 81 lt 0  # dashed
#set style line 81 lt rgb \"#808080\"  # grey

#set grid back linestyle 81
#set border 3 back linestyle 80 
# Remove border on top and right.  These
# borders are useless and make it harder
# to see plotted lines near the border.
# Also, put it in grey; no need for so much emphasis on a border.
set xtics nomirror
set ytics nomirror

# Line styles: try to pick pleasing colors, rather
# than strictly primary colors or hard-to-see colors
# like gnuplot's default yellow.  Make the lines thick
# so they're easy to see in small plots in papers.
set style line 1 lt rgb \"#A00000\" lw 2 pt 1
set style line 2 lt rgb \"#00A000\" lw 2 pt 6
set style line 3 lt rgb \"#5060D0\" lw 2 pt 2
set style line 4 lt rgb \"#F25900\" lw 2 pt 9
set key below

#set yrange [0:1.0]

set autoscale # trying out 
set ylabel \" rx bitrate (Mbps)\"
set xlabel \" tx bitrate (Mbps) \" \n";

#print $a;

opendir(DIR, "./$ARGV[0]/")|| die ("Cannot open the directory\n");
my @files= readdir(DIR);
closedir(DIR);
print $ARGV[0];
open (FILE, ">>./$ARGV[0]/plot-x-r-t.gnu") or die "Cannot create gnu plot file";
print FILE $a;
$count =0;
$color=1;
foreach $f(@files){
    if(($f eq ".") || ($f eq "..") ) {
	next;
    }
    if ($count ==0){
	print FILE "p ";
        $count++;
    }
    print $f , "   " ;
    print FILE "\'./",$f,"\' using 8:9  w p ps -1 pt ", $color++," title '", $f ,"' ,";

}
close(FILE);


