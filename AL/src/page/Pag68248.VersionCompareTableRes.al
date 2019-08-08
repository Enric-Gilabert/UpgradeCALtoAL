page 68248 "Version Compare Table Res."
{
    // ©Dynamics.is

    Caption = 'Version Compare Table Results';
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Step 1,Step 2,Result';
    SourceTable = "Compare Table Result";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    ToolTip = 'Table No.';
                }
                field(GetSourceTableName; GetSourceTableName())
                {
                    ApplicationArea = All;
                    Caption = 'Source Table Name';
                    Editable = false;
                    StyleExpr = LineStyle;
                    ToolTip = 'Source Table Name';
                }
                field(GetDestinationTableName; GetDestinationTableName())
                {
                    ApplicationArea = All;
                    Caption = 'Destination Table Name';
                    Editable = false;
                    StyleExpr = LineStyle;
                    ToolTip = 'Destination Table Name';
                }
                field(Result; Result)
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    ToolTip = 'Result';
                }
                field("Step 1 Action"; "Step 1 Action")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    ToolTip = 'Step 1 Action';
                }
                field("Step 2 Action"; "Step 2 Action")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    ToolTip = 'Step 2 Action';
                }
                field("Step 2 Transfer Fields"; "Step 2 Transfer Fields")
                {
                    ApplicationArea = All;
                    ToolTip = 'Step 2 Transfer Fields';
                }
                field("Upgrade Table ID"; "Upgrade Table ID")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    ToolTip = 'Upgrade Table ID';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if CurrPage.Editable() then
                            Validate("Upgrade Table ID", DestinationTableLookup("Upgrade Table ID"));
                    end;
                }
                field("Upgrade Codeunit ID"; "Upgrade Codeunit ID")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    ToolTip = 'Upgrade Codeunit ID';
                    Visible = false;
                }
                field("Error Text"; VerifyTableActions(''))
                {
                    ApplicationArea = All;
                    Caption = 'Error Text';
                    Editable = false;
                    StyleExpr = LineStyle;
                    ToolTip = 'Error Text';
                }
            }
        }
        area(factboxes)
        {
            part(Control1100408024; "Version Compare Table Fact")
            {
                ApplicationArea = All;
                SubPageLink = Code = FIELD ("Compare Version Code"),
                              "Table No. Filter" = FIELD ("Table No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Fields")
            {
                ApplicationArea = All;
                Caption = 'Fields';
                Image = Entries;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                RunObject = Page "Version Compare Field Res.";
                RunPageLink = "Compare Version Code" = FIELD ("Compare Version Code"),
                              "Table No." = FIELD ("Table No."),
                              "Table Result Filter" = FIELD (Result);
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'Fields';
            }
        }
        area(processing)
        {
            action("SplitResults")
            {
                ApplicationArea = All;
                Caption = 'Split Results';
                Ellipsis = true;
                Enabled = SplitTableEnabled;
                Image = Splitlines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Split Results';

                trigger OnAction()
                begin
                    SplitModifiedResult();
                end;
            }
            group("Step 1")
            {
                Caption = 'Step 1';
                ToolTip = 'Step 1';
                action("Step 1 Ignore to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Ignore to Selected Lines';
                    Image = Allocations;
                    ToolTip = 'Ignore to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(1, 0);
                    end;
                }
                action("Step 1 Copy to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Copy to Selected Lines';
                    Image = Copy;
                    ToolTip = 'Copy to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(1, 1);
                    end;
                }
                action("Step 1 Move to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Move to Selected Lines';
                    Image = MoveNegativeLines;
                    ToolTip = 'Move to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(1, 2);
                    end;
                }
                action("Step 1 Force to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Force to Selected Lines';
                    Image = DeleteQtyToHandle;
                    ToolTip = 'Force to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(1, 3);
                    end;
                }
                action("Step 1 Move with Source Id")
                {
                    ApplicationArea = All;
                    Caption = 'Move with Source Id to Selected Lines';
                    Image = MoveToNextPeriod;
                    ToolTip = 'Move with Source Id to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(1, 5);
                    end;
                }
            }
            group("Step 2")
            {
                Caption = 'Step 2';
                ToolTip = 'Step 2';
                action("Step 2 Ignore to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Ignore to Selected Lines';
                    Image = Allocations;
                    ToolTip = 'Ignore to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(2, 0);
                    end;
                }
                action("Step 2 Copy to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Copy to Selected Lines';
                    Image = Copy;
                    ToolTip = 'Copy to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(2, 1);
                    end;
                }
                action("Step 2 Move to Selected Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Move to Selected Lines';
                    Image = MoveNegativeLines;
                    ToolTip = 'Move to Selected Lines';

                    trigger OnAction()
                    begin
                        ModifySelectedLines(2, 2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SplitTableEnabled := Result = Result::Modified;
    end;

    trigger OnAfterGetRecord()
    begin
        LineStyle := GetLineStyle();
    end;

    var
        LineStyle: Text;
        [InDataSet]
        SplitTableEnabled: Boolean;

    local procedure ModifySelectedLines(StepNo: Integer; StepAction: Option Ignore,Copy,Move,Force,Check,"Use Source Id")
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        CurrPage.SetSelectionFilter(CompareTableResult);
        SetSelectedLinesStepAction(CompareTableResult, StepNo, StepAction);
    end;
}

