package todo::Routes::Todo;

use strict;
use vars qw($VERSION);
use todo::Models::User;
use todo::Models::Todo;
use todo::Routes::User;
use Dancer ':syntax';

$VERSION  = 1.00;

get '/api/todos' => sub {
  my $account = getUser();
  my @todos = getTodos($account);
  return to_json(\@todos);
};

post '/api/todos' => sub {
  header 'Content-Type' => 'application/json';
  my $req = from_json(request->body);
  my $todo = $req->{'todo'};
  my $account = getUser();
  if (defined($account)) {
    $todo->{'email'} = $account->{'email'};
  }
  my $todo_id = saveTodo($todo);
  return to_json({ '_id' => $todo_id });
};

put '/api/todo/:todo_id' => sub {
  header 'Content-Type' => 'application/json';
  my $todo_id = params->{'todo_id'};
  my $req = from_json(request->body);
  updateTodo($todo_id, $req->{'todo'});
};
