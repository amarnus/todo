package todo;
use Dancer ':syntax';
use Model;
use Data::Dumper;

our $VERSION = '0.1';

sub initJson {
  our $json = JSON->new->utf8->allow_nonref->allow_blessed->convert_blessed;
};

sub getTodosRouteHandler {
  my @todos = getTodos();
  my $json = JSON->new->utf8->allow_nonref->allow_blessed->convert_blessed;
  return $json->encode(\@todos);
};

get '/' => sub {
    template 'index';
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
  my $todo_id = saveTodo($req->{'todo'});
  return $json->encode({'todo_id' => $todo_id});
};

post '/api/todos/archive' => sub {
  header 'Content-Type' => 'application/json';
  defined(our $json) or initJson();
  my $req = $json->decode(request->body);
  archiveTodo($req->{'todo'}->{'oid'});
};

post '/api/todos/complete' => sub {
  header 'Content-Type' => 'application/json';
  defined(our $json) or initJson();
  my $req = $json->decode(request->body);
  completeTodo($req->{'todo'});
};

true;
