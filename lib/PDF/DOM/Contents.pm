use v6;

use PDF::DOM::Contents::Stream;
use PDF::DOM::Type::XObject;

#| this role is applied to PDF::DOM::Type::Pages and PDF::DOM::Type::XObject::Form
role PDF::DOM::Contents {

    method Contents is rw { self<Contents> }

    has PDF::DOM::Contents::Stream $.pre-gfx = PDF::DOM::Contents::Stream.new( :parent(self) ); #| prepended graphics
    has PDF::DOM::Contents::Stream $.gfx     = PDF::DOM::Contents::Stream.new( :parent(self) ); #| appended graphics

    method cb-finish {

        if $!pre-gfx.ops || $!gfx.ops {

            my $new-content;

            # wrap new content in save ... restore - for safety's sake
            for $!pre-gfx, $!gfx {
                if .defined && .ops {
                    $new-content = True;
                    .save(:prepend);
                    .restore;
                }
            }

            # also wrap any existing content in save ... restore
            if $new-content {
                my $content = self.decoded;
                if $content.defined && $content.chars
                    && ($content !~~ m:s/^ 'q' /  || $content !~~ m:s/ 'Q' ^/) {
                        $!pre-gfx.save;
                        $!gfx.restore(:prepend);
                }

                my $prepend = $!pre-gfx.ops
                    ?? $!pre-gfx.content ~ "\n"
                    !! '';

                my $append = $!gfx.ops
                    ?? "\n" ~ $!gfx.content
                    !! '';

                self.edit-stream(:$prepend, :$append)
                    if $prepend.chars || $append.chars;
            }
        }
    }

}