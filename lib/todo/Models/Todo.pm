package todo::Models::Todo;

use strict;
use warnings;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use todo::DB;
use todo::Cache;
use todo::Utils;
use Dancer::Logger;
use LWP::UserAgent;
use HTTP::Request::Common qw{ POST };
use Dancer;
use Data::Dumper;

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getTodos saveTodo updateTodo);

sub getUserTodosCacheKey {
  my ($account) = @_;
  my $email = $account->{'email'};
  return "$email.todos";
}

sub getTodosFromCache {
  my ($account) = @_;
  my $client = getRedisClient();
  my $cache_key = getUserTodosCacheKey($account);
  my @todos_json = $client->smembers($cache_key);
  my @todos;
  foreach my $todo_json (@todos_json) {
    push @todos => from_json($todo_json);
  }
  return @todos;
};

sub saveTodoToCache {
  my ($account, $todo) = @_;
  my @todos;
  if (ref($todo) =~ m/ARRAY/) {
    @todos = @{$todo};
  }
  else {
    push @todos => $todo;
  }
  my $client = getRedisClient();
  my $cache_key = getUserTodosCacheKey($account);
  foreach my $todo (@todos) {
    $client->sadd($cache_key, to_json($todo));
  }
};

sub getTodoFromCache {
  my ($account, $todo_id) = @_;
  my @todos = getTodosFromCache($account);
  # Linear search
  foreach my $todo (@todos) {
    if ($todo->{'_id'}->{'$oid'} eq $todo_id) {
      return $todo;
    }
  }
  return -1;
};

sub removeTodosFromCache {
  my ($account, $todo) = @_;
  my $client = getRedisClient();
  my $cache_key = getUserTodosCacheKey($account);
  return $client->del($cache_key);
}

sub getTodos {
  my ($account) = @_;
  # Look for user todos in Redis first..
  my @todos = getTodosFromCache($account);
  # If you can't find it, then fall back to the DB..
  if (count(@todos) == 0) {
    debug ('getTodos(): Cache MISS');
    my $collection = getCollection('todos');
    @todos = $collection->find({ 'email' => $account->{'email'} })->all;
    # ..but save the results to Redis at least now..
    saveTodoToCache($account, \@todos);
  }
  else {
    debug ('getTodos(): Cache HIT');
  }
  return @todos;
};

sub getTodo {
  my ($account, $todo_id) = @_;
  my $todo = getTodoFromCache($account, $todo_id);
  if ($todo == -1) {
    debug ('getTodo(): Cache MISS');
    my $collection = getCollection('todos');
    $todo = $collection->find_one({ '_id' => MongoDB::OID->new($todo_id) });
    return $todo;
  }
  else {
    debug ('getTodo(): Cache HIT');
  }
  return $todo;
}

sub saveTodo {
  my ($account, $todo) = @_;
  # Save to the database..
  my $collection = getCollection('todos');
  my $todo_id = $collection->save($todo);
  removeTodosFromCache($account, $todo);
  return getTodo($account, $todo_id);
};

sub updateTodo {
  my ($account, $todo_id, $todo) = @_;
  # Remove from cache..
  removeTodosFromCache($account, $todo);
  my $todo_id_bless = MongoDB::OID->new($todo_id);
  my $collection = getCollection('todos');
  delete $todo->{'_id'};
  $collection->update({ _id => $todo_id_bless }, $todo);
  $todo = getTodo($account, $todo_id);
  $todo->{'_id'} = $todo_id_bless;
  return $todo;
};
