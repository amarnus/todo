package todo;
use Dancer ':syntax';
use Model;
use Data::Dumper;
use Template;

our $VERSION = '0.1';

sub initJson {
  our $json = JSON->new->utf8->allow_nonref->allow_blessed->convert_blessed;
};

sub getUser {
  return session('user');
};

sub getTodosRouteHandler {
  my $account = getUser();
  my @todos = getTodos($account);
  my $json = JSON->new->utf8->allow_nonref->allow_blessed->convert_blessed;
  return $json->encode(\@todos);
};

get '/' => sub {
  my $logged_in = false;
  my $logged_out = true;
  if (session('user')) {
    $logged_in = true; $logged_out = false;
  }
  template 'index' =>
    { 'logged_in' => $logged_in, 'logged_out' => $logged_out  };
};

post '/api/persona/login' => sub {
  header 'Content-Type' => 'application/json';
  defined(our $json) or initJson();
  my $req = $json->decode(request->body);
  my $persona_key = $req->{'persona_key'};
  my $account = lookupOrRegisterUser($persona_key);
  if (!defined($account)) {
    status 401;
  }
  session 'user' => $account;
  status 200;
};

get '/user/logout' => sub {
  session->destroy;
  redirect '/';
};

get '/api/todos' => sub {
  getTodosRouteHandler();
};

get '/api/todos/all' => sub {
  getTodosRouteHandler();
};

get '/api/todos/completed' => sub {
  my @todos = getCompletedTodos();
  defined(our $json) or initJson();
  return $json->encode(\@todos);
};

get '/api/todos/archived' => sub {
  my @todos = getArchivedTodos();
  defined(our $json) or initJson();
  return $json->encode(\@todos);
};

post '/api/todos' => sub {
  header 'Content-Type' => 'application/json';
  defined(our $json) or initJson();
  my $req = $json->decode(request->body);
  my $todo = $req->{'todo'};
  my $account = getUser();
  if (defined($account)) {
    $todo->{'email'} = $account->{'email'};
  }
  my $todo_id = saveTodo($todo);
  return $json->encode({'todo_id' => $todo_id});
};

post '/api/todos/archive' => sub {
  header 'Content-Type' => 'application/json';
  defined(our $json) or initJson();
  my $req = $json->decode(request->body);
  archiveTodo($req->{'todo'}->{'oid'});
};

put '/api/todo/:todo_id' => sub {
  header 'Content-Type' => 'application/json';
  defined(our $json) or initJson();
  my $todo_id = params->{'todo_id'};
  my $req = $json->decode(request->body);
  updateTodo($todo_id, $req->{'todo'});
};

true;
