page 68245 "Table Version List"
{
    // ©Dynamics.is

    Caption = 'Table Version List';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Table Version Field";

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
            }
        }
    }

    actions
    {
    }
}

