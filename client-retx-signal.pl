#!/usr/bin/perl
=Purpose
Takes the input folder of data files and creates another folder with different format of data
This is done to produce plots of no retransmissions with signal strength and link rate
ARGV[0] : directory from where input files for plotting have to be picked up
ARGV[1] : directory to dump new files
=cut
%mac_add=();

$index=0;
if (@ARGV!=2){
     print "Usage: ./client-retx-signal.pl <input data directory> <output data directory> \n" ;
     exit(1);
}
opendir(DIR, "./$ARGV[0]/")|| die ("Cannot open the directory\n");
my @files= readdir(DIR);
closedir(DIR);
print $ARGV[0], "\n";

foreach $f(@files){
    if(($f eq ".") || ($f eq "..") ) {
	next;
    }
    open FILE , "<","$ARGV[0]$f" or die "Cannot open the $f \n";    
    @lines = <FILE> ;
#We have the lines, we need to process each line 
#for finding the change in retransmission and dump it into a file
    @previous = split(/\s+/, $lines[0]);
    for ($i =1; $i<scalar(@lines);){
	@current= split(/\s+/, $lines[$i]);
	#print "i is ", $i, "\n";
	if($current[0]==$previous[0]){
	    if($current[10]-$previous[10]<120){
		local @diff_line=();
	#	print " in usual time lapse \n";
		$diff_line[0]=$current[0];
		$diff_line[1]=$current[1]-$previous[1];	$diff_line[2]=$current[2]-$previous[2];
		$diff_line[3]=$current[3]-$previous[3];	$diff_line[4]=$current[4]-$previous[4];
		$diff_line[5]=$current[5]-$previous[5];	$diff_line[6]=$current[6]-$previous[6];
		$diff_line[7]=$current[7];$diff_line[8]=$current[8];
		$diff_line[9]=$current[9]; $diff_line[10]=$current[10];
		push(@{$mac_add{$f}},\@diff_line);
#		print "difference=", $current[10]-$previous[10] ,"  " ;
#		print " pushed in first \n";
		@previous=@current;
		$i=$i+1;
	    }
	    else{
		#stat is collected on the same interface but the time difference is more than 120
		#hence shift the current and previous both to a new front leaving the previous ones
	
		@previous=@current;
		$i=$i+1;
		@current= split(/\s+/, $lines[$i]);
		local @diff_line=();
#		print "difference=", $current[10]-$previous[10] ,"  " ;
#		print "pushed here in last !! \n" ;
		$diff_line[0]=$current[0];
		$diff_line[1]=$current[1]-$previous[1];	$diff_line[2]=$current[2]-$previous[2];
		$diff_line[3]=$current[3]-$previous[3];	$diff_line[4]=$current[4]-$previous[4];
		$diff_line[5]=$current[5]-$previous[5];	$diff_line[6]=$current[6]-$previous[6];
		$diff_line[7]=$current[7];$diff_line[8]=$current[8];
		$diff_line[9]=$current[9];$diff_line[10]=$current[10];

		push(@{$mac_add{$f}},\@diff_line);

	    }
	}
	else
	{
	  #The interface has changed hence the 'previous' array won't work
#	    print "change in interface $current[0], $previous[0]\n";
	    @previous=@current;
	    $i=$i+1;
	    @current= split(/\s+/, $lines[$i]);
#	    print "after change in interface $current[0], $previous[0]\n";
#	    print "pushed here in last \n" ;
	    local @diff_line=();
	    $diff_line[0]=$current[0];
	    $diff_line[1]=$current[1]-$previous[1];
	    $diff_line[2]=$current[2]-$previous[2];
	    $diff_line[3]=$current[3]-$previous[3];
	    $diff_line[4]=$current[4]-$previous[4];
	    $diff_line[5]=$current[5]-$previous[5];
	    $diff_line[6]=$current[6]-$previous[6];
	    $diff_line[7]=$current[7];$diff_line[8]=$current[8];
	    $diff_line[9]=$current[9];$diff_line[10]=$current[10];
	    push(@{$mac_add{$f}},\@diff_line);
	}
    }
}
`mkdir -p $ARGV[1]` ;

foreach $key(sort keys %mac_add){
    print "key before is ",$key, " \n" ;
    $f_=">>$ARGV[1]/$key";
    print "\n", $f_, "\n";
    open (FILE,$f_) or die "can't create a file" ;
    @s = @{$mac_add{$key}};
    for($r_s_i=0;$r_s_i<scalar(@s);$r_s_i++){
        print FILE  ${$s[$r_s_i]}[0],  " ", ${$s[$r_s_i]}[1],   " ", ${$s[$r_s_i]}[2],  " ",  ${$s[$r_s_i]}[3],
	" ", ${$s[$r_s_i]}[4],  " ", " ", ${$s[$r_s_i]}[5], " ", ${$s[$r_s_i]}[6], " ", ${$s[$r_s_i]}[7], " ",
	${$s[$r_s_i]}[8], " ",${$s[$r_s_i]}[9],  " ", ${$s[$r_s_i]}[10], "\n";    
    }
    close(FILE);
}





