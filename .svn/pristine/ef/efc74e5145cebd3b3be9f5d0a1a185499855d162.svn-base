#!/usr/bin/perl

# written by Dan Povey.

use Sys::Hostname;
use Sys::Syslog;

$warn = 0;

# We'll start killing processes if 
# (the  proportion of swap used is >= $swap_proportion AND the total proportion
#  of memory used is >= $mem_proportion).

$swap_proportion = 0.2;
$mem_proportion = 0.97;
$user_proportion = 0.8; # Only start killing user processes if the total
                        # of user-level memory use is at least this fraction
                        # of the total memory.  This prevents things being 
                        # killed because nfsd was using up too much memory.

# Don't kill processes of userids less than this.
$min_uid = 200; 

for ($x = 1; $x <= 4; $x++) {
    if (@ARGV > 0 && $ARGV[0] eq "-w") {
	$warn = 1;
	shift @ARGV;
    }
    if (@ARGV > 0 && $ARGV[0] eq "-n") {
	shift @ARGV;
	if (@ARGV  == 0) {  die "-n option requires an argument."; }
	$notify_email = shift @ARGV;
    }
}

openlog("mem-killer.pl", "nofatal", "local0");

if (@ARGV != 0) {
    die "Usage: mem-killer.pl [-w] [-n foo\@bar]\n" .
	"-n means: notify by email when processes are killed\n" .
	"-w means: print any warnings on its operation to STDERR (only for debug)\n";
}

chdir("/proc") || die "Can't chdir to /proc";

# This will return the total memory used by the process.
sub get_memory_for_process {
    my $pid = shift @_;
    defined $pid || die;
    my $f = "$pid/smaps";
    my $size = 0; # in kB.
    if (open(F, "<$f")) {
	while(<F>) {
	    if (m/^Rss:\s+(\d+) kB$/) {
		$size += $1;
	    }
	}
    } else {
	if ($warn) {
	    print STDERR "$0: Could not open file $f\n";
	}
    }
    return $size;
}

sub get_user_for_process {
    my $pid = shift @_;
    defined $pid || die;
    my $f = "$pid/status";
    if (open(F, "<$f")) {
	while(<F>) {
	    if (m/^Uid:\s+(\d+)\s*/) { # Get first field of Uid line,
		# which is "real UID".
		return $1;
	    }
	}
    }
    if ($warn) {
	print STDERR "$0: Could not get UID for process $pid\n";
    }
    return -1;
}

sub get_name_for_process {
    my $pid = shift @_;
    defined $pid || die;
    my $f = "$pid/status";
    if (open(F, "<$f")) {
	while(<F>) {
	    if (m/^Name:\s+(.+)/) { 
		return $1;
	    }
	}
    }
    if ($warn) {
	print STDERR "$0: Could not get name for process $pid\n";
    }
    return "[unknown name]";
}


sub find_process_to_kill {
    # We find the largest process of the user with uid >200 who is using
    # the most memory.
    # returns (PID, process-name, owner-name, owner-email, owner-tot-mem, users-tot-mem, process-mem)
    # [note: users-tot-mem is the total size of all processes of users greater than the min-uid.]

    my %user_tot; # indexed by userid: total mem.
    my %user_max; # indexed by userid: mem of biggest process.
    my %user_proc; # indexed by userid: PID of biggest process.
    
    my $users_tot_mem = 0;
    foreach $pid (<*>) { # We're in directory /proc
	if ($pid !~ m/^\d+$/) { next; } # ignore non-numeric files in /proc/
        # type "man 5 proc" to see format of the smaps file.
	my $size = get_memory_for_process($pid);
	my $uid = get_user_for_process($pid);
	if ($uid >= $min_uid) {
	    $users_tot_mem += $size;
	    if (!defined $user_tot{$uid}) {
		$user_tot{$uid} = $size;
		$user_max{$uid} = $size;
		$user_proc{$uid} = $pid;
	    } else {
		$user_tot{$uid} += $size;
		if ($size > $user_max{$uid}) {
		    $user_max{$uid} = $size;
		    $user_proc{$uid} = $pid;
		}
	    }
	}
    }
    my $tot_mem = -1;
    my $max_mem = -1;
    my $worst_user = -1;
    my $kill_process = -1;
    foreach $user (keys %user_tot) {
	if ($user_tot{$user} > $tot_mem) {
	    $tot_mem = $user_tot{$user};
	    $max_mem = $user_max{$user};
	    $worst_user = $user;
	    $kill_process = $user_proc{$user};
	}
    }

    # Convert $worst_user to username.
    my $worst_user_name = $worst_user; # default if conversion fails.
    my $worst_user_email = "";
    if ($worst_user > 0) {
	my @A = getpwuid($worst_user);
	if (@A > 0) {
	    $worst_user_name = $A[0]; # username.
	    my $gecos = $A[6];
	    if ($gecos =~ m/([-a-zA-Z_0-9-\.]+@[-a-zA-Z0-9\.]+)/) {
		$worst_user_email = $1;
	    }
	} else {
	    if ($warn) {
		print STDERR "Could not convert userid $worst_user to username.\n";
	    }
	}
    }
    my $process_name = get_name_for_process($kill_process);
    
    if ($users_tot_mem > $user_proportion *  $mem_total) {
       return ($kill_process, $process_name, $worst_user_name, $worst_user_email, $tot_mem, $users_tot_mem, $max_mem);
    }
}

sub kill_something {
    # First find a process to kill.
    my ($pid, $process_name, $username, $useremail, $tot_mem, $users_tot_mem, $max_mem) = find_process_to_kill();
    if ($pid > 0) {
	$message = "Killing process: PID $pid, name $process_name, username $username, user-email $useremail, total user memory $tot_mem (all non-system users $users_tot_mem), memory for the process $max_mem\n";
	if ($warn) {
	    print STDERR $message;
	} 
	syslog("info|local0", $message);

	# Kill it.
	kill (9, $pid);
	if (defined $notify_email) {
	    $host = hostname();
	    if (open(F, "|notify -s 'mem_killer.pl triggered on $host' $notify_email $useremail")) {
		print F "Killed process $process_name (PID: $pid) of user $username\n";
		print F "User was using total $tot_mem kB, the process we killed was using $max_mem\n";
		print F "Output of top (after killing it) follows.\n";
		open(G, "top -n 1 -b|");
		my $n = 0;
		my $max = 50;
		while(<G>) {
		    if ($_ !~ m/^\s*$/ && $n < $max) {
			print F $_;
			$n++;
		    }
		}
		close(G);
		if ((!close(F) || $? != 0) && $warn) {
		    print STDERR "$0: error closing pipe to send notification e-mail.\n";
		}
	    } else {
		print STDERR "$0: failed to open pipe to send notification email.\n";
	    }
	}
    } else {
	if ($warn) {
	    print STDERR "$0: Excessive memory use detected but could not find suitable process to kill.\n";
	}
    }
}

while(1) {
    sleep(1.0); # Every second...
    if (open(M, "</proc/meminfo")) {
        $swap_total = -1;
	$swap_free = -1;
        $mem_total = -1; # This needs to remain a global variable.
	$mem_free = -1;
	while(<M>) {
	    m/SwapTotal:\s*(\d+) kB/ && ($swap_total = $1);
	    m/SwapFree:\s*(\d+) kB/ && ($swap_free = $1);
	    m/MemTotal:\s*(\d+) kB/ && ($mem_total = $1);
	    m/MemFree:\s*(\d+) kB/ && ($mem_free = $1);
	}
	close(M);
	if ($swap_total >= 0 && $swap_free >= 0 &&
	    $mem_total >= 0.0 && $mem_free >= 0.0) {
	    if ($swap_free < (1.0 - $swap_proportion) * $swap_total &&
		$mem_free < (1.0 - $mem_proportion) * $mem_total) {
		# Caution: kill_something() will only kill something if 
		# more than "$user_proportion" of the memory was being used
		# by non-system users.
		kill_something(); 
	    }
	} else {
	    if ($warn) {
		print STDERR "$0: Could not find the variables we wanted from /proc/meminfo.\n";
	    }
	}
    } else {
	if ($warn) {
	    print STDERR "$0: Could not open /proc/meminfo.";
	}
    }
}
