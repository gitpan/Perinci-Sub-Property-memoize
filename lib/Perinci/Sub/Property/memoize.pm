package Perinci::Sub::Property::memoize;

use 5.010001;
use strict;
use warnings;

use Perinci::Sub::PropertyUtil qw(declare_property);

our $VERSION = '0.01'; # VERSION

declare_property(
    name => 'memoize',
    type => 'function',
    schema => ['any' => {default=>0, of=>[
        ['bool*'],
        ['hash*' => {keys=>{
        }}],
    ]}],
    wrapper => {
        meta => {
            v       => 2,
            # high, we want to return memoized result early right after we get
            # %args
            prio    => 0,
            convert => 1,
        },
        handler => sub {
            my ($self, %args) = @_;

            my $v    = $args{new} // $args{value};
            return unless $v;

            $self->select_section('declare_vars');
            $self->_add_var('_w_cache_key');
            my @fargs_names = sort keys %{ $self->{_meta}{args} // {} };
            my $qsub_name = Perinci::Sub::Wrapper::__squote($self->{_args}{sub_name});
            $self->push_lines(
                '{',
                '    no warnings;',
                '    $_w_cache_key = join("\0", map {$args{$_}} ('.
                    join(",",map {Perinci::Sub::Wrapper::__squote($_)}
                             @fargs_names).'));',
                '    return $Perinci::Sub::Wrapped::memoize_cache{'.$qsub_name.'}{$_w_cache_key} '.
                    'if exists $Perinci::Sub::Wrapped::memoize_cache{'.$qsub_name.'}{$_w_cache_key};',
                '}',
            );

            $self->select_section('after_call_after_res_validation');
            $self->push_lines(
                '$Perinci::Sub::Wrapped::memoize_cache{'.$qsub_name.'}{$_w_cache_key} = $_w_res;',
            );
        },
    },
);

1;
# ABSTRACT: Memoize function

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::Sub::Property::memoize - Memoize function

=head1 VERSION

version 0.01

=head1 SYNOPSIS

 # in function metadata
 memoize => 1,

=head1 DESCRIPTION

This property implements a simple memoize. There are currently no options yet.

See L<Memoize> for more information and caveats about memoizing.

=head1 SEE ALSO

L<Perinci>

L<Memoize>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Perinci-Sub-Property-memoize>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Perinci-Sub-Property-memoize>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Perinci-Sub-Property-memoize>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
