package AI::NeuralNet::Kohonen::Demo::RGB;

use vars qw/$VERSION/;
$VERSION = 0.11;

=head1 NAME

AI::NeuralNet::Kohonen::Demo::RGB - Colour-based demo

=head1 SYNOPSIS

	use AI::NeuralNet::Kohonen::Demo::RGB;
	$_ = AI::NeuralNet::Kohonen::Demo::RGB->new(
		map_dim	=> 39,
		epochs  => 9,
		table   => "R G B"
	              ."1 0 0"
	              ."0 1 0"
	              ."0 0 1",
	);
	$_->train;
	exit;


=head1 DESCRIPTION

A sub-class of C<AI::NeuralNet::Kohonen>
that Impliments extra methods for make use of TK
in a very slow demonstration of how a SOM can classify
RGB colours. See L<SYNOPSIS>.

=cut

use strict;
use warnings;
use Carp qw/cluck carp confess croak/;

use base "AI::NeuralNet::Kohonen";

use Tk;
use Tk::Canvas;
use Tk::Label;
use Tk qw/DoOneEvent DONT_WAIT/;

#
# Used only by &tk_train
#
sub tk_show { my $self=shift;
	for my $x (0..$self->{map_dim}){
		for my $y (0..$self->{map_dim}){
			my $colour = sprintf("#%02x%02x%02x",
				(int (255 * $self->{map}->[$x]->[$y]->{weight}->[0])),
				(int (255 * $self->{map}->[$x]->[$y]->{weight}->[1])),
				(int (255 * $self->{map}->[$x]->[$y]->{weight}->[2])),
			);
			$self->{c}->create(
				rectangle	=> [
					(1+$x)*$self->{display_scale} ,
					(1+$y)*$self->{display_scale} ,
					(1+$x)*($self->{display_scale})+$self->{display_scale} ,
					(1+$y)*($self->{display_scale})+$self->{display_scale}
				],
				-outline	=> "black",
				-fill 		=> $colour,
			);
		}
	}
	return 1;
}


#
# As &train, but with a real-time TK display.
#
sub train { my ($self,$epochs) = (shift,shift);
	my $bmu_text;
	$epochs = $self->{epochs} unless defined $epochs;

	$self->{display_scale} = 10;
	my $size = $self->{map_dim} * $self->{display_scale};
	$self->{mw} = MainWindow->new(
		-width	=> ($size+200),
		-height	=> ($size+200),
	);
    my $quit_flag = 0;
    my $quit_code = sub {$quit_flag = 1};
    $self->{mw}->protocol('WM_DELETE_WINDOW' => $quit_code);

	$self->{c} = $self->{mw}->Canvas(
		-width	=> $size+100,
		-height	=> $size+100,
	);
	$self->{c}->pack();
	# Labels
	my $e = $self->{mw}->Label(-text => 'Epoch:');
	$e->pack(-side=>'left');
	my $l = $self->{mw}->Label(-text => '0',-textvariable=>\$self->{t});
	$l->pack(-side=>'left');
	my $b = $self->{mw}->Label(-text => '   BMU:');
	$b->pack(-side=>'left');
	my $bl = $self->{mw}->Label(-text => '0',-textvariable=>\$bmu_text);
	$bl->pack(-side=>'left');
	# Replaces Tk's MainLoop
    for (0..$self->{epochs}) {
		if ($quit_flag) {
			$self->{mw}->destroy;
			return;
		}
		$self->{t}++;
		my $target = $self->_select_target;
		my $bmu = $self->_find_bmu($target);
		$bmu_text = $bmu->[1].",".$bmu->[2];
		$self->_adjust_neighbours_of($bmu,$target);
		$self->_decay_learning_rate;
		$self->tk_show;
		$self->{c}->update;
		$l->update;
        DoOneEvent(DONT_WAIT);		# be kind and process XEvents if they arise
	}
	return 1;
}



1;

__END__

=head1 SEE ALSO

See
L<AI::NeuralNet::Kohonen>;
L<AI::NeuralNet::Kohonen::Node>;

=head1 AUTHOR AND COYRIGHT

This implimentation Copyright (C) Lee Goddard, 2003.
All Rights Reserved.

Available under the same terms as Perl itself.
















