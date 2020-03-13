use strict;

package BrandMeister::API;

use LWP::UserAgent;
use JSON;
use MIME::Base64;
#use LWP::ConsoleLogger::Everywhere ();

=head1 NAME

BM::API - Use the BM API from Perl

=head1 SYNOPSIS

Implementation of the BM API in Perl.

=head1 AUTHOR

Simon (G7RZU) <simon@gb7fr.org.uk>

=cut

use vars qw($VERSION);
#Define version
$VERSION = '0.1';

=head1 METHODS

=cut

sub new {
	my($class) = shift;
	my($self) = shift;
	if (!exists($self->{BM_APIKEY}) || !exists($self->{DMRID})) {
        return(0);
	}
	$self->{BM_APIBASEURL} = "https://api.brandmeister.network/v1.0/repeater/";
	$self->{BM_APIKEYBASE64} = encode_base64($self->{BM_APIKEY});
	bless($self,$class);
	return($self);
};

sub _build_request {
    my($self) = shift;
    #my($json) = shift;
    my($requrlpart) = shift;
    my($uri) = $self->{BM_APIBASEURL}.$requrlpart;
    print("Building HTTP request\n") if($self->{DEBUG});
    my($req) = HTTP::Request->new(
                GET => $uri
	             );
    $req->header(   'Content-Type' => 'application/x-www-form-urlencoded',
                    'Authorization'=>'Basic ' . $self->{BM_APIKEYBASE64}
            );
	
#$req->content( $json );
    return($req);
    
};

sub _send_request {
    my($self) = shift;
    my($req) = shift;
    return(1) if (!$req);
    my($ua) = LWP::UserAgent->new;
    my($jsonresobj) = JSON->new;
    my($res) = $ua->request($req);
    print('Request status line: '.$res->status_line."\n") if($self->{DEBUG}) ;
    if (!$res->is_success) {
        return($res->status_line);
    };
    $self->{_JSONRESPONSEREF} = $jsonresobj->decode($res->decoded_content);
    return(0);
};
    

=head2 json_response

    Returns a hash ref to the last JSON response or undef if there is none
    
    $jsonhashref = $jsonobj->json_response;

=cut

sub json_response {
    my($self) = shift;
    print("Return JSON response\n") if($self->{DEBUG});
    return($self->{_JSONRESPONSEREF});
};

=head2 add_static_tg
    
    Add static TG to repeater config. 

=cut

sub _do_action {
    my($self) = shift;
    my($requrlpart) = shift;
    my($req) = $self->_build_request->($requrlpart);
    my($res) = $self->_send_request($req);
    return($res);
  
};

sub _action {
    my($self) = shift;
    my($action) = shift;
    my($reqaction);
    my($ts,$tg) = @_;
    if ($action = 'delstatic') {
        $reqaction = 'talkgroup/?action=DEL&id='.$self->{DMRID}.'&talkgroup='.$tg.'&timeslot='.$ts;
    } elsif ($action = 'addstatic') {
        $reqaction = 'talkgroup/?action=ADD&id='.$self->{DMRID}.'&talkgroup='.$tg.'&timeslot='.$ts;
    } elsif ($action = 'dropdynamic') {
        $reqaction = 'setRepeaterTarantool.php?action=dropDynamicGroups&slot='.$ts.'&q='.$self->{DMRID};
    } else {
        return(1);
    };
    
    return($self->_do_action($reqaction));

};

sub add_static_tg {
    my($self) = shift;
    my($ts,$tg) = shift;
    return(1) if (($ts < 1 || $ts > 2) || !$tg || $tg == 9 || $tg == 8 || $tg == 6);
    return($self->_action('addstatic'));
};

sub del_static_tg {
    my($self) = shift;
    my($ts,$tg) = shift;
    return(1) if (($ts < 1 || $ts > 2) || !$tg || $tg == 9 || $tg == 8 || $tg == 6);
    return($self->_action('delstatic'));
};

sub dropdynamic {
    my($self) = shift;
    return($self->_action('dropdynamic'));
};

1;
