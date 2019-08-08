page 60653 "Upgrade Project App Fields"
{

    PageType = List;
    SourceTable = "Upgrade Project App Field";
    Caption = 'Upgrade Project App Fields';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("App Field ID"; "App Field ID")
                {
                    ApplicationArea = All;
                }
                field("App Field Name"; "App Field Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
