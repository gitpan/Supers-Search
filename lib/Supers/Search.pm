package Supers::Search;
use Elastic::Model;
# ABSTRACT: Search model for soysuper

has_namespace 'soysuper' => {
    product  => 'Supers::Search::Product',
    category => 'Supers::Search::Category'
};

has_filter 'snowball_spanish' => (
    type      => 'snowball',
    language  => 'Spanish',
);

has_filter 'phonetic_sound' => (
    type     => 'phonetic',
    encoder  => 'refinedsoundex',
    replace  => 'true'
);

has_filter supers_edge_ngram => (
    type     => 'edge_ngram',
    min_gram => 1,
    max_gram => 20,
    side     => 'front',
);

has_filter supers_slug => (
    type     => 'pattern_replace',
    pattern     => '\s+',
    replacement => '-'
);

has_filter spanish_stop => (
    type        => 'stop',
    ignore_case => 'true',
    stopwords   => [qw/ de la los el las /]
);

has_analyzer 'supers_clean' => (
    type      => 'custom',
    tokenizer => 'standard',
    filter    => [qw/ standard lowercase asciifolding /]
);

has_analyzer 'supers_spanish' => (
    type      => 'custom',
    tokenizer => 'lowercase',
    filter    => [qw/ asciifolding snowball_spanish /]
);

has_analyzer 'sound_like' => (
    type      => 'custom',
    tokenizer => 'lowercase',
    filter    => [qw/ asciifolding phonetic_sound /]
);

has_analyzer 'path_analyzer' => (
    type      => 'custom',
    tokenizer => 'path_hierarchy',
);

has_analyzer supers_suggest => (
    type      => 'custom',
    tokenizer => 'standard',
    filter    => [ 'standard', 'lowercase', 'asciifolding', 'supers_edge_ngram' ] 
);

has_analyzer 'lower_keyword' => (
    type      => 'custom',
    tokenizer => 'keyword',
    filter    => [qw/ asciifolding lowercase trim supers_slug /]
);

has_analyzer 'unique_clean' => (
    type      => 'custom',
    tokenizer => 'standard',
    filter    => [qw/ standard lowercase asciifolding unique /]
);

has_analyzer 'unique_spanish' => (
    type      => 'custom',
    tokenizer => 'lowercase',
    filter    => [qw/ asciifolding snowball_spanish unique /]
);

has_analyzer 'unique_sound_like' => (
    type      => 'custom',
    tokenizer => 'lowercase',
    filter    => [qw/ asciifolding phonetic_sound unique /]
);

no Elastic::Model;

1;

__END__
=pod

=head1 NAME

Supers::Search - Search model for soysuper

=head1 VERSION

version 1.123430

=head1 AUTHOR

Diego Kuperman <diego@freekeylabs.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Diego Kuperman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

