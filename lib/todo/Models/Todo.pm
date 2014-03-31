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

sub saveTodo {
  my ($todo) = @_;
  my $collection = getCollection('todos');
  $collection->save($todo);
};

sub updateTodo {
  my ($todo_id, $todo) = @_;
  my $collection = getCollection('todos');
  delete $todo->{'_id'};
  $collection->update({ _id => MongoDB::OID->new($todo_id) }, $todo);
};
