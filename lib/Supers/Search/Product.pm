package Supers::Search::Product;
use Elastic::Doc;
use Supers::Image::Identity;
use MooseX::Types::Structured qw(Dict Optional);
use MooseX::Types::Moose qw(Int Str Object ArrayRef Num HashRef Maybe);

has 'name' => (
    is    => 'rw',
    isa   => Str,
    analyzer => 'supers_clean',
    multi => {
        stem  => { analyzer => 'supers_spanish' },
        sound => { analyzer => 'sound_like' },
        suggest => { analyzer => 'supers_suggest' }
    },
    trigger => \&clear_name_length
);

has 'slug' => (
    is    => 'rw',
    isa   => Str,
    index => 'not_analyzed',
);

has 'name_length' =>(
    isa      => Int,
    init_arg => undef,
    lazy     => 1,
    default  => sub {length(shift->name)},
    clearer  => 'clear_name_length'
);

has 'brand' => (
    is    => 'rw',
    isa   => 'Maybe[Str]',
    index => 'not_analyzed',
    multi    => { clean => { analyzer => 'lower_keyword' } }
);

has 'brands' => (
    is  => 'rw',
    isa      => 'ArrayRef[Str]',
    default  => sub {[]},
    analyzer => 'unique_clean',
    multi    => {
        stem    => { analyzer => 'unique_spanish' },
        sound   => { analyzer => 'unique_sound_like' },
        suggest => { analyzer => 'supers_suggest' },
    }
);

has variant => (
    is       => 'rw',
    isa      => Str,
    analyzer => 'supers_clean',
    multi => {
        stem    => { analyzer => 'supers_spanish' },
        suggest => { analyzer => 'supers_suggest' },
    }
);

has 'v' => (
    is      => 'rw',
    isa     => HashRef,
    default => sub {{}}
);

has 'price' => (
    is      => 'rw',
    isa     => HashRef,
    default => sub {{}},
);

has 'mean_price' => (
    is      => 'rw',
    isa     => Dict[
        mean        => Optional[Num],
        carrefour   => Optional[Num],
        alcampo     => Optional[Num],
        eroski      => Optional[Num],
        corteingles => Optional[Num],
        condis      => Optional[Num],
        mercadona   => Optional[Num]
    ],
    default => sub {{}},
);

has 'image_key' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
    index => 'no'
);

has 'tags' => (
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    multi    => {
        untouched => { index    => 'not_analyzed' },
        clean     => { analyzer => 'lower_keyword' },
        sound     => { analyzer => 'sound_like' },
        suggest   => { analyzer => 'supers_suggest' }
    },
    analyzer => 'supers_spanish',
);

has 'attrs' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub {[]},
    index   => 'not_analyzed'
);

has 'keywords' => (
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    default  => sub {[]},
    analyzer => 'supers_spanish',
    multi    => { sound => { analyzer => 'sound_like' } },
);

has 'supermarket' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub {[]},
    index   => 'not_analyzed'
);

has 'warehouse' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub {[]},
    index   => 'not_analyzed'
);

has 'status' => (
    is      => 'rw',
    isa     => 'Str',
    index   => 'not_analyzed',
    default => 'unavail'
);

has category => (
    is       => 'rw',
    isa      => 'ArrayRef[Str]',
    default  => sub {[]},
    analyzer => 'supers_spanish',
    multi    => {
        untouched => { index => 'not_analyzed' },
        suggest   => { analyzer => 'supers_suggest' }
    }
);

has category_path => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub {[]},
    analyzer=> 'path_analyzer',
    multi    => { untouched => { index => 'not_analyzed' } }
);

has category_name => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
    default => sub {[]},
    analyzer => 'supers_clean',
    multi    => { 
        untouched => { index => 'not_analyzed' },
        suggest   => { analyzer => 'supers_suggest' }
    }
);

sub _id { shift->uid->id };

#TODO: make this works as predicate of image_key
sub has_image { shift->image_key }

sub image_url {
    my $self = shift;

    return unless $self->has_image;

    my $host = $self->image_key;
    $host =~ s/\D//g;
    $host = $host % 3;
    "http://a$host.soysuper.com/" . $self->thumb_filename(@_);
}

sub thumb_filename {
    my $self = shift;

    my $img = Supers::Image::Identity->new(
        id        => $self->image_key,
        params    => {@_},
        extension => 'png'
    );

    $img->to_string;
}

sub get_price {
    my ( $self, $opt )  = @_;
    $opt ||= {}; # good point to inject localized data

    return [0] unless $self->status eq 'avail';

    if ( my $super = $opt->{supermarket} ) {

        if ( my $wh = $opt->{warehouse} ) {
            return $self->price->{$super}{$wh};
        }

        return [$self->price->{$super}{_mean}];
    }

    return [$self->price->{_mean}];
}

no Elastic::Doc;

1;

__END__
=pod

=head1 NAME

Supers::Search::Product

=head1 VERSION

version 1.123430

=head1 METHODS

=head2 image_url
Return the absolute URL for this image.
Accept same options as thumb_filename.

=head2 thumb_filename
Return a Supers::Image::Identity string representation of this image for public usage.
You can pass a hashref of params as stated on Supers::Image::Identity docs.

=head2 get_price
Get price for a given warehouse and/or supermarket, or mean if none are provided.
Return an array of one or two elements. First is price, second is offer if exists.

=head1 AUTHOR

Diego Kuperman <diego@freekeylabs.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Diego Kuperman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

