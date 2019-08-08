codeunit 60660 "Upgrade Project Scheduler"
{
    trigger OnRun()
    begin

    end;

    procedure ScheduleDataTransfer(var ADVUpgradeProjTable: Record "Upgrade Project Table")
    begin
        with ADVUpgradeProjTable do begin
            FindSet();
            repeat
                ScheduleDataTransferForTable(ADVUpgradeProjTable);
            until Next() = 0;
        end;
        Message(DataUpgradeScheduledMsg);
    end;

    local procedure ScheduleDataTransferForTable(ADVUpgradeProjTable: Record "Upgrade Project Table")
    begin
        ScheduleJobQueueEntry(Codeunit::"Upgrade Project Data Trans", ADVUpgradeProjTable.RecordId(), 10);
    end;

    local procedure ScheduleJobQueueEntry(CodeunitId: Integer; RelatedRecordId: RecordID; SecondsDelay: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntryExists(CodeunitId, RelatedRecordId) then exit;
        JobQueueEntry.Init();
        JobQueueEntry."Earliest Start Date/Time" := CurrentDateTime() + (SecondsDelay * 1000);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CodeunitId;
        JobQueueEntry."Record ID to Process" := RelatedRecordId;
        JobQueueEntry."Run in User Session" := false;
        JobQueueEntry.Priority := 1000;
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure JobQueueEntryExists(CodeunitId: Integer; RelatedRecordId: RecordID): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CodeunitId);
        JobQueueEntry.SetRange("Record ID to Process", RelatedRecordId);
        exit(not JobQueueEntry.IsEmpty());
    end;

    var
        DataUpgradeScheduledMsg: Label 'Data Upgrade has been scheduled.';
}