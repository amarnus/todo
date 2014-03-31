package Models::User;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use MongoDB;
use Dancer ':syntax';
use Dancer::Logger;
use LWP::UserAgent;
use HTTP::Request::Common qw{ POST };

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(lookupOrRegisterUser);

sub initCollection() {
  Dancer::Logger::debug ("Setting up the Database connection..\n");
  my $client = MongoDB::MongoClient->new;
  my $database = $client->get_database( 'todo' );
  our $collection = $database->get_collection( 'users' );
};

sub lookupOrRegisterUser {
  $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
  my ($persona_key) = @_;
  defined(our $collection) or initCollection();
  my $ua = LWP::UserAgent->new();
  my $request = POST ( 'https://verifier.login.persona.org/verify',
    [ 'assertion' => $persona_key, 'audience' => 'http://localhost:3000' ]);
  my $response = $ua->request($request);
  my $user_info = from_json($response->content);
  if ($user_info->{'status'} eq 'okay') {
    my $account = $collection->find_one({ email => $user_info->{'email'} });
    if (!defined($account)) {
      my $account = { email => $user_info->{'email'}, issuer => $user_info->{'issuer'} };
      $collection->save($account);
    }
    return $account;
  }
};
