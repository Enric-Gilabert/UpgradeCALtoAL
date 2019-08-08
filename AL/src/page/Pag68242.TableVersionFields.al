page 68242 "Table Version Fields"
{
    // ©Dynamics.is

    Caption = 'Table Version Fields';
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
                field("Data Per Company"; "Data Per Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Data Per Company';
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
                field("Field Type"; "Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field Type';
                }
                field(GetOptionString; GetOptionString())
                {
                    ApplicationArea = All;
                    Caption = 'Option String';
                    Editable = false;
                    ToolTip = 'Option String';
                }
                field("Auto Increment"; "Auto Increment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Auto Increment';
                }
                field(SubType; SubType)
                {
                    ApplicationArea = All;
                    Enabled = BLOBValuesEnabled;
                    ToolTip = 'SubType';
                }
                field(Compressed; Compressed)
                {
                    ApplicationArea = All;
                    Enabled = BLOBValuesEnabled;
                    ToolTip = 'Compressed';
                }
                field("SQL Data Type"; "SQL Data Type")
                {
                    ApplicationArea = All;
                    Enabled = not BLOBValuesEnabled;
                    ToolTip = 'SQL Data Type';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        BLOBValuesEnabled := UpperCase("Field Type") = 'BLOB';
    end;

    var
        BLOBValuesEnabled: Boolean;
}

