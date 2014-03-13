#!perl

use 5.010001;
use strict;
use warnings;

use Test::More 0.98;
use Test::Perinci::Sub::Wrapper qw(test_wrap);

{
    my $n = 0;
    my $sub  = sub { ++$n };
    my $meta = {v=>1.1};

    test_wrap(
        name => 'no args',
        pre_test => sub { $n = 0 },
        wrap_args => {sub => $sub, meta => $meta, convert=>{memoize=>1}},
        wrap_status => 200,
        calls => [
            {argsr=>[], actual_res=>1},
            {argsr=>[], actual_res=>1},
        ],
    );

    test_wrap(
        name => 'another function',
        pre_test => sub { $n = 2 },
        wrap_args => {sub => $sub, meta => $meta, convert=>{memoize=>1}},
        wrap_status => 200,
        calls => [
            {argsr=>[], actual_res=>3},
            {argsr=>[], actual_res=>3},
        ],
    );
}

{
    my $na = 0;
    my $nb = 10;
    my $sub  = sub {
        my %args = @_;
        if ($args{a}) { ++$na } elsif ($args{b}) { ++$nb } else { 0 }
    };
    my $meta = {v=>1.1, args=>{a=>{}, b=>{}}};

    test_wrap(
        name => 'with args',
        pre_test => sub { $na = 0; $nb = 0 },
        wrap_args => {sub => $sub, meta => $meta, convert=>{memoize=>1}},
        wrap_status => 200,
        calls => [
            {argsr=>[]    , actual_res=>0},

            {argsr=>[a=>1], actual_res=>1},
            {argsr=>[a=>1], actual_res=>1},
            {argsr=>[b=>1], actual_res=>11},
            {argsr=>[b=>1], actual_res=>11},

            {argsr=>[a=>2], actual_res=>2},
            {argsr=>[a=>2], actual_res=>2},
            {argsr=>[b=>2], actual_res=>12},
            {argsr=>[b=>2], actual_res=>12},

            {argsr=>[a=>1, b=>0], actual_res=>3},
            {argsr=>[a=>1, b=>0], actual_res=>3},
            {argsr=>[b=>1, a=>0], actual_res=>13},
            {argsr=>[b=>1, a=>0], actual_res=>13},
        ],
    );
}

DONE_TESTING:
done_testing;
