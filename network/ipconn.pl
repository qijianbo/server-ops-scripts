#!/usr/bin/perl
#use strict;
use Getopt::Long;

my $netstat = '/bin/netstat';
my $grep = '/bin/grep';
my $iptables = '/sbin/iptables';
my $killed_file = '/tmp/killedips';

# ansi escape
my $esc = "\033";
my $esc_reset = $esc . "[0m";
my $esc_boldon = $esc . "[1m";
my $esc_boldoff = $esc . "[22m";
my %esc_color = (
        'black' => $esc . "[30m",
        'red'   => $esc . "[31m",
        'green' => $esc . "[32m",
        'yellow'=> $esc . "[33m",
        'blue'  => $esc . "[34m",
        'purple'=> $esc . "[35m",
        'cyan'  => $esc . "[36m",
        'white' => $esc . "[37m");
my %esc_bgcolor = (
        'black' => $esc . "[40m",
        'red'   => $esc . "[41m",
        'green' => $esc . "[42m",
        'yellow'=> $esc . "[43m",
        'blue'  => $esc . "[44m",
        'purple'=> $esc . "[45m",
        'cyan'  => $esc . "[46m",
        'white' => $esc . "[47m");

my $tmp_file = '/tmp/ipconn_'.$$.time();
my ($from) = $ENV{'SSH_CLIENT'} =~ /^(\S+)/;

my $port = '80';
my $level = 9;
my $dns = 0;
GetOptions("port|p=i" => \$port,"level|l=i" => \$level,"dns|d" => \$dns);

system("$netstat -an | $grep ':$port ' > $tmp_file");

open(TMP,"$tmp_file");

# storge connection information
my $conn = {};
foreach my $line(<TMP>)
    {
    my ($proto,$recv_q,$send_q,$local,$foreign,$state) = split(/\s+/,$line);
    my ($local_address,$local_port) = split(/\:/,$local);
    next if ($local_port != $port);
    my ($remote,$foreign_port) = split(/\:/,$foreign);
    $conn->{$remote}{'ALL'}++;
    $conn->{$remote}{$state}++;
    }
close(TMP);
unlink($tmp_file);

# get killed ip
open(KILLED,"$killed_file");
my $killed = {};
foreach $line(<KILLED>)
    {
    chop($line);
    $killed->{$line} = 1;
    }
close(KILLED);

# count of large connection 
my $Large_Count = {};
# count of all connection
my $All_Count = {};

# ips of large
my @larges = ();
our $id = 0;
print "
 Show Current Foreign IP Conntion to $esc_boldon*:$port$esc_reset($esc_boldon over $level$esc_reset ),$esc_boldon dns " . (($dns)?'on':'off') . $esc_reset;
print "
 $esc_boldon$esc_color{'white'}$esc_bgcolor{'blue'} Line      Foreign Ip       All    SYN    EST    TIM    FIN $esc_reset
 $esc_color{'green'}+-----+-----------------+------+------+------+------+------+$esc_reset
";
foreach our $remote (sort {$conn->{$b}{'ALL'} <=> $conn->{$a}{'ALL'}} keys %{$conn})
    {
    # all
    $All_Count->{'all'} += $conn->{$remote}{'ALL'};
    $All_Count->{'syn'} += $conn->{$remote}{'SYN_RECV'};
    $All_Count->{'est'} += $conn->{$remote}{'ESTABLISHED'};
    $All_Count->{'tim'} += $conn->{$remote}{'TIME_WAIT'};
    $All_Count->{'fin'} += $conn->{$remote}{'FIN_WAIT1'} + $conn->{$remote}{'FIN_WAIT2'};
    # large
    if ($conn->{$remote}{'ALL'} > $level)
        {
        our $id++;
        our $tag = ($killed->{$remote})?($esc_boldon . $esc_bgcolor{'red'}):($remote eq $from)?($esc_boldon . $esc_bgcolor{'yellow'}):'';
        our $all = $conn->{$remote}{'ALL'};$Large_Count->{'all'} += $all;
        our $syn = $conn->{$remote}{'SYN_RECV'};$Large_Count->{'syn'} += $syn;
        our $est = $conn->{$remote}{'ESTABLISHED'};$Large_Count->{'est'} += $est;
        our $tim = $conn->{$remote}{'TIME_WAIT'};$Large_Count->{'tim'} += $tim;
        our $fin = $conn->{$remote}{'FIN_WAIT1'} + $conn->{$remote}{'FIN_WAIT2'};$Large_Count->{'fin'} += $fin;
        push(@larges,$remote);
        #format ip address
        my $rev = join('.',reverse(split(/\./,$remote))) . '.in-addr.arpa';
        if ($dns and my $ptr = `dig PTR $rev +short +time=1 +tries=1`)
            {
            $ptr = substr($ptr,0,-2);
            $remote = sprintf("%03d.%03d.%03d.%03d",split(/\./,$remote));
            printf(" $tag$esc_color{'green'}|$esc_reset %3d $esc_color{'green'}|$esc_reset $tag%-59s$esc_reset $esc_color{'green'}|$esc_reset\n",$id,$esc_color{'cyan'} . $ptr . $esc_reset);
            printf(" $tag$esc_color{'green'}|$esc_reset     $esc_color{'green'}|$esc_reset $tag%15s$esc_reset $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset",$remote,$all);
            printf("  " . (($syn > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset",$syn);
            printf("  " . (($est > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset",$est);
            printf("  " . (($tim > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset",$tim);
            printf("  " . (($fin > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset\n",$fin);
            printf(" $esc_color{'green'}+-----+-----------------+------+------+------+------+------+$esc_reset\n");
            }
        else 
            {
            $remote = sprintf("%03d.%03d.%03d.%03d",split(/\./,$remote));
            printf(" $esc_color{'green'}|$esc_reset %3d $esc_color{'green'}|$esc_reset $tag%15s$esc_reset $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset",$id,$remote,$all);
            printf("  " . (($syn > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset",$syn);
            printf("  " . (($est > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset",$est);
            printf("  " . (($tim > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset",$tim);
            printf("  " . (($fin > 0)?"$esc_color{'purple'}%3d$esc_reset":"%3d") . " $esc_color{'green'}|$esc_reset\n",$fin);
            printf(" $esc_color{'green'}+-----+-----------------+------+------+------+------+------+$esc_reset\n");
            }
        }
    }
printf (" $esc_color{'green'}|$esc_reset      Above Count:     $esc_color{'green'}|$esc_reset %4d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset\n",
    $Large_Count->{'all'},
    $Large_Count->{'syn'},
    $Large_Count->{'est'},
    $Large_Count->{'tim'},
    $Large_Count->{'fin'});
printf (" $esc_color{'green'}|$esc_reset      All Count:       $esc_color{'green'}|$esc_reset %4d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset  %3d $esc_color{'green'}|$esc_reset\n",
    $All_Count->{'all'},
    $All_Count->{'syn'},
    $All_Count->{'est'},
    $All_Count->{'tim'},
    $All_Count->{'fin'});
print " $esc_color{'green'}+-----+-----------------+------+------+------+------+------+$esc_reset\n";

print "\n'$esc_color{'red'}<Line>$esc_reset'    : iptable deny, '$esc_color{'red'}r$esc_reset','$esc_color{'red'}Enter$esc_reset' : refresh,'$esc_color{'red'}q$esc_reset' : quit,\n'$esc_color{'red'}p<number>$esc_reset' : set port,     '$esc_color{'red'}l<number>$esc_reset' : set level,\n'$esc_color{'red'}d$esc_reset'         : turn on/off dns resover.\n";
print "Your choice : $esc_color{'red'}";
while  (my $key = <>) 
    {
    print $esc_reset . $esc_color{'yellow'};
    if ($key =~ /^[q|Q]$/)
        {
        print "Quit$esc_reset\n";
        exit;
        }
    elsif ($key =~ /^[r|R]$/)
        {
        print "Refresh$esc_reset\n";
        exec("$0 -p $port -l $level " . (($dns)?'-d':''));
        }
    elsif ($key =~ /^[p|P](\d+)$/)
        {
        $port = $1;
        print "Set port:$port and refresh$esc_reset\n";
        exec("$0 -p $port -l $level " . (($dns)?'-d':''));
        }
    elsif ($key =~ /^[l|L](\d+)$/)
        {
        $level = $1;
        print "Set level:$level and refresh$esc_reset\n";
        exec("$0 -p $port -l $level " . (($dns)?'-d':''));
        }
    elsif ($key =~ /^[d|D]$/)
        {
        $dns = ($dns)?0:1;
        print "Set dns resolve " . (($dns)?'on':'off') . "$esc_reset\n";
        exec("$0 -p $port -l $level " . (($dns)?'-d':''));
        }
    elsif ($key =~ /^[w|W]$/)
        {
        system("uptime");
        print $esc_reset;
        }
    elsif ($key =~ /^\d+(\D?)$/)
        {
        $second_key = $1;
        if ($key <= scalar @larges && $larges[$key - 1] ne $from)
            {
            print "Deny : ".$larges[$key - 1]."\n";
            system("iptables -I INPUT 1 -i eth0 -p tcp -s ".$larges[$key - 1]." --dport ".$port." -j DROP");            
            system("iptables -I OUTPUT 1 -o eth0 -p tcp -d ".$larges[$key - 1]." --sport ".$port." -j DROP");
            open(KILLED,">>$killed_file");
            print KILLED $larges[$key - 1]."\n";
            close(KILLED);
            if ($second_key ne '')
                {
                if ($second_key =~ /^[q|Q]$/)
                    {
                    print "Quit$esc_reset\n";
                    exit;
                    }
                elsif ($second_key =~ /^[r|R]$/)
                    {
                    print "Refresh$esc_reset\n";
                    exec("$0 -p $port -l $level " . (($dns)?'-d':''));
                    }
                elsif ($key =~ /^[w|W]$/)
                    {
                    system("uptime");
                    print $esc_reset;
                    }
                }
            else 
                {
                print $esc_reset;
                }
            } 
        }
    else
        {
        print "Refresh$esc_reset\n";
        exec("$0 -p $port -l $level " . (($dns)?'-d':''));
        }
    print "Your choice : ";
    }   
