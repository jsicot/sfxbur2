package Parsers::TargetParser::ISTEX::istexapi;
use base qw(Parsers::TargetParser);
use URI;
use JSON;
use Encode;

sub getURL {
	my ($this,$ctx_obj,$CGIquery) = @_;
	my $doi = $ctx_obj->get('rft.doi') || '';
	my $istex_url = "https://api.istex.fr/document/";
	my $uri = $istex_url;

	if ($doi) {
		$q = "doi%3A%22$doi%22";
		$uri .= "?q=$q&output=doi,fulltext";
		my $ua = LWP::UserAgent->new;
		my $timeout = 5;
		$ua->timeout($timeout) if $timeout;
		my $response = $ua->get($uri);

		# print $response->status_line;
		# print $response->decoded_content;

		if ($response->is_success) {
			
# 			print "success";
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
						            }
						    }
						  last;
						}
                	};

                	if($@){
                		print "JSON parser crashed!";
	                }
		}
	}
	return $ft_url ;
}
1;
