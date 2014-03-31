package todo::DB;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use MongoDB;
use Dancer qw(debug);

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getCollection);

sub initDatabase {
  debug ("Setting up the Database connection..");
  my $client = MongoDB::MongoClient->new;
  our $database = $client->get_database( 'todo' );
};

sub getCollection {
  my ($collname) = @_;
  defined(our $database) or initDatabase();
  return $database->get_collection( $collname );
};

1;
