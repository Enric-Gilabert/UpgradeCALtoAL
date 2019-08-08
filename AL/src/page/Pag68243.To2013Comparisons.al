page 68243 "To 2013 Comparisons"
{
    // ©Dynamics.is

    Caption = 'Version Comparisons';
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Step 1,Step 2,Result';
    SourceTable = "Version Comparison";
    SourceTableView = WHERE ("Upgrade Code Version" = CONST ("To 2013 R2"));
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
                field("Source Version Code"; "Source Version Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Version Code';
                }
                field("Destination Version Code"; "Destination Version Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Destination Version Code';
                }
                field("First Upgrade Table ID"; "First Upgrade Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'First Upgrade Table ID';
                }
                field("First Upgrade Codeunit ID"; "First Upgrade Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'First Upgrade Codeunit ID';
                }
                field("Step 1 Tables Object File"; "Step 1 Tables Object File".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Step 1 Tables Object File';
                    Editable = false;
                    ToolTip = 'Step 1 Tables Object File';
                }
                field("Step 1 Codeunit Object File"; "Step 1 Codeunit Object File".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Step 1 Codeunit Object File';
                    Editable = false;
                    ToolTip = 'Step 1 Codeunit Object File';
                }
                field("Step 1 Delete Object File"; "Step 1 Delete Object File".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Step 1 Delete Object File';
                    Editable = false;
                    ToolTip = 'Step 1 Delete Object File';
                }
                field("Step 2 Codeunit Object File"; "Step 2 Codeunit Object File".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Step 2 Codeunit Object File';
                    Editable = false;
                    ToolTip = 'Step 2 Codeunit Object File';
                }
                field("Step 2 Mark Tables Object File"; "Step 2 Mark Tables Object File".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Step 2 Delete Object File';
                    Editable = false;
                    ToolTip = 'Step 2 Delete Object File';
                }
            }
        }
        area(factboxes)
        {
            part(Control1100408014; "Version Compare FactBox")
            {
                ApplicationArea = All;
                SubPageLink = Code = FIELD (Code);
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Table Versions")
            {
                ApplicationArea = All;
                Caption = 'Table Versions';
                Image = "Table";
                RunObject = Page "Table Versions";
                RunPageMode = View;
                ToolTip = 'Table Versions';
            }
            action("Tables")
            {
                ApplicationArea = All;
                Caption = 'Tables';
                Image = Entries;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                RunObject = Page "Version Compare Table Res.";
                RunPageLink = "Compare Version Code" = FIELD (Code);
                RunPageMode = View;
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'Tables';
            }
        }
        area(processing)
        {
            action("Compare")
            {
                ApplicationArea = All;
                Caption = 'Compare';
                Ellipsis = true;
                Image = CompareCost;
                ShortcutKey = F9;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Compare';

                trigger OnAction()
                var
                    FieldCompareMgt: Codeunit "Field Compare Management";
                begin
                    FieldCompareMgt.Compare(Rec);
                end;
            }
            action("Delete Comparison")
            {
                ApplicationArea = All;
                Caption = 'Delete Comparison';
                Ellipsis = true;
                Image = RemoveLine;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Delete Comparison';

                trigger OnAction()
                begin
                    DeleteComparation();
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
                    ToolTip = 'Import';

                    trigger OnAction()
                    begin
                        ImportResults();
                    end;
                }
                action("ExportXML")
                {
                    ApplicationArea = All;
                    Caption = 'Export';
                    Image = Export;
                    ToolTip = 'Export';

                    trigger OnAction()
                    begin
                        ExportResults();
                    end;
                }
            }
            group("Step 1")
            {
                Caption = 'Step 1';
                ToolTip = 'Step 1';
                action("Create 2013 Step 1 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Create 2013 Step 1 Code';
                    Image = NewStatusChange;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Create 2013 Step 1 Code';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"To 2013 Step 1 Code Maker", Rec);
                    end;
                }
                action("Step 1 Save Table Object File")
                {
                    ApplicationArea = All;
                    Caption = 'Save Table Object File';
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Save Table Object File';

                    trigger OnAction()
                    begin
                        SaveStep1TableObjectTextFile('Step1Tables.txt');
                    end;
                }
                action("Step 1 Save Codeunit Object File")
                {
                    ApplicationArea = All;
                    Caption = 'Save Codeunit Object File';
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Save Codeunit Object File';

                    trigger OnAction()
                    begin
                        SaveStep1CodeunitObjectTextFile('Step1Codeunit.txt');
                    end;
                }
                action("Step 1 Save Delete Discontinued Tables Addin")
                {
                    ApplicationArea = All;
                    Caption = 'Save Delete Discontinued Tables Addin';
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Save Delete Discontinued Tables Addin';

                    trigger OnAction()
                    begin
                        SaveStep1DeleteDiscontinuedTablesTextFile('Step1DeleteTables.txt');
                    end;
                }
            }
            group("Step 2")
            {
                Caption = 'Step 2';
                ToolTip = 'Step 2';
                action("Create 2013 Step 2 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Create 2013 Step 2 Code';
                    Image = NewStatusChange;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Create 2013 Step 2 Code';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"To 2013 Step 2 Code Maker", Rec);
                    end;
                }
                action("Step 2 Save Codeunit Object File")
                {
                    ApplicationArea = All;
                    Caption = 'Save Codeunit Object File';
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Save Codeunit Object File';

                    trigger OnAction()
                    begin
                        SaveStep2CodeunitObjectTextFile('Step2Codeunit.txt');
                    end;
                }
                action("Step 2 Save Mark Tables Tables Addin")
                {
                    ApplicationArea = All;
                    Caption = 'Save Mark Tables Tables Addin';
                    Image = ExportFile;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Save Mark Tables Tables Addin';

                    trigger OnAction()
                    begin
                        SaveStep2MarkTablesTextFile('Step2MarkTables.txt');
                    end;
                }
            }
            group(Tools)
            {
                Caption = 'Tools';
                ToolTip = 'Tools';
                action("Convert Object File to Code")
                {
                    ApplicationArea = All;
                    Caption = 'Convert Object File to Code';
                    Image = CopyCosttoGLBudget;
                    RunObject = Report "Conv. Object File to Code";
                    ToolTip = 'Convert Object File to Code';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Upgrade Code Version" := "Upgrade Code Version"::"To 2013 R2";
    end;
}

