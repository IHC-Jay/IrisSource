#!/usr/bin/perl
### Script to load ITFCOMMON package to multiple environments
# Auther: Jay Narasipura
# Needs 2 parameters
# server file
# file(s) to load

use lib '/CLIN/CLINDEVLPV01/dev/perl';
require "PERLBIND.pm";
use Intersys::PERLBIND;

use File::Path;
use File::Basename;
use File::Spec;
use File::Temp;
use Getopt::Long;


my $subversionRep =  "https://subversion.co.ihc.com/ITF_Ensemble/trunk";
my $servers = "";
my $fileList = "";
my $command = "";
my $nameSpace = "";
my $help;
my $helpStr = "Command line arguments --s=server --n=NAMESPACE --f=componentsFile --c=COMMAND \n";
my @compArray;
my $nmObj;

  GetOptions ("server=s"   => \$server, # string
              "file=s"   => \$file, # string
              "nameSpace=s"   => \$nameSpace, # string
              "command=s"   => \$command, # string
	      "help" => \$help) or die("$helpStr");

  if($help)
  {
	 die("$0: $helpStr");
  }
  if(length($server) <=0  || length($nameSpace) <=0  || length($file) <=0  || length($command) <=0 )
  {
	 die("ERROR: $helpStr");
  }


if( !(-f $file))
{
	die "Can't find component file :$file\n";
}


#
# parse the server and port information
 #print "Open $server\n";
        @params = split(':', $server);
	if($params[0] eq "" || $params[1] eq "")
	{
		print "Invalid sever $line $#params\n";
		exit;
	}
        $mac = $params[0];
	$port = $params[1];
	# print "Conneting to Ensemble $mac:$port \n";
	
my $ensUser = getpwuid( $< );
my $ensPassword;


	print "Server: $server, User: $ensUser, Type Password: ";
	system('stty','-echo');
	chop($ensPassword=<STDIN>);
	system('stty','echo');
	print "\n";


   eval {
      # Connect to the Cache' database
      $url = $mac . "[" . $port . "]:"."ITFCOMMON"; 
      print "\n------\nConnecting to $url as $ensUser\n----\n";
      $conn = Intersys::PERLBIND::Connection->new($url,$ensUser,"$ensPassword",0);
      print "$conn\n";
      $database = Intersys::PERLBIND::Database->new($conn);
      if(GetList($nameSpace) >= 1)
      {
        # open the file with components
        print "Opening file: $file\n";
        open(openCompList, $file) or die "Can't open the file $file";
        my $res = "";
        while(defined($comp = <openCompList>)) {
           chomp($comp);
 	   if(length($comp) > 0 && ($comp ~~ @compArray) )
	   {
           	if(uc($command) eq "START")
		{
			$res = $nmObj->startComponent($comp);
		}
		else
		{
           		$res = $nmObj->stopComponent($comp);
		}
           	print "\n\t$comp: Status: $res\n";
	   }
	   else
	   {
		print "\n**** Invalid component name: $comp ****\n";
	   }
        }
      }
/*
      while (1)
      {
        my $ans = <STDIN>;
        chomp $ans;
        if(uc($ans) =~ "Y")
        {
                exit;
        }
        else
        {
                print "Run the start the component: $ans\n";
		$res = $nmObj->startComponent($ans);
		print "\t$res\n";
        }

      }
*/
    };

sub GetList
{
    my $nmSp = shift;
    # print "Create class in $nmSp $database\n";
    $nmObj = $database->create_new("IHC.ITF.ITFCOMMON.Util.Monitor", undef);
    # print "Object created: $nmObj\n";
    $arrayref = $nmObj->getList($nmSp);
    if($arrayref =~ /ERROR/)
    {
	return 0;
    }
    @compArray = @$arrayref;
    print "\nNumber of components: " . scalar(@compArray)."\n";
    
    # for ($i=0;$i<scalar(@compArray);$i++) {
    #       print " element ",$i+1," = [$compArray[$i-1]]\n";
    #  }
   

    return scalar(@compArray);
}

