package todo::Utils;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(count);

sub count {
  my (@list) = @_;
  my $count = @list;
};
