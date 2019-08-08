page 68252 "Data Upgrade Activities"
{
    Caption = 'Data Upgrade Activities';
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Data Upgrade Cue";

    layout
    {
        area(content)
        {
            cuegroup(Activities)
            {
                Caption = 'Activities';
                ShowCaption = false;
                field("Table Versions"; "Table Versions")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Table Versions";
                    ToolTip = 'Table Versions';
                }
                field("Version comparasions to 2013"; "Version comparasions to -2013")
                {
                    ApplicationArea = All;
                    Caption = 'Version compare -2013';
                    DrillDownPageID = "To 2013 Comparisons";
                    ToolTip = 'Version compare 2013 and prior versions.';
                }
                field("<Version comparasions 2015>"; "Version comparasions to +2015")
                {
                    ApplicationArea = All;
                    Caption = 'Version compare 2015';
                    DrillDownPageID = "To 2015 Comparisons";
                    ToolTip = 'Version compare 2015 and later versions.';
                }
                field("Upgrade Project"; "Upgrade Project")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Upgrade Projects";
                    ToolTip = 'Upgrade Projects';
                }

            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}

