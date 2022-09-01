#!/usr/bin/perl -w

# This file is part of Product Opener.
#
# Product Opener
# Copyright (C) 2011-2020 Association Open Food Facts
# Contact: contact@openfoodfacts.org
# Address: 21 rue des Iles, 94100 Saint-Maur des Fossés, France
#
# Product Opener is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

use Modern::Perl '2017';
use utf8;

use ProductOpener::Users qw/:all/;
use ProductOpener::Config qw/:all/;
use ProductOpener::Lang qw/:all/;
use ProductOpener::Display qw/:all/;
use ProductOpener::Store qw/:all/;
use ProductOpener::Text qw/:all/;

use Storable qw(store retrieve freeze thaw dclone);

use LWP::UserAgent;
use JSON;
use Log::Any qw($log);
use CGI qw(:standard);

#open for reading
open (my $fh, "<", "users.txt");
my $line = <$fh>;

#read line by line
while(<$fh>){
    my $ua = LWP::UserAgent->new;

    #post request to create identity
    my $post_req = HTTP::Request->new(POST => "http://kratos.openfoodfacts.localhost:4434/admin/identities");
    $post_req->header('accept' => 'application/json');
    $post_req->header('content-type' => 'application/json');
    $post_req->content($_);

    my $post_resp = $ua->request($post_req);

    if($post_resp->is_success){
        $log->debug("User Created");
        #remove line if the user was created in kratos
        chomp $line
    }
    else{
        #display error message leave user in .txt
        $log->debug("HTTP POST error code: ", $post_resp->code);
        $log->debug("HTTP POST error message: ", $post_resp->message);
    }
}

close $fh;

#users.txt will be left with all the users not imported