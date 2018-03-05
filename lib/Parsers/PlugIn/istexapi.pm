# oaDOI PlugIn: Checks the oaDOI API for an OA version of a DOI provided
# 09.11.2017: changed to v2 endpoint of API
# ------------------------------------------------------------------
package Parsers::PlugIn::istexapi;
use base qw(Parsers::PlugIn);
use SFXMenu::Debug qw(debug error);
use LWP::UserAgent;
use URI;
use JSON;
use Encode;

sub lookup {
	my ($self, $ctx_obj) = @_;

	# read from context object and initiate variables
	my $doi        = $ctx_obj->get('rft.doi') || '';
	my $ret        = 0; # return value
	my $url        = '';
	my $timeout    = '';

	# read from config
	my $config_file = "istex.config";
	eval {$config_parser = new Manager::Config(file=>$config_file)};
	if ($@) {
		debug "initiating config manager fails";
		return $ret;
	}
	else {
		$url        = $config_parser->getSection('api','url');
		$timeout    = $config_parser->getSection('api','timeout');
	}

	if ($url && $doi) {
		$q = "doi%3A%22$doi%22";
		$url .= "?q=$q&output=doi,fulltext";
	} else {
		debug "missing url or doi, check the configuration";
		return $ret;
	}

	# start timer
	my $t = Benchmark::Timer->new();
	$t->start;

	# create HTTP request and check JSON response
	$uri = URI->new($url);
	my $ua = LWP::UserAgent->new;
	$ua->timeout($timeout) if $timeout;
	debug $uri->as_string;
	my $response = $ua->get($uri);

	if ($response->is_success) {
		debug $response->content; 
		eval { 
						my $content = Encode::decode("utf8", $response->content);
						my $json = from_json( $content );
						my $r;
						my @results = ref $json->{hits} eq "ARRAY"
						            ? @{ $json->{hits}}
						: ($json->{hits});						
						for my $result (@results) {
						    my $istex_id = $result->{'id'};
						    my $fulltext_node = $result->{'fulltext'};
						    my @fulltexts =
						      ref $fulltext_node eq "ARRAY"
						      ? @$fulltext_node
						      : ($fulltext_node);
						    for my $fulltext (@fulltexts) {
						            if( $fulltext->{extension} eq "pdf") {
							           $ft_url = $fulltext->{uri} ;
							           $ret = 1;
						            }
						    }
						  last;
						}
		};
		if($@){
			debug "JSON parser crashed!";
		}
	}
	else {
		debug $response->status_line;
	}

	# stop timer and return
	$t->stop;
	debug "Process took: " . $t->results()->[1];
	$t->reset;
	return $ret;
}
1;
