page 68250 "Version Compare Field Fact"
{
    Caption = 'Fields Details';
    PageType = CardPart;
    SourceTable = "Compare Field Result";

    layout
    {
        area(content)
        {
            field("Table No."; "Table No.")
            {
                ApplicationArea = All;
                DrillDown = true;
                ToolTip = 'Table No.';

                trigger OnDrillDown()
                begin
                    LookupTableResult();
                end;
            }
            field("Source Table Name"; GetSourceTableName())
            {
                ApplicationArea = All;
                Caption = 'Source Table Name';
                ToolTip = 'Source Table Name';
            }
            field("Destination Table Name"; GetDestinationTableName())
            {
                ApplicationArea = All;
                Caption = 'Destination Table Name';
                ToolTip = 'Destination Table Name';
            }
            group("Source Field")
            {
                Caption = 'Source Field';
                field("Source Field Name"; SourceFieldDetails[1])
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Name';
                }
                field("Source Field Type"; SourceFieldDetails[2])
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Type';
                }
                field("Source Field Option String"; SourceFieldDetails[3])
                {
                    ApplicationArea = All;
                    Caption = 'Option String';
                    ToolTip = 'Option String';
                }
            }
            group("Destination Field")
            {
                Caption = 'Destination Field';
                field("Destination Field Name"; DestinationFieldDetails[1])
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Name';
                }
                field("Destination Field Type"; DestinationFieldDetails[2])
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Type';
                }
                field("Destination Field Option String"; DestinationFieldDetails[3])
                {
                    ApplicationArea = All;
                    Caption = 'Option String';
                    ToolTip = 'Option String';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        GetSourceFieldDetails(SourceFieldDetails);
        GetDestinationFieldDetails(DestinationFieldDetails);
    end;

    var
        SourceFieldDetails: array[3] of Text;
        DestinationFieldDetails: array[3] of Text;
}

