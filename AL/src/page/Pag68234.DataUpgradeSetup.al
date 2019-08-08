page 68234 "Data Upgrade Setup"
{
    Caption = 'Data Upgrade Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "Data Upgrade Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Data Upgrade Tool Enabled"; "Data Upgrade Tool Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Data Upgrade Tool Enabled';
                }
            }

        }
    }

    actions
    {
        area(processing)
        {
        }
    }

    trigger OnInit()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}

