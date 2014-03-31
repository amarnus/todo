package todo::Routes::User;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use todo::Models::User;
use Dancer ':syntax';

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getUser);

sub getUser {
  return session('user');
};

get '/' => sub {
  my $logged_in = false;
  my $logged_out = true;
  my $email = undef;
  my $user_from_session = session('user');
  if ($user_from_session) {
    $logged_in = true;
    $logged_out = false;
    $email = $user_from_session->{'email'};
  }
  template 'index' => { logged_in => $logged_in, logged_out => $logged_out, email => $email };
};

post '/api/persona/login' => sub {
  header 'Content-Type' => 'application/json';
  my $req = from_json(request->body);
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
