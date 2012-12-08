package Supers::Search::Category;
use Elastic::Doc;

has 'name' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub { shift->path->[-1] },
    index   => 'not_analyzed',
    multi   => { suggest => { analyzer => 'supers_suggest' } }
);

has 'slug' => (
    is    => 'rw',
    isa   => 'Str',
    index   => 'not_analyzed'
);

has 'path' => (
    is  => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub {[]},
    analyzer => 'supers_spanish',
);

no Elastic::Doc;

1;

__END__
=pod

=head1 NAME

Supers::Search::Category

=head1 VERSION

version 1.123430

=head1 AUTHOR

Diego Kuperman <diego@freekeylabs.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Diego Kuperman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

