# --
# Kernel/Output/HTML/OutputFilterOwnerChangeTicketView.pm
# Copyright (C) 2015 - 2016 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::OutputFilterOwnerChangeTicketView;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::Output::HTML::Layout
    Kernel::System::User
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    if ( $Templatename  =~ m{AgentTicketOverview(?:Small|Medium|Preview)\z} ) {
        my %User = $UserObject->UserList(
            Type    => 'Long',
        );

        my $AgentGroup = $ConfigObject->Get('QuickOwnerChange::OwnerGroup');
        if ( $AgentGroup ) {
            my $GroupID = $GroupObject->GroupLookup( Group => $AgentGroup );
            my $Type    = $ConfigObject->Get('QuickOwnerChange::Permissions') || 'rw';

            %User = $GroupObject->GroupMemberList(
                GroupID => $GroupID,
                Type    => $Type,
                Result  => 'HASH',
            );

            $User{$_} = $UserObject->UserName( UserID => $_ ) for keys %User;
        }

        my @Data = map{ { Key => $_, Value => $User{$_} } }sort{ $User{$a} cmp $User{$b} }keys %User;
        
        unshift @Data, {
            Key => '', 
            Value => ' - ' . ($ConfigObject->Get( 'QuickOwnerChange::NoneLabel' ) || 'QuickOwnerChange')  . ' - ',
        };
        
        my $Select = $LayoutObject->BuildSelection(
            Data         => \@Data,
            Name         => 'QuickOwnerChange',
            Size         => 1,
            HTMLQuote    => 1,
        );

        my $Snippet = $LayoutObject->Output(
            TemplateFile => 'QuickOwnerChangeSnippetTicketView',
            Data         => {
                Select => $Select,
            },
        ); 

        #scan html output and generate new html input
        ${ $Param{Data} } =~ s{(<ul \s+ class="Actions"> \s* <li .*? /li>)}{$1 $Snippet}xmgs;
    }

    return ${ $Param{Data} };
}

1;
