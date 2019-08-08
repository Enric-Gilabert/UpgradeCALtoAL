page 68240 "Data Upgrade Role Center"
{
    Caption = 'Data Upgrade Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part("Activities"; "Data Upgrade Activities")
            {
                Caption = 'Activities';
                ApplicationArea = All;
                ToolTip = 'Data Upgrade ';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Setup")
            {
                Caption = 'Setup';
                ApplicationArea = All;
                image = Setup;
                ToolTip = 'Configure Data Upgrade Solution';
                RunObject = page "Data Upgrade Setup";

            }
        }
        area(embedding)
        {
            action("Table Versions")
            {
                ApplicationArea = All;
                Caption = 'Table Versions';
                Image = "Table";
                Promoted = false;
                RunObject = Page "Table Versions";
                ToolTip = 'Table Versions';
            }
            action("To 2015 Comparisons")
            {
                ApplicationArea = All;
                Caption = 'To 2015 Comparisons';
                Image = CompareCost;
                Promoted = false;
                RunObject = Page "To 2015 Comparisons";
                ToolTip = 'To 2015 Comparisons';
            }
            action("To 2013 Comparisons")
            {
                ApplicationArea = All;
                Caption = 'To 2013 Comparisons';
                Image = CompareCOA;
                Promoted = false;
                RunObject = Page "To 2013 Comparisons";
                ToolTip = 'To 2013 Comparisons';
            }
            action("Upgrade Projects")
            {
                ApplicationArea = All;
                Caption = 'Upgrade Projects';
                Promoted = false;
                Image = DataEntry;
                RunObject = Page "Upgrade Projects";
                ToolTip = 'Upgrade Projects';
            }
        }
    }
}

