package Models::Todo;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use MongoDB;
use Dancer::Logger;
use LWP::UserAgent;
use HTTP::Request::Common qw{ POST };

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getTodos saveTodo updateTodo);

sub initCollection {
  Dancer::Logger::debug ("Setting up the Database connection..\n");
  my $client = MongoDB::MongoClient->new;
  my $database = $client->get_database( 'todo' );
  our $collection = $database->get_collection( 'todos' );
};

sub getTodos {
  my ($account) = @_;
  defined(our $collection) or initCollection();
  my @todos = $collection->find({ 'email' => $account->{'email'} })->all;
  return @todos;
};

sub saveTodo {
  my ($todo) = @_;
  defined(our $collection) or initCollection();
  $collection->save($todo);
};

sub updateTodo {
  my ($todo_id, $todo) = @_;
  defined(our $collection) or initCollection();
  delete $todo->{'_id'};
  $collection->update({ _id => MongoDB::OID->new($todo_id) }, $todo);
};
