# $Author$
# $Date$
# $Revision$

#    Copyright (c) 2008 Dominique Dumont.
#
#    This file is part of Config-Model-TkUi.
#
#    Config-Model is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser Public License as
#    published by the Free Software Foundation; either version 2.1 of
#    the License, or (at your option) any later version.
#
#    Config-Model is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser Public License for more details.
#
#    You should have received a copy of the GNU Lesser Public License
#    along with Config-Model; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA

package Config::Model::Tk::AnyViewer ;

use strict;
use warnings ;
use Carp ;

use Tk::Photo ;
use Tk::ROText;
use Config::Model::TkUI ;

use vars qw/$VERSION $icon_path/ ;

$VERSION = sprintf "1.%04d", q$Revision$ =~ /(\d+)/;

my @fbe1 = qw/-fill both -expand 1/ ;
my @fxe1 = qw/-fill x    -expand 1/ ;
my @fx   = qw/-fill x             / ;
my @e1   = qw/           -expand 1/ ;

my %img ;
*icon_path = *Config::Model::TkUI::icon_path ;

sub add_header {
    my ($cw,$type,$item) = @_ ;

    unless (%img) {
	$img{edit} = $cw->Photo(-file => $icon_path.'edit-find-replace.gif');
	$img{view} = $cw->Photo(-file => $icon_path.'system-search.gif');
    }

    my $idx ;
    $idx = $item->index_value if $item->can('index_value' ) ;
    my $elt_name = $item->composite_name ;

    my $parent = $item->parent ;
    my $class = defined $parent ? $item->parent->config_class_name 
              :                   $item->config_class_name ;

    my $label = "$type: Class $class";
    $label .= "- Element $elt_name" if defined $parent ;
    my $f = $cw -> Frame -> pack (@fxe1);

    $f -> Label ( -text => $label, -anchor => 'w' )
       -> pack  (-side => 'left', @fxe1);

    $f -> Label (-image => $img{lc($type)} , -anchor => 'e') 
      -> pack (-side => 'left');
}

my @top_frame_args = qw/-relief raised -borderwidth 4/ ;
my @low_frame_args = qw/-relief sunken -borderwidth 1/ ;
my $padx = 20 ;
my $text_font = [qw/-family Arial -weight normal/] ;

sub add_info_frame {
    my $cw = shift;
    my @items = @_;

    my $frame = $cw->Frame()->pack(@fx) ;
    $frame -> Label(-text => 'Info', -anchor => 'w' ) ->pack(qw/-fill x/) ;

    my $i_frame = $frame->Frame(
				-padx => $padx 
			       )->pack(@fx) ;
    map { $i_frame -> Label(-text => $_, 
			    -anchor => 'w',  
			    -font => $text_font ,
			   ) ->pack(@fx)  ;
	} @items;
}


sub add_help_frame {
    my $cw = shift ;

    my $htop_frame = $cw->Frame()->pack(@fxe1) ;
    $htop_frame -> Label(-text => 'Help', -anchor => 'w' ) ->pack(@fx) ;

    $cw->{help_f} = $htop_frame->Frame()->pack(@fxe1) ;
}

sub add_help {
    my $cw = shift ;
    my $type = shift ;
    my $help = shift ;

    my $help_frame = $cw->{help_f} -> Frame(
					    -padx => $padx ,
					   )->pack(@fxe1);

    $help_frame->Label(-text => "on $type: ", 
		       -font => $text_font 
		      )->pack(-side => 'left');

    my @text = ref $help ? ( -textvariable => $help)
             :             ( -text => $help ) ;

    chomp $help if defined $help ;
    if (    defined $help and not ref $help 
	and ($help =~ /\n/ or length($help) > 70)) {
	$help_frame->Scrolled('ROText',
			      -scrollbars => 'ow',
			      -wrap => 'word',
			      -height => 6,
			     )
	  ->pack( -fill => 'x')
	    ->insert('end',$help) ;
    }
    else {
	$help_frame->Label( @text,
			    -justify => 'left',
			    -font => $text_font ,
			    -anchor => 'w')
	  ->pack( -fill => 'x');
    }
}

sub add_editor_button {
    my ($cw,$path) = @_ ;

    my $sub = sub {
	$cw->parent->parent->parent->parent
	  -> create_element_widget( edit => $path) ;
	} ;
    $cw->Button(-text => 'Edit ...', -command => $sub)-> pack ;
}


1;
