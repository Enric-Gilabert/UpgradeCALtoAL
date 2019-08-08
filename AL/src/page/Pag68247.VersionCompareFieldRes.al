page 68247 "Version Compare Field Res."
{
    // ©Dynamics.is

    Caption = 'Version Compare Field Results';
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Step 1,Step 2,Result';
    SourceTable = "Compare Field Result";
    SourceTableView = SORTING (Result);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Table No.';
                    Visible = false;
                }
                field(GetSourceTableName; GetSourceTableName())
                {
                    ApplicationArea = All;
                    Caption = 'Source Table Name';
                    Editable = false;
                    ToolTip = 'Source Table Name';
                    Visible = false;
                }
                field(GetDestinationTableName; GetDestinationTableName())
                {
                    ApplicationArea = All;
                    Caption = 'Destination Table Name';
                    Editable = false;
                    ToolTip = 'Destination Table Name';
                    Visible = false;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field No.';
                }
                field(GetSourceFieldName; GetSourceFieldName())
                {
                    ApplicationArea = All;
                    Caption = 'Source Field Name';
                    Editable = false;
                    ToolTip = 'Source Field Name';
                }
                field(GetDestinationFieldName; GetDestinationFieldName())
                {
                    ApplicationArea = All;
                    Caption = 'Destination Field Name';
                    Editable = false;
                    ToolTip = 'Destination Field Name';
                }
                field(Result; Result)
                {
                    ApplicationArea = All;
                    ToolTip = 'Result';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field("Copy Value From Field No."; "Copy Value From Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Copy Value From Field No.';
                }
            }
        }
        area(factboxes)
        {
            part(Control1100408011; "Version Compare Field Fact")
            {
                ApplicationArea = All;
                SubPageLink = "Compare Version Code" = FIELD ("Compare Version Code"),
                              "Table No." = FIELD ("Table No."),
                              "Field No." = FIELD ("Field No.");
            }
        }
    }

    actions
    {
    }
}

