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
my $srcFile  = "";
my $servers = "";
my $help;
my $revNum = 0;

  GetOptions ("servers=s"   => \$servers, # string
              "file=s"   => \$srcFile,      # string
              "rev=i"   => \$revNum,      # number
              "twoUser"  => \$twoUser, # flag 
	      "help" => \$help) or die("Error in command line arguments --s=serversFile --rev=RevNum --f=srcFile \n");

  if($help || length($servers) <=0 || length($srcFile) <=0 )
  {
	 die("Command line arguments --s=serversFile --f=srcFile \n");
  }


if( !(-f $servers))
{
	die "Can't find servers config file : $servers\n";
}

# set umask to allow group access
umask 022;
my $msk = umask;
# printf "umask = %0o\n", $msk;

my $svnUser="";
my $svnPassword="";
my $ensUser="";
my $ensPassword;

if($twoUser)
{
	print "SVN Username: ";
	chop($svnUser=<STDIN>);
	
	print "SVN Password: ";
	system('stty','-echo');
	chop($svnPassword=<STDIN>);
	system('stty','echo');
	
	print "\nEnsemble Username: ";
	chop($ensUser=<STDIN>);
	
	print "Ensemble Password: ";
	system('stty','-echo');
	chop($ensPassword=<STDIN>);
	system('stty','echo');
	print "\n";
}
else
{

	$svnUser = getpwuid( $< );

	print "Username: $svnUser\n";

	print "Password: ";
	system('stty','-echo');
	chop($svnPassword=<STDIN>);
	system('stty','echo');
	print "\n";

	$ensUser = $svnUser;
	$ensPassword = $svnPassword;
}

### my $svnUsrRootDir="/itf-testdata/$svnUser/EnsSrcDir/";
my $svnUsrRootDir="/itf-admin/ITFCOMMON/sync/";

if(! -d $svnUsrRootDir)
{
	mkpath $svnUsrRootDir;
}

# Get file from subversion
  my ($svnFileName, $svnFilePath, $svnDir) = getFileFromSvn($svnUser, "$svnPassword", "$subversionRep"."/"."$srcFile", $svnUsrRootDir, $revNum, 1);

  print "$svnFileName : $svnFilePath, $svnDir\n";
  if(length($svnFileName) <=0)
  {
 		if( !(-f  $svnFilePath))
		{
			die "Can't find source file to load: $svnFilePath\n";
		}
  }

  print "\nImport as $svnUser, load $svnFileName as $ensUser\n";
  print "\tEnter Y|N: ";
  chomp(my $input = <STDIN>);
    
  if ($input ne "Y" && $input ne "y")
  {
      deleteSvn();
      die "exiting\n";
  }

#
# open the file with server and port information
 print "Open $servers\n";
 open(openFl, $servers) or die "Can't open the file $servers";
 while(defined($line = <openFl>)) {
        chomp($line);
        if(length($line) < 2 || substr($line, 0, 1) eq '#') {
                next;
        }
        @params = split(',', $line);
	if($params[0] eq "" || $params[1] eq "")
	{
		print "Invalid line: $line $#params\n";
		next;
	}
        $mac = $params[0];
	$port = $params[1];
	# print "Conneting to Ensemble $mac:$port \n";
	
   eval {
      # Connect to the Cache' database
      $url = $mac . "[" . $port . "]:ITFCOMMON"; 
      print "\n------\nConnecting to $url as $ensUser\n----\n";
      $conn = Intersys::PERLBIND::Connection->new($url,$ensUser,"$ensPassword",0);
      $database = Intersys::PERLBIND::Database->new($conn);
      if(loadClassFile($svnFilePath, $svnFileName, "c") == 1)
      {
      	print "Loaded files to $url \n";
      }
};

if ($@) {
      print "Perl exception $@\n";
      deleteSvn();
      exit;
   }
}

#Delete files or not
  print "\n----------\nDo you want to delete $svnFilePath\n";
  print "\tEnter Y|N: ";
  chomp(my $input = <STDIN>);
    
  if ($input eq "Y" || $input eq "y")
  {
	deleteSvn();
  }

sub deleteSvn
{
	if( -f  $svnFilePath)
	{
		print "Delete $svnDir\n";
		system("rm -rf $svnDir");
	}
}

sub loadClassFile
{
    my $fileNm = shift;
    my $loadfileNm = shift;
    $loadfileNm = "./".$loadfileNm . "/LoadLog.xml";
    my $opt = shift;
    $errLog = "";
    $res = $database->run_class_method("%SYSTEM.OBJ", "Load", $fileNm, $opt, $loadfileNm, $errLog);
    if($res =~ /ERROR/)
    {
	return 0;
    }
    print "Ensemble SYSTEM.OBJ.Load $fileNm: result: $res  , $errLog logged to $loadfileNm\n";
    storeInfoToHistoryDB($ensUser,"$ensPassword",$fileNm, $srcFile);
    return 1;
}


sub storeInfoToHistoryDB
{
   # Message bank
   my $msgBnkMac="lp-itfprdfs01";
   my $msgBnkPort="3974";

 # print "  In sub: Parms = @_ \n";  
 my $usrNm = shift;
 my $passwd = shift;
 my $svnFile = shift;
 my $file = shift;

 # Connect to the MSG bank Cache' msgBnkDb
   $msgBnkUrl = $msgBnkMac . "[" . $msgBnkPort . "]:ITFCOMMON";
   print "Connecting to $msgBnkUrl \n";
   $msgConn = Intersys::PERLBIND::Connection->new($msgBnkUrl,$usrNm,$passwd,0);
   $msgBnkDb = Intersys::PERLBIND::Database->new($msgConn);
 #
 #
 my $cmd = "svn log --no-auth-cache --non-interactive --username  $svnUser  --password  \"$svnPassword\"  $svnFile";
 # print "$cmd\n";
 $stat = qx($cmd);
 if ( $stat != 0 )
 {
   print "svn command to get svn log failed: $!\n";
   return 1;
 }
 else
 {
   printf "$usrNm got information of file from subversion\n ";
   @lines = split("\n", $stat);
   # print "# of lines: $#lines\n";
   foreach $ln (@lines)
   {
     # looking for SVN like :
     # r410 | lpjnaras | 2014-12-08 14:46:26 -0700 (Mon, 08 Dec 2014) | 1 line
     if($ln =~ /^r[0-9]*/)
	{
		@flds = split(/\|/, $ln);
		$tm=localtime();
		$flds[0] =~ s/r//;
		# print "$file : $ENV{LOGNAME} : $flds[0] : SVN info:  $ln : $tm\n";
		$itfCls = $msgBnkDb->create_new("IHC.ITF.SrcCtrlPkg.ITFCOMMONClasses", undef);
		$itfCls->set("FileName", $file);
		$itfCls->set("UserName", $ENV{LOGNAME});
		$itfCls->set("Revision", $flds[0]);
		$itfCls->set("Instance", $url);
		$itfCls->set("ImplDtTm", $tm);
		$itfCls->set("Description", $ln);
		$res = $itfCls->run_obj_method("%Save");
        	print "Add to DB: $res\n";


		last;
	}
   }
   
   return 0;
 }
}

sub getFileFromSvn
{
my $svnUser = shift;
my $svnPassword = shift;
my $inpUrl = shift;
my $svnUsrRootDir = shift;
my $revNum = shift;

# Get file name - last part
my $inpFileName = basename($inpUrl);

# Get upto last directory
my $inpDirectoryUrl = dirname($inpUrl);

# Get last directory name
my $inpDirectoryName = basename($inpDirectoryUrl);

# print "$inpUrl, $svnUsrRootDir\n";
# print "$inpFileName, $inpDirectoryUrl , $inpDirectoryName\n";

my $svnFile=$svnUsrRootDir.$inpDirectoryName."/".$inpFileName;
# print "$svnFile\n";

 my $cmd = "";

       if( !$revNum || $revNum == 0)
	{
 		$cmd = "svn co --no-auth-cache --non-interactive --username  $svnUser  --password  \"$svnPassword\"  $inpDirectoryUrl $svnUsrRootDir$inpDirectoryName";
	}
	else
	{
 		$cmd = "svn co --no-auth-cache --non-interactive --username  $svnUser  --password  \"$svnPassword\"  --revision $revNum $inpDirectoryUrl $svnUsrRootDir$inpDirectoryName";
	}

 $stat = system($cmd);
 if ( $stat != 0 )
 {
   print "svn command failed to check out $subversionRep $inpUrl. :$!\n";
   return 1;
 }
 else
 {
   printf "$usrNm : Ran svn command to check out files from subversion\n";
   if (-e "$svnFile")
   { 
		print "\nFile Exists: $svnFile\n";
   }
   else 
	{
		print "\nCould not checkout file with svn co command, check the file path and also svn\n";
   		die;
	}
 }
 return ($inpFileName, $svnFile, $svnUsrRootDir.$inpDirectoryName);

}
