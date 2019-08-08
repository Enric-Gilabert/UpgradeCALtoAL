page 68246 "Table Version Primary Keys"
{
    // ©Dynamics.is

    Caption = 'Table Version Primary Keys';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Table Version Primary Key";

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
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Table Name';
                }
                field("Field Index No."; "Field Index No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field Index No.';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field No.';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field Name';
                }
            }
        }
    }

    actions
    {
    }
}

