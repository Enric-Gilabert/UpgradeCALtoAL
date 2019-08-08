codeunit 60652 "Upgrade Project Rec. Count"
{
    trigger OnRun()
    begin

    end;

    procedure GetUpgRecordCount(TableId: Integer): Integer
    var
        RecRef: RecordRef;
    begin
        if TableId = 0 then exit(0);
        RecRef.Open(TableId);
        exit(RecRef.Count());
    end;

}