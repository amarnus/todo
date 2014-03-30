package Routes::Todo;

use strict;
use Models::User;
use Models::Todo;
use vars qw($VERSION);
use Routes::User;
use Dancer ':syntax';

$VERSION  = 1.00;

sub getTodosRouteHandler {
  my $account = getUser();
  my @todos = getTodos($account);
  return to_json(\@todos);
};

get '/api/todos' => sub {
  getTodosRouteHandler();
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
