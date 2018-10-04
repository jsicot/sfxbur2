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
	my $host        = $svc->parse_param('url');
        my $exception1  = $svc->parse_param('exception1');

	return $this->getCAIRNURL($ctx_obj, $jkey,$host,$exception1);
}


sub getCAIRNURL
{
	my ($this, $ctx_obj, $jkey,$host,$exception1) = @_;
	
	my %query = (); 
	my $publication_year  = $ctx_obj->get('rft.year')  || '';
	my $volume            = $ctx_obj->get('rft.volume') || '';
	my $issue             = $ctx_obj->get('rft.issue') || ''; 
	my $page              = $ctx_obj->get('rft.spage') || '';
	my $issn	      = $ctx_obj->get('rft.eissn') || '';
	my $isbn	      = $ctx_obj->get('rft.isbn_13') || '';
	my $doi               = $ctx_obj->get('rft.doi')   || '';
	my $doiurl            = $ctx_obj->get('sfx.doi_url');
	my $atitle	      = $ctx_obj->get('rft.atitle') || '';
	my $uri;
	
	$uri = URI->new($host);

	if ($atitle && $exception1 && $exception1 eq 'atitle'){
                $query{'send_search_field'}   = "Chercher";
                $query{'searchTerm'}   = "\"$atitle\"";
                $query{'searchIn'}   = "all";
                $uri = URI->new($host."resultats_recherche.php");
        }
	elsif($doi && $doiurl){
		if ($this->is_doi_allowed('CAIRN::CAIRN2',$doi)) {
			$uri = URI->new("$host/OpenUrl/sap.php?doi=$doi");
		} elsif (length($publication_year) && length($volume) && length($issue) && length($page)) {
           		 $uri = URI->new("$host/	OpenUrl/sap.php?issn=$issn&date=$publication_year&volume=$volume&issue=$issue&spage=$page");
		}
	}
	elsif(length($isbn)){
            $uri = URI->new("$host/OpenUrl/sap.php?isbn=$isbn");
	}
	elsif (length($issn) && length($publication_year) && length($volume) && length($issue) && length($page)) {
            $uri = URI->new("$host/OpenUrl/sap.php?issn=$issn&date=$publication_year&volume=$volume&issue=$issue&spage=$page");
        }
	 elsif (length($jkey) && length($publication_year) && length($issue) && length($page)) {
             $uri = URI->new("$host-$jkey-$publication_year-$issue-page-$page.htm");
	 }
	elsif (length($issn) && length($publication_year) && length($volume) && length($issue)) {
            $uri = URI->new("$host/OpenUrl/sap.php?issn=$issn&date=$publication_year&volume=$volume&issue=$issue");
        }
	elsif (length($issn) && length($publication_year) && length($volume)) {
            $uri = URI->new("$host/OpenUrl/sap.php?issn=$issn&date=$publication_year&volume=$volume");
        }
	elsif (length($issn) && length($publication_year)) {
            $uri = URI->new("$host/OpenUrl/sap.php?issn=$issn&date=$publication_year");
        }
	elsif (length($issn)) {
            $uri = URI->new("$host/OpenUrl/sap.php?issn=$issn");
        }
	
	$uri->query_form(%query);
	return $uri;
}

1;
