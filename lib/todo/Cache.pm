package todo::Cache;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT);
use Redis;
use Dancer qw(debug);

$VERSION  = 1.00;
@ISA      = qw(Exporter);
@EXPORT   = qw(getRedisClient);

sub initClient {
  debug ('Setting up the Redis connection..');
  our $redisClient = Redis->new;
};

sub getRedisClient {
  defined(our $redisClient) or initClient();
  return $redisClient;
};

1;
