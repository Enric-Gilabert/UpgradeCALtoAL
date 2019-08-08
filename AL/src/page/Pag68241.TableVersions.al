page 68241 "Table Versions"
{
    // ©Dynamics.is

    Caption = 'Table Versions';
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Import,Result';
    SourceTable = "Table Version";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Code';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Name';
                }
                field("Base Version"; "Base Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Base Version';
                }
                field("Base Version Code"; "Base Version Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Base Version Code';
                }
                field("No. of Fields"; "No. of Fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. of Fields';
                }
                field("No. of Key Fields"; "No. of Key Fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'No. of Key Fields';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import")
            {
                ApplicationArea = All;
                Caption = 'Import Object Text File';
                Ellipsis = true;
                Image = Import;
                Scope = "Repeater";
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Import Object Text File';

                trigger OnAction()
                var
                    ImportBatch: Report "Read Table Object File";
                begin
                    ImportBatch.SetTableVersion(Rec, false);
                    ImportBatch.RunModal();
                end;
            }
            action("ImportWithIDInName")
            {
                ApplicationArea = All;
                Caption = 'Import Object Text File with table id in comma delimited name';
                Ellipsis = true;
                Image = Import;
                Scope = "Repeater";
                ShortCutKey = 'Shift+F9';
                ToolTip = 'Import Object Text File with table id in comma delimited name';

                trigger OnAction()
                var
                    ImportBatch: Report "Read Table Object File";
                begin
                    ImportBatch.SetTableVersion(Rec, true);
                    ImportBatch.RunModal();
                end;
            }
            action("Delete Import")
            {
                ApplicationArea = All;
                Caption = 'Delete Import';
                Ellipsis = true;
                Image = RemoveLine;
                Scope = "Repeater";
                Promoted = true;
                PromotedCategory = Category4;
                ToolTip = 'Delete Import';

                trigger OnAction()
                begin
                    DeleteFieldsAndKeys();
                end;
            }
            group(XML)
            {
                Caption = 'XML';
                ToolTip = 'XML';
                action("ImportXML")
                {
                    ApplicationArea = All;
                    Caption = 'Import';
                    Ellipsis = true;
                    Image = Import;
                    Scope = "Repeater";
                    ToolTip = 'Import';

                    trigger OnAction()
                    begin
                        ImportVersion();
                    end;
                }
                action("ExportXML")
                {
                    ApplicationArea = All;
                    Caption = 'Export';
                    Image = Export;
                    Scope = "Repeater";
                    ToolTip = 'Export';

                    trigger OnAction()
                    begin
                        ExportVersion();
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Fields")
            {
                ApplicationArea = All;
                Caption = 'Version Table Fields';
                Image = "Table";
                Scope = "Repeater";
                Promoted = true;
                PromotedCategory = Category5;
                RunObject = Page "Table Version Fields";
                RunPageLink = "Table Version Code" = FIELD (Code);
                RunPageMode = View;
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'Version Table Fields';
            }
            action("Primary Keys")
            {
                ApplicationArea = All;
                Caption = 'Primary Keys';
                Image = "Table";
                Scope = "Repeater";
                Promoted = true;
                PromotedCategory = Category5;
                RunObject = Page "Table Version Primary Keys";
                RunPageLink = "Table Version Code" = FIELD (Code);
                RunPageMode = View;
                ToolTip = 'Primary Keys';
            }
        }
    }
}

