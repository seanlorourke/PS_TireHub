#! /usr/local/bin/perl -w
#By: Keith L Thompson

### Load the default libraries
use Getopt::Std;

our ($opt_e,$opt_h,$opt_o,$opt_s,$opt_v) = ('.*SQLDBCode: 999.*',0,600,'C:/tmp/TireHub',0);

### Parse the command line options
getopts('e:ho:s:v');

### Help message
if ($opt_h) {
	print "Supported Parameters:\n";
	print " -e: The ERE to seach for within the file name ($opt_e)\n";
	print " -o: Within the number of seconds old the file needs to be ($opt_o)\n";
	print " -s: The source folder ($opt_s)\n";
	print " -v: Verbose ($opt_v)\n";
	print " -h: This help message\n";
	exit 0;
}

my $fileFilter = ".*\.err";
my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks);
my ($fqf, $errorFound);

opendir(SDIR, ${opt_s}) || die("Error: $!");
foreach(readdir(SDIR)) {
	#Get the fully qualified file name, just in case we need it for stat()
	$fqf = "${opt_s}" . "/" . $_;
	if (/$fileFilter/) {
		#print "$fqf" . "\n";
		($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($fqf);
		#get the elapsed time in seconds
		$etime = (time() - $mtime);
		#print ("How Old is old in seconds:" . $etime . "\n");
		if ($etime < ${opt_o}) {
			print ("${fqf} is ${etime} seconds old\n");
			### open the file for reading and modifying
			$errorFound = 0;
			open(FIN, "< ${fqf}") or die "Can't open ${fqf} for input; error $!";
			while (defined($line = <FIN>) && !${errorFound} ) {
				if ($line =~ m/${opt_e}/i) {
					if (${opt_v}) {
						print("${line}");
						print("Sending NSCA...\n");
					}
					$cmd="\"C:/Program Files/PS/PSUtil/bin/NSClientSender.bat\" -m \"Error: 999 in file ${fqf}\" -c 1";
					@lines = qx($cmd);
					foreach $line (@lines) {
						print("$line");
					}
					$errorFound++;
				}
			}
			close(FIN);
		}
	}
}
close(SDIR);

