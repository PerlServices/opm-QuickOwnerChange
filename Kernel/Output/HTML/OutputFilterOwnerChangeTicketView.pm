# --
# Kernel/Output/HTML/OutputFilterOwnerChangeTicketView.pm
# Copyright (C) 2011 Perl-Services.de, http://www.perl-services.de/
# --
# $Id: OutputFilterOwnerChangeTicketView.pm,v 1.1 2011/04/19 10:21:42 rb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterOwnerChangeTicketView;

use strict;
use warnings;

use Kernel::System::Encode;
use Kernel::System::Time;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for my $Object (
        qw(MainObject ConfigObject LogObject LayoutObject ParamObject)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    if ( $Templatename  =~ m{AgentTicketOverview(?:Small|Medium|Preview)\z} ) {
        my @Indexes = sort{ $List{$a} cmp $List{$b} }keys %List;
        my @Data    = map{ { Key => $_, Value => $List{$_} } }@Indexes;
        
        unshift @Data, {
            Key => '', 
            Value => ' - ' . ($Self->{ConfigObject}->Get( 'QuickOwnerChange::NoneLabel' ) || 'QuickOwnerChange')  . ' - ',
        };
        
        my $Select = $Self->{LayoutObject}->BuildSelection(
            Data         => \@Data,
            Name         => 'QuickOwnerChange',
            Size         => 1,
            HTMLQuote    => 1,
        );

        my $Snippet = $Self->{LayoutObject}->Output(
            TemplateFile => 'QuickOwnerChangeSnippetTicketView',
            Data         => {
                QuickOwnerChangeSelect => $Select,
                FormID                 => $FormID,
            },
        ); 

        #scan html output and generate new html input
        ${ $Param{Data} } =~ s{(<ul \s+ class="Actions"> \s* <li .*? /li>)}{$1 $Snippet}xmgs;
    }

    return ${ $Param{Data} };
}

1;
