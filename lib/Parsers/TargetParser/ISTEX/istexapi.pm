package Parsers::TargetParser::ISTEX::istexapi;
use base qw(Parsers::TargetParser);
use URI;

sub getURL {
	my($this, $ctx_obj) = @_;
	my $svc = $this -> {svc};

	my $doi  = $ctx_obj->get('rft.doi') || '';
	my $host = $svc->parse_param('url') || '';
	my $sid = $svc->parse_param('sid') || '';

	my $uri;
	my %query = ();

	if ($host && $doi) {
		$query{'rft_id'} = "info:doi/$doi";
		$query{'rfr_id'} = "info/sid:$sid";
	}

	$uri = URI->new($host);
	$uri->query_form(%query);

	return $uri;
}
1;
