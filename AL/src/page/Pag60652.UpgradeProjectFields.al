page 60652 "Upgrade Project Fields"
{

    PageType = List;
    SourceTable = "Upgrade Project Field";
    Caption = 'Upgrade Project Fields';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("App Package Id"; "App Package Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("App Table Id"; "App Table Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field(IsPrimaryKey; GetIsPrimaryKeyField())
                {
                    Caption = 'Part of primary key';
                    ApplicationArea = All;
                    Editable = false;
                }

                field("App Field ID"; "App Field ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("Upgrade Table Id"; "Upgrade Table Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Editable = false;
                }
                field("Upgrade Field ID"; "Upgrade Field ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    QuickEntry = true;
                }
                field("App Table Name"; "App Table Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("App Field Name"; "App Field Name")
                {
                    ApplicationArea = All;
                }
                field("Upgrade Table Name"; "Upgrade Table Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Upgrade Field Name"; "Upgrade Field Name")
                {
                    ApplicationArea = All;
                }
                field("Transformation Rule"; "Transformation Rule")
                {
                    ApplicationArea = All;
                }
                field(Warning; GetWarning())
                {
                    Caption = 'Field Warning';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }


}
