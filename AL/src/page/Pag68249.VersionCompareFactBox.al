page 68249 "Version Compare FactBox"
{
    // ©Dynamics.is

    Caption = 'Version Compare Information';
    PageType = CardPart;
    SourceTable = "Version Comparison";

    layout
    {
        area(content)
        {
            field("No. of Tables Compared"; "No. of Tables Compared")
            {
                ApplicationArea = All;
                ToolTip = 'No. of Tables Compared';
            }
            field("No. of Identical Tables"; "No. of Identical Tables")
            {
                ApplicationArea = All;
                Caption = '  There of Identical';
                ToolTip = 'There of Identical';
            }
            field("No. of New Tables"; "No. of New Tables")
            {
                ApplicationArea = All;
                Caption = '  There of New';
                ToolTip = 'There of New';
            }
            field("No. of Modified Tables"; "No. of Modified Tables")
            {
                ApplicationArea = All;
                Caption = '  There of Modifed';
                ToolTip = 'There of Modifed';
            }
            field("No. of Deleted Tables"; "No. of Deleted Tables")
            {
                ApplicationArea = All;
                Caption = '  There of Deleted';
                ToolTip = 'There of Deleted';
            }
            field("''"; '')
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
            field("No. of Fields Compared"; "No. of Fields Compared")
            {
                ApplicationArea = All;
                ToolTip = 'No. of Fields Compared';
            }
            field("No. of Identical Fields"; "No. of Identical Fields")
            {
                ApplicationArea = All;
                Caption = '  There of Identical';
                ToolTip = 'There of Identical';
            }
            field("No. of New Fields"; "No. of New Fields")
            {
                ApplicationArea = All;
                Caption = '  There of New';
                ToolTip = 'There of New';
            }
            field("No. of Modifed Fields"; "No. of Modifed Fields")
            {
                ApplicationArea = All;
                Caption = '  There of Modifed';
                ToolTip = 'There of Modifed';
            }
            field("No. of Deleted Fields"; "No. of Deleted Fields")
            {
                ApplicationArea = All;
                Caption = '  There of Deleted';
                ToolTip = 'There of Deleted';
            }
        }
    }

    actions
    {
    }
}

