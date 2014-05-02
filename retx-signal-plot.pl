#!/usr/bin/perl
=Purpose
Takes the input folder of data files and creates gnuplot graph file as an output
ARGV[0] : directory from where input files for plotting have to be picked up
 ARGV[1] : pdf file name without extention
=cut

if (@ARGV!=1){
    print "Usage: ./retx-signal-plot.pl <input data directory>  \n" ;
    exit(1);
}
$filename= "'retx-signal-strength.pdf'";
$a ="
set terminal pdfcairo enhanced font \"Gill Sans,4\" linewidth 3 rounded
set output $filename 

# Line style for axes
set style line 80 lt rgb \"\#808080\"

# Line style for grid
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
set ylabel \" signal strength (dBm)\"
set xlabel \" no. of retransmission per minute \" \n";


#print $a;

opendir(DIR, "./$ARGV[0]") || die ("Cannot open the directory\n");
my @files= readdir(DIR);
closedir(DIR);
print $ARGV[0], "   ", @files,  "\n";
open (FILE, ">>./$ARGV[0]/plot") or die "Cannot create gnu plot file";
$color=0;
$count=0;
print FILE $a;
foreach $f(@files){
    if(($f eq ".") || ($f eq "..") ) {
	next;
    }
    
    if($count==0){
	print FILE "p ";
	$count++;    
    }
    print FILE "'./",$f,"' using 5:10 w p ps -1 pt ", $color++," title '", $f ,"' , ";
    
}
close(FILE);



