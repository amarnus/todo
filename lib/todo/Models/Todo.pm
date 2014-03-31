package todo::Models::Todo;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use todo::DB;
use Dancer::Logger;
use LWP::UserAgent;
use HTTP::Request::Common qw{ POST };

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getTodos saveTodo updateTodo);

sub getTodos {
  my ($account) = @_;
  my $collection = getCollection('todos');
  my @todos = $collection->find({ 'email' => $account->{'email'} })->all;
  return @todos;
};

sub getTodo {
  my ($todo_id) = @_;
  my $collection = getCollection('todos');
  return $collection->find_one({ '_id' => MongoDB::OID->new($todo_id) });
}

sub saveTodo {
  my ($todo) = @_;
  my $collection = getCollection('todos');
  my $todo_id = $collection->save($todo);
  return getTodo($todo_id);
};

sub updateTodo {
  my ($todo_id, $todo) = @_;
  my $todo_id_bless = MongoDB::OID->new($todo_id);
  my $collection = getCollection('todos');
  delete $todo->{'_id'};
  $collection->update({ _id => $todo_id_bless }, $todo);
  $todo = getTodo($todo_id);
  $todo->{'_id'} = $todo_id_bless;
  return $todo;
};
