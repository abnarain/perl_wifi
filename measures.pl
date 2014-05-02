#!/usr/bin/perl
use Math::Complex
opendir(DIR, "./$ARGV[0]/")|| die ("Cannot open the directory\n");
my @files= readdir(DIR);
$avg=0;
$square_sum=0;
$sum=0;
$interval = 5; 
closedir(DIR);
foreach $f(@files){
    if(($f eq ".") || ($f eq "..") ) {
        next;
    }
    open FILE , "<","$ARGV[0]/$f" or die "Cannot open the $f \n";    
    open FILE_WRITE , ">","$ARGV[0]/$f-variance" or die "Cannot open the $f \n";    
    @lines = <FILE> ;
    @previous = split(/\s+/, $lines[0]);
    my @t;
    $ref_time= $previous[0];
    print "ref time" , $ref_time,"\n";
    push (@t,\@prev);
    for ($i=1; $i<scalar(@lines);$i++){	
        @current= split(/\s+/, $lines[$i]);
	if($current[0] - $ref_time < $interval){
	    local @temp ;
	    @temp=@current ;
	    push (@t, \@temp) ;
	}
	else{	    
	    if( $#t >0){
		#calculate mean
		$sum=0;
		for $k ( 1 .. $#t ) {
		    print " -*- $t[$k][0]\n";		
		    $sum+=$t[$k][0];
		}
		$avg=$sum/$#t; 
		print "avg is ", $avg, ", index is $#t\n";
		#calculate variance 
		$square_sum=0 ;
		for $k ( 1 .. $#t ) {
		    print "-- $t[$k][0]\n";		
		    $square_sum+=($t[$k][0]-$avg)*($t[$k][0]-$avg);
		    print  $t[$k][0]-$avg , "\n" ;
		}
		$standard_dev = sqrt($square_sum/($#t-1));
		print "standard dev is ",$standard_dev, " \n" ;
		#now get the time 		
		print "median time can be found by the index ", int($#t/2), "\n";
		print FILE_WRITE "$avg $standard_dev\n";
	    }
	    @previous=@current;
	    $ref_time=$previous[0];
	    @t=[]; 
	    $i=$i-1;	    
	}
    }
    close(FILE);
    close(FILE_WRITE);


}
