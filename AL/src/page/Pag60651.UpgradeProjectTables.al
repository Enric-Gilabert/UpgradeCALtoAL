page 60651 "Upgrade Project Tables"
{

    PageType = List;
    SourceTable = "Upgrade Project Table";
    Caption = 'Upgrade Project Tables';
    InsertAllowed = false;
    DeleteAllowed = false;

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
                    ShowMandatory = true;
                    Editable = false;
                }
                field("Upgrade Table Id"; "Upgrade Table Id")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
                field("App Table Name"; "App Table Name")
                {
                    ApplicationArea = All;
                }
                field("Upgrade Table Name"; "Upgrade Table Name")
                {
                    ApplicationArea = All;
                }
                field("Data Upgrade Method"; "Data Upgrade Method")
                {
                    ApplicationArea = All;
                    QuickEntry = true;
                }
                field("Upgrade Table Record Count"; UpgradeTableRecordCount)
                {
                    ApplicationArea = All;
                    Caption = 'Upgrade Table Record Count';
                    Editable = false;
                }
                field("Job Queue Status"; GetJobQueueEntryStatus())
                {
                    Caption = 'Job Queue Status';
                    Editable = false;
                    ToolTip = 'Displays the Job Queue Entry Status, if the data upgrade has been scheduled and is not completed.';

                    trigger OnDrillDown()
                    begin
                        JobQueueEntryDrillDown();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Fields")
            {
                ApplicationArea = All;
                Caption = 'Fields';
                Image = SetupColumns;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                RunObject = Page "Upgrade Project Fields";
                RunPageLink = "App Package Id" = field ("App Package Id"), "App Table Id" = field ("App Table Id");
                ToolTip = 'Select or set up fields for data upgrade table.';
            }
            action(RefreshSuggestion)
            {
                ApplicationArea = All;
                Caption = 'Refrech Table Metadata';
                Image = WorkCenterLoad;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                ToolTip = 'Reloads table metadata and mapping.  Will remote previous mapping!';

                trigger OnAction()
                begin
                    UpdateMetadata();
                end;
            }
            action("ExecuteDataUpgrade")
            {
                ApplicationArea = All;
                Caption = 'Execute Data Upgrade';
                Image = DataEntry;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Page;
                ToolTip = 'Executed the selected data upgrade method for the selected tables.';

                trigger OnAction()
                var
                    ADVUpgradeProjTable: Record "Upgrade Project Table";
                    ADVUpgradeProjDataTrans: Codeunit "Upgrade Project Data Trans";
                begin
                    CurrPage.SetSelectionFilter(ADVUpgradeProjTable);
                    ADVUpgradeProjDataTrans.ExecuteDataTransfer(ADVUpgradeProjTable);
                end;
            }
            action("SceduleDataUpgrade")
            {
                ApplicationArea = All;
                Caption = 'Schedule Data Upgrade';
                Image = Timesheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = Page;
                ToolTip = 'Schedule the selected data upgrade method for the selected tables to be executed by the Job Queue.';

                trigger OnAction()
                var
                    ADVUpgradeProjTable: Record "Upgrade Project Table";
                    ADVUpgradeProjScheduler: Codeunit "Upgrade Project Scheduler";
                begin
                    CurrPage.SetSelectionFilter(ADVUpgradeProjTable);
                    ADVUpgradeProjScheduler.ScheduleDataTransfer(ADVUpgradeProjTable);
                end;
            }
            action("ShowListPage")
            {
                ApplicationArea = All;
                Caption = 'Show Records';
                Image = ListPage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Scope = "Repeater";
                ToolTip = 'Show the default list page for the current applicaton table.';

                trigger OnAction()
                var
                    PageMgt: Codeunit "Page Management";
                    RecRef: RecordRef;
                begin
                    RecRef.Open("App Table Id");
                    PageMgt.PageRun(RecRef);
                end;
            }

        }
    }
    trigger OnAfterGetRecord()
    var
        ADVUpgradeProjRecCount: Codeunit "Upgrade Project Rec. Count";
    begin
        UpgradeTableRecordCount := ADVUpgradeProjRecCount.GetUpgRecordCount("Upgrade Table Id");
    end;

    var
        UpgradeTableRecordCount: Integer;
}
