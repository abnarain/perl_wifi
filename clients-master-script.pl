#!/usr/bin/perl
use Compress::Zlib ;

%router_stats_0=();
%router_stats_1=();
%station_stats=();

#
# There are two statistics maintained in the script 
# 1: Stats of diffrent errors of router per interface for different timestamps
# 2: Stats of different stations connected to router per interface per timestamp
# Each of them is a hash with key as bismark_id and mac_id of station respectively
# 

if (@ARGV!=3){
    print "Usage : ./master_script.pl <input folder> <station_stat output folder> <router_stat output folder> \n";
    exit(1);
}

`mkdir -p ./$ARGV[1]` ;
`mkdir -p ./$ARGV[2]` ;

opendir(DIR, "./$ARGV[0]")|| die ("Cannot open the directory\n");
my @files= readdir(DIR);
closedir(DIR);

foreach $f(@files){
    if(($f eq ".") || ($f eq "..") ) {
	next;
    }
    $f = "./$ARGV[0]". $f;
    $gz = gzopen($f, "rb") or die "Cannot open the $f \n";    
    $data ="";
    while ($gz->gzreadline($buffer) > 0 ){
	$data = $data. $buffer;	
    }
    @entries= split(/\n/ , $data);

    @ct=split(/\ /,$entries[0]);
    $timestamp=$ct[3]; $bismark_id=$ct[0]; shift(@entries);
    $data= join("\n", @entries);
    @entries= split(/--/ , $data); # for each section    

#   print "** $entries[0]**\n";
# error statistics are collected here
    $entries[0]=~s/\n//g;
    @entry0= split(/\^/,$entries[0]);
    
    @array00=split(/\|/,$entry0[0]);
    @array01=split(/\|/,$entry0[1]);

    $crc_err_0=$array00[0] ;
    $phy_err_0= $array00[1];
    $rec_packets_0=$array00[2] ;
    $rec_bytes_0=$array00[3] ;

    $crc_err_1=$array01[0] ;
    $phy_err_1= $array01[1];
    $rec_packets_1= $array01[2];
    $rec_bytes_1= $array01[3];

#iw statistics are collected here
    @entry2= split(/^/,$entries[2]);
    @array21=split(/\|/,$entry2[1]);
    $frequency21=join('.',$array21[1],$array21[2]);
    $tx_power_21=$array21[3];
    chomp($tx_power_21);
    $channels_21=$array21[0];
    
#    print "freq: ",$frequency21," tx power : ",$tx_power_21,"  c:" , $channels_21 ;
    @array23=split(/\|/,$entry2[3]);
    $frequency23=join('.',$array23[1],$array23[2]);
  
    $tx_power_23=$array23[3];
    chomp($tx_power_23);
    $channels_23=$array23[0];
#    print "\nfreq: ",$frequency23," tx power : ",$tx_power_23,"  c:", $channels_23;    
    { local @stats_0;
      local @stats_1;
      @stats_0=(0,$crc_err_0,$phy_err_0,$rec_packets_0,$rec_bytes_0,$channels_21,$frequency21,$tx_power_21,$timestamp);
      @stats_1=(1,$crc_err_1,$phy_err_1,$rec_packets_1,$rec_bytes_1,$channels_23,$frequency23,$tx_power_23,$timestamp);
      push(@{$router_stats_0{$bismark_id}},(\@stats_0));
      push(@{$router_stats_1{$bismark_id}},(\@stats_1));
    }

# To calculate per station characteristics
#    print "\n\n##$entries[1] ##\n\n";
    $entries[1]=~s/\n/ /g;
    @entry1= split(/\^/,$entries[1]);
#   foreach $r (@entry1){
#	print ">",$r,"<\n";
#   }
    
#now you split on $$ for each of the devices connected at home
#    print " 0",$entry1[0], "0\n";  
#  print "1",$entry1[1], "1 " ;
=start
    station   ,rx_packets , rx_bytes , 
    tx_packets,tx_bytes   ,tx_retries,
    tx_failed ,tx_rate_i  ,tx_rate_d ,
    rx_rate_i ,rx_rate_d  ,-signal_avg
=cut 
    @devices_on_phy0= split(/\$\$/,$entry1[0]);
   
    for ($p0=0;$p0<scalar(@devices_on_phy0)-1;$p0++){
#	print $p0," *" , $devices_on_phy0[$p0],"*\n";
	$devices_on_phy0[$p0]=~s/\s+//g;
	@mac_stats=split(/\|/, $devices_on_phy0[$p0]);
	if(scalar(@mac_stats)!=12){
	    print "panic in phy0\n" ;
	}
#        print "stats are :",scalar(@mac_stats)," \n"; #$mac_stats[12] is 0 essentially as it does not have any value stored in it.
	{ local @l ;
	  @l= (0, $mac_stats[1], $mac_stats[2], $mac_stats[3], $mac_stats[4]
	       , $mac_stats[5], $mac_stats[6], $mac_stats[7], $mac_stats[8], $mac_stats[9]
	       , $mac_stats[10], $mac_stats[11], $mac_stats[12],$timestamp);
	  push(@{$station_stats{$mac_stats[0]}},\@l);
	  print " $mac_stats[0]  l[1] is " , $l[1], "\n";
	}
    }	

    @devices_on_phy1= split(/\$\$/,$entry1[1]);
    for ($p1=0;$p1<scalar(@devices_on_phy1)-1;$p1++){
#	print $p1," *" , $devices_on_phy1[$p1],"*\n";
	$devices_on_phy1[$p1]=~s/\s+//g;
	@mac_stats=split(/\|/, $devices_on_phy1[$p1]);
	if(scalar(@mac_stats)!=12){
	    print "panic in phy1\n" ;
	}
	{local @l ;
	 @l=(1, $mac_stats[1], $mac_stats[2], $mac_stats[3], $mac_stats[4]
	    , $mac_stats[5], $mac_stats[6], $mac_stats[7], $mac_stats[8], $mac_stats[9]
	    , $mac_stats[10], $mac_stats[11], $mac_stats[12],$timestamp);
	 push(@{$station_stats{$mac_stats[0]}},\@l);
	 print " $mac_stats[0]  l[1] is " , $l[1], "\n";
	}
    }
}

foreach $key(sort keys %router_stats_0){
    print "key before is ",$key, " 0\n" ;
    $f_=">>./$ARGV[2]/$key"."_0";
    print "\n", $f_, "\n";
    open (FILE,$f_) or die "can't create a file" ;
    @arr = @{$router_stats_0{$key}};
    @s= sort {@{$a}->[8] cmp @{$b}->[8]} @arr;
    for($r_s_i=0;$r_s_i<scalar(@s);$r_s_i++){
	print  FILE ${$s[$r_s_i]}[0],  " ", ${$s[$r_s_i]}[1],   " ", ${$s[$r_s_i]}[2],  " ",  ${$s[$r_s_i]}[3],
	" ", ${$s[$r_s_i]}[4],  " ", " ", ${$s[$r_s_i]}[5], " ", ${$s[$r_s_i]}[6], " ", ${$s[$r_s_i]}[7], " ",
	${$s[$r_s_i]}[8], "\n";
    }
    close(FILE);
}
foreach $key(sort keys %router_stats_1){
    print "key before is ",$key, " 1\n" ;
    $f_=">>./$ARGV[2]/$key"."_1";
    print "\n", $f_, "\n";
    open (FILE,$f_) or die "can't create a file" ;
    @arr = @{$router_stats_1{$key}};
    @s= sort {@{$a}->[8] cmp @{$b}->[8]} @arr;
    for($r_s_i=0;$r_s_i<scalar(@arr);$r_s_i++){
	print  FILE ${$s[$r_s_i]}[0],  " ", ${$s[$r_s_i]}[1],   " ", ${$s[$r_s_i]}[2],  " ",  ${$s[$r_s_i]}[3],
	" ", ${$s[$r_s_i]}[4],  " ", " ", ${$s[$r_s_i]}[5], " ", ${$s[$r_s_i]}[6], " ", ${$s[$r_s_i]}[7], " ",
	${$s[$r_s_i]}[8], "\n";
    }
    close(FILE);
}

=start
input format :  interface, rx_packets,rx_bytes,tx_packets , tx_bytes, tx_retries,tx_failed ,tx_rate_i,tx_rate_d, rx_rate_i,rx_rate_d ,-signal_avg, timestamp
output file :   interface, rx_packets,rx_bytes,tx_packets , tx_bytes, tx_retries,tx_failed ,tx_rate_i.tx_rate_d, rx_rate_i.rx_rate_d ,-signal_avg, timestamp

=cut 
foreach $key( sort keys %station_stats){
   print "\nkey is ",$key, "\n" ;
   open (FILE,">>./$ARGV[1]/$key") or die "can't create a file" ;    
   @arr = @{$station_stats{$key}};
   @s= sort {@{$a}->[13] cmp @{$b}->[13]} @arr;
   if ($key eq ""){
	$key="null";
	print " ------------- NULL FOUND ----------------------";
   }
   for( $r=0;$r<scalar(@s);$r++){ 
       @temp=@{$s[$r]};
       print FILE $temp[0], " ",$temp[1], " ",$temp[2], " ",$temp[3], " ",$temp[4], " ",$temp[5], " ",
       $temp[6], " ",$temp[7], ".",$temp[8], " ",$temp[9], ".",$temp[10], " ",-$temp[11], " ",$temp[12], " ",$temp[13], "\n";
   }
   close (FILE);
}
print "\n";
