#!perl-5.10

use strict;
use Carp;
use v5.10; #make use of the say command and other nifty perl 10.0 onwards goodness
use Common::Sense;
use Net::Amazon;
use IO::Prompt::Simple;
use YAML;

#enable these for more verbose logging
#use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);

#set the version number in a way Getopt::Euclid can parse
BEGIN { use version; our $VERSION = qv('0.1.1_1') }

use Getopt::Euclid; # Create a command-line parser that implements the documentation below... 

my $file = $ARGV{-f};
my  $csv;

#get the google login data
my $amazon_details = YAML::LoadFile($ENV{HOME} . "/.amazon_login")
    or die "Failed to read $ENV{HOME}/.amazon_login - $!";
           
if ( defined($file) ) 
{ 
	open $csv, '>', $file or croak "Couldn't open $file: $!";
	#print the header
	print {$csv} 
    "title, ".
    "author, ".
    "ListPrice, ".
    "OurPrice, ".
   	"UsedPrice, ".
   	"\n"  or croak "Couldn't write to $csv because: $!";

}
           
my $ua = Net::Amazon->new(
        token      => $amazon_details->{token},
        secret_key => $amazon_details->{secret_key},
        associate_tag => $amazon_details->{associate_tag},
        locale        => 'uk', #you can change this to your preferred locale
);

#continue looping this until told to stop
while ( 1 )
{
	my $answer = prompt 'Enter an ISBN (enter "q" to exit): ';

	if ($answer eq "q") 
	{
		if ( defined($file) ) { close $csv or croak "Couldn't close $csv because: $!"; }
		exit; 
	}

	# Get a request object
  	my $response = $ua->search(isbn => $answer);

  	if($response->is_success()) 
  	{
      #print $response->as_string(), "\n";
            for my $prop ($response->properties) 
            {
          		print "\n". 
                $prop->title(). ", ".
          		$prop->author(). ", ".
                #$prop->Availabilty(). ", ".
                $prop->ListPrice().  ", ".
                $prop->OurPrice().  ", ".
                $prop->UsedPrice().  ", ".
                "\n" ;
                if ( defined($file) )
                {
                #and now to the file
     	           print {$csv} 
        	        $prop->title(). ", ".
          			$prop->author(). ", ".
                	#$prop->Availabilty(). ", ".
        	        $prop->ListPrice().  ", ".
            	    $prop->OurPrice().  ", ".
                	$prop->UsedPrice().  ", ".
                	"\n"   or croak "Couldn't write to $csv because: $!";
                }
            }
  	} 
  	else 
  	{
      print "Error: ", $response->message(), "\n";
  	}
}#end of while loop


__END__
=head1 NAME

AmazonPriceChecker - script to take an ISBN at the command line, return information, 
	optionally to a CSV file.

Return's Title, Author, List Price, Amazon's Price and the Used Price, e.g.;
Deadline (Newsflesh Trilogy), Mira Grant, £7.99, £4.69, £3.83,

The script will continue looping round asking for an ISBN untill you enter 'q' to quit.

You will need your personal amazon developer's token (can be obtained from http://amazon.com/soap).

<b> Note</b> The script expect to find a file called ~/.amazon_login and will fail if it can't.
It's a YAML file and follows the following format;

 ---
 token: my_amazon_token
 secret_key: my_amazon_key
 associate_tag: tag





=head1 USAGE

    AmazonPriceChecker.pl  [-f] 

=head1 OPTIONS

=over

=item  -f[ile] [=] <file>

Specify file to write the output to [default: AmazonPriceChecker.csv]


=for Euclid:
    file.type:    writable 
    file.default: 'AmazonPriceChecker.csv'


=item --version

=item --usage

=item --help

=item --man

Print the usual program information

=back

=begin remainder of documentation here. . .

