#!/usr/bin/env raku

# Adapted from the Perl version.

# Rather than put in a number of say statements here, we use a
# "here document".  This is very useful for long strings of text.  In this
# case, everything between the end of the "say" line and the line with
# "END_INSTRUCTIONS" on it will be printed verbatim.
say q:to/END_INSTRUCTIONS/;

Acey-Ducey
Adapted from Creative Computing, Morristown, New Jersey


Acey-Ducey is played as follows. The dealer (computer) deals two cards face up.
You have an option to bet or not bet, depending on whether or not you feel that
the next card drawn will have a value between the first two.  Aces are low.

Bets must be in whole-dollar amounts only.

If you do not want to bet, input a 0.  If you want to quit, input a -1.

END_INSTRUCTIONS

my @cards       = 1 .. 13;    # That is, Ace through King.
my $keepPlaying = True;

GAME:
while $keepPlaying {
	my $playerBalance = 100;      # The player starts with $100

	HAND:
	loop {
		say "\nYou now have $playerBalance dollars.\n\n";

        # We'll create a new array that is a shuffled version of the deck.
        my @shuffledDeck = @cards.pick: *;

        # Then, by taking the two "top cards" off the deck, we're guaranteed
        # that those will be unique.  This way we don't have to keep drawing
        # if we get, say, two queens.  We sort them as we pull them to make
        # sure that the first card is lower than the second one.
        my ( $firstCard, $secondCard ) = @shuffledDeck[ 0 .. 1 ].sort;

        say "I drew ", nameOfCard($firstCard), " and ", nameOfCard($secondCard), ".\n";

        my $bet = getValidBet($playerBalance);
        
        if $bet == 0 {
            say "Chicken!\n";
            next HAND;
        }

        if $bet < 0 {
            last GAME;
        }

        # Now we re-shuffle the whole deck again and choose a third card.
        # (Note: This is how the odds get stacked in favor of the dealer since
        # the third card can be exactly the same as the first or second.)
        @shuffledDeck = @cards.pick: *;
        my $thirdCard = @shuffledDeck[0];

        say "I drew ", nameOfCard($thirdCard), "!";

        if ( $firstCard < $thirdCard ) && ( $thirdCard < $secondCard ) {
            say "You win!\n";
            $playerBalance += $bet;
        }
        else {
            say "You lose!\n";
            $playerBalance -= $bet;
        }

        if $playerBalance <= 0 {
            say "Sorry, buddy, you blew your wad!\n";
            last HAND;
        }
    }

    $keepPlaying = promptUserToKeepPlaying();
}

say "Thanks for playing!";

################
sub getValidBet ($maxBet) {
    INPUT: 
    {
        say "\nWhat's your bet? ";

        my $input = $*IN.get;

        # This regular expression will validate that the player entered an integer.
        # The !~ match operate *negates* the match, so if the player did NOT enter
        # an integer, they'll be given an error and prompted again.
        if $input !~~ /^        # Match the beginning of the string
                    <[+-]>?    # Optional plus or minus...
                    \d+      # followed by one more more digits...
                    $        # and then the end of the string
                    /   
        {
            say "Sorry, numbers only!";
            redo INPUT;
        }

        if $input > $maxBet {
            say "Sorry, my friend, you can't bet more money than you have.";
            say "You only have $maxBet dollars to spend!";
            redo INPUT;
        }

        return $input;
    }
}

# Since arrays in Perl are 0-based, we need to convert the value that we drew from
# the array to its proper position in the deck.
sub nameOfCard ($value) {

    # Note that the Joker isn't used in this game, but since arrays in Perl are
    # 0-based, it's useful to have something there to represent the "0th"
    # position.  This way the rest of the elements match their expected values
    # (e.g., element 1 is Ace, element 7 is 7, and element 12 is Queen).

    my @cardlist = <Joker Ace 2 3 4 5 6 7 8 9 10 Jack Queen King>;
    return @cardlist[$value];
}

sub promptUserToKeepPlaying {
    YESNO:
    {
       	say "Try again (Y/N)? ";

        my $input = uc $*IN.get;

        if $input eq 'Y' {
            return True;
        }
        elsif  $input eq 'N' {
            return False;
        }
        else {
            redo YESNO;
        }
    }
}
