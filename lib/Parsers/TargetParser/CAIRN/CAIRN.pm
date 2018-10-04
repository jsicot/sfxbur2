# Version: $Id: CAIRN.pm,v 1.9 2017/10/15 19:30:34 eldada Exp $
package Parsers::TargetParser::CAIRN::CAIRN;
use base qw(Parsers::TargetParser);
use URI; 
use strict;
use warnings;

sub getFullTxt
{
	my ($this)      = @_;
	my $ctx_obj     = $this->{ctx_obj};
	my $svc         = $this->{svc};
	my $jkey        = $svc->parse_param('jkey');
	my $host1       = $svc->parse_param('url');
	my $host2       = "http://www.cairn.info/revue";
        my $exception1       = $svc->parse_param('exception1');

	return $this->getCAIRNURL($ctx_obj, $jkey,$host1,$host2,$exception1);
}


sub getCAIRNURL
{
	my ($this, $ctx_obj, $jkey,$host1,$host2,$exception1) = @_;
	
	my %query = (); 
	my $publication_year  = $ctx_obj->get('rft.year')  || '';
	my $issue             = $ctx_obj->get('rft.issue') || ''; 
	my $page              = $ctx_obj->get('rft.spage') || '';
	my $doi               = $ctx_obj->get('rft.doi')   || '';
	my $doiurl            = $ctx_obj->get('sfx.doi_url');
	my $atitle = $ctx_obj->get('rft.atitle') || '';
	my $uri;
	
	$uri = URI->new($host1);

	if ($atitle && $exception1 && $exception1 eq 'atitle'){
                $query{'send_search_field'}   = "Chercher";
                $query{'searchTerm'}   = "\"$atitle\"";
                $query{'searchIn'}   = "all";
                $uri = URI->new($host1."resultats_recherche.php");
        }
	elsif($doi && $doiurl){
		if ($this->is_doi_allowed('CAIRN::CAIRN',$doi)) {
			$uri = URI->new("http://www.cairn.info/OpenUrl/sap.php?doi=$doi");
		} elsif (length($jkey) && length($publication_year) && length($issue) && length($page)) {
			$uri = URI->new("$host2-$jkey-$publication_year-$issue-page-$page.htm");
		}
	}
	elsif (length($jkey) && length($publication_year) && length($issue) && length($page)) {
            $uri = URI->new("$host2-$jkey-$publication_year-$issue-page-$page.htm");
        }
	elsif (length($jkey) && length($publication_year) && length($issue)) {
            $uri = URI->new("$host2-$jkey-$publication_year-$issue.htm");
        }
	elsif (length($jkey)) {
            $uri = URI->new("$host2-$jkey.htm");
        }
	
	$uri->query_form(%query);
	return $uri;
}

1;
