package Model;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use MongoDB;
use JSON;
use Data::Dumper;
use Dancer::Logger;
use LWP::UserAgent;
use HTTP::Request::Common qw{ POST };

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getTodos getCompletedTodos getArchivedTodos saveTodo archiveTodo updateTodo lookupOrRegisterUser);

sub initCollection {
  Dancer::Logger::debug ("Setting up the Database connection..\n");
  my $client = MongoDB::MongoClient->new;
  our $database = $client->get_database( 'todo' );
  our $collection = $database->get_collection( 'todos' );
};

sub getTodos {
  my ($account) = @_;
  defined(our $collection) or initCollection();
  my @todos = $collection->find({ 'email' => $account->{'email'} })->all;
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

sub updateTodo {
  my ($todo_id, $todo) = @_;
  defined(our $collection) or initCollection();
  delete $todo->{'_id'};
  $collection->update({ _id => MongoDB::OID->new($todo_id) }, $todo);
};

sub lookupOrRegisterUser {
  my ($persona_key) = @_;
  defined(our $collection) or initCollection();
  our $database;
  my $collection = $database->get_collection('users');
  my $ua = LWP::UserAgent->new();
  my $request = POST ( 'https://verifier.login.persona.org/verify',
  [ 'assertion' => $persona_key, 'audience' => 'http://localhost:3000' ]);
  my $json = JSON->new->utf8->allow_blessed->convert_blessed;
  $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
  my $ua = LWP::UserAgent->new();
  my $response = $ua->request($request);
  my $user_info = $json->decode($response->content);
  if ($user_info->{'status'} eq 'okay') {
    my $account = $collection->find_one({ email => $user_info->{'email'} });
    if (!defined($account)) {
      my $account = { email => $user_info->{'email'}, issuer => $user_info->{'issuer'} };
      $collection->save($account);
    }
    return $account;
  }
};
