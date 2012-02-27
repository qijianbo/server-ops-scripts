#!/usr/bin/perl

#2011.11.10
#editor:mayiwei

use Net::SMTP;
use Net::SMTP::SSL;
use Net::SMTP::TLS;

my $mailhost = "smtp.gmail.com";
my $mailfrom = 'xxx@gmail.com';
my $mailto = ('xxx@xxx.com');
my $subject = "214-backup-stats";
my $text = `du -sh /data/backup/*`;

#$smtp = Net::SMTP->new($mailhost, Hello => 'localhost', Timeout => 120, Debug => 1);
$smtp = new Net::SMTP::TLS(
$mailhost,
Hello => 'localhost',
Port => 587,
User => 'xxx@gmail.com',
Password => 'xxx');
#$smtp->auth('xxx@126.com','xxx');
$smtp->mail($mailfrom);
$smtp->to($mailto);
$smtp->data();
$smtp->datasend("To: $mailto\n");
$smtp->datasend("From: $mailfrom\n");
$smtp->datasend("Subject: $subject\n");
$smtp->datasend("\n");
$smtp->datasend("$text\n\n");
$smtp->dataend();
$smtp->quit;
