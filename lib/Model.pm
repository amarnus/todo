package Model;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use MongoDB;
use JSON;
use Data::Dumper;
use Dancer::Logger;

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getTodos getCompletedTodos getArchivedTodos saveTodo archiveTodo completeTodo);

sub initCollection {
  Dancer::Logger::debug ("Setting up the Database connection..\n");
  my $client = MongoDB::MongoClient->new;
  my $database = $client->get_database( 'todo' );
  our $collection = $database->get_collection( 'todos' );
};

sub getTodos {
  defined(our $collection) or initCollection();
  my @todos = $collection->find()->all;
  return @todos;
};

sub getCompletedTodos {
  defined(our $collection) or initCollection();
  my @todos = $collection->find({ 'status' => 1 })->all;
  return @todos;
};

sub getArchivedTodos {
  defined(our $collection) or initCollection();
  my @todos = $collection->find({ 'archived' => 1 })->all;
  return @todos;
};

sub saveTodo {
  my ($todo) = @_;
  defined(our $collection) or initCollection();
  $collection->save($todo);
};

sub archiveTodo {
  my ($oid) = @_;
  defined(our $collection) or initCollection();
  $collection->update({ _id => MongoDB::OID->new($oid)  }, { '$set' => { 'archived' => 1 } });
};

sub completeTodo {
  my ($todo) = @_;
  defined(our $collection) or initCollection();
  $collection->update($todo, { 'status' => 1 });
};
