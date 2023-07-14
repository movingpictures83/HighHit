use strict;
use warnings;

my $filename;
#my $filename = 'brenda_download.txt';
#my $filename = 'brenda_download_shorter.txt';
#my $filename = 'test.txt';
my $fh;
my $prefix;
my $limit;#=100;	
my $reactionFound;# = "no";
my %wordsCountHash;
my $openParenthesis = "no";
my $metaboliteCharNum;
$| = 1; # Force flushing
my @rowsarray;
my $buildrow;
my $k;
my $v;
my %lowHits;
my %highHits;

my $highcount=0;
 
sub input {
   $filename = @_[0];
open($fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open file '$filename' $!";
}

sub run {
	$limit=100;
	$metaboliteCharNum=0;
	$reactionFound = "no";
	$buildrow="";
while (my $row = <$fh>) 
{

    chomp $row;
  
    if($row eq "REACTION")
    {
        $reactionFound = "yes";
    }

    elsif($reactionFound eq "yes")
    {
        if($row eq "")
        {
            $reactionFound = "no"; 
			if ($buildrow ne ""){
				push @rowsarray, $buildrow;
				#print "2.buildrow=$buildrow\n";
				$buildrow="";
			}
			
        }
        else
        {
            my @aa=split("\t", $row);
            if(@aa > 1 && $aa[0] eq "RE") # RE row
            {
				#print "RE row=$aa[1]\n";
				$aa[1] =~ s/^\s+|\s+$//g; # trim white space
                $row=$aa[1];
				$openParenthesis="no";
            }
            if ($openParenthesis eq "yes"){ # previous line had ( parenthesis
				#print "3. next\n";
				next;
			}
            @aa=split("\Q(#\E", $row); # Split at Parenthesis

            if(@aa > 1) #has an open parenthesis followed by # which symbolizes a comment
            {
				$openParenthesis="yes";
				$aa[0] =~ s/^\s+|\s+$//g; # trim white space
				$buildrow=$buildrow." ".$aa[0];
				push @rowsarray, $buildrow;
				#print "buildrow=$buildrow\n";
				$buildrow="";
				
            }else{
				$buildrow=$buildrow. " ".$row;

			}


 
        } 
    }
}

close($fh);

foreach (@rowsarray){
	my $row=$_;
	
          # my @words = split(/[ ]+/,$aa[0]);
            my @words = split(/\s\+\s|\s\=\s/,$row); # split on either " + " or " = "

            for my $word (@words) 
            {
				$word =~ s/^\w$//; # remove if it is single number or letter
				$word =~ s/^\w\s//; # remove if it is "a" or a number followed by space
				$word =~ s/^\s+|\s+$//g; # trim white space
				if($metaboliteCharNum == 1){
					$word =~ s/[^a-zA-Z0-9\+]//g; # Optional: keep only letters and numbers and pluses
				}

				chomp($word);
				next if ($word eq "");
				if (exists $wordsCountHash{$word} ) 
				{
					$wordsCountHash{$word}+=1;
				} 
				else 
				{
					$wordsCountHash{$word}=1;
				}

            }	
}

while ( ($k,$v) = each %wordsCountHash ) 
{
    if($v<$limit)
    {
        $lowHits{$k}=$v;
    }
    else
    {
	$highcount++;
        $highHits{$k}=$v;
    }
}
}

sub output {
$prefix = @_[0];

if($metaboliteCharNum == 1){
	open (OUTFILE, ">".$prefix."/Brenda_low_hits.txt")|| die "Can't open Brenda_low_hits.txt\n";
}
else{
	open (OUTFILE, ">".$prefix."/Brenda_low_hits_fullname.txt")|| die "Can't open Brenda_low_hits_fullname.txt\n";
} 


print("LowHits: \n");
while ( ($k,$v) = each %lowHits ) {
    print OUTFILE "$k = $v hits\n";
	print ".";

}

close (OUTFILE);



if($highcount>0){
print "\nhighcount=$highcount\n";
							
if($metaboliteCharNum == 1){
	open (OUTFILE, ">".$prefix."/Brenda_high_hits.txt")|| die "Can't open Brenda_high_hits.txt\n";
}else{
	open (OUTFILE, ">".$prefix."/Brenda_high_hits_fullname.txt")|| die "Can't open Brenda_high_hits_fullname.txt\n";
}
																									 
 

	print("\nHighHits: \n");
	while ( ($k,$v) = each %highHits ) {
		print OUTFILE "$k = $v hits\n";
		print ".";


	}
	close (OUTFILE);
}
}


;
