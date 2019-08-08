codeunit 60650 "Upgrade Project Field Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure InitTableFields(UpgradeTable: Record "Upgrade Project Table")
    var
        Fld: Record Field;
    begin
        if VerifyUpgradeTable(UpgradeTable) then
            with Fld do begin
                SetRange(TableNo, UpgradeTable."Upgrade Table Id");
                SetRange(Enabled, true);
                SetRange(Class, Class::Normal);
                if FindSet() then
                    repeat
                        InsertUpgradeField(UpgradeTable, "No.");
                    until Next() = 0;
            end;
    end;

    local procedure VerifyUpgradeTable(UpgradeTable: Record "Upgrade Project Table") Passed: Boolean
    begin
        UpgradeTable.TestField("App Package Id");
        UpgradeTable.TestField("App Table Id");
        Passed := (UpgradeTable."Upgrade Table Id" <> 0);
        OnAfterVerifyUpgradeTable(UpgradeTable, Passed);
    end;

    local procedure InsertUpgradeField(UpgradeTable: Record "Upgrade Project Table"; FieldId: Integer)
    var
        ADVUpgradeProjField: Record "Upgrade Project Field";
    begin
        with ADVUpgradeProjField do begin
            Init();
            "App Package Id" := UpgradeTable."App Package Id";
            "App Table Id" := UpgradeTable."App Table Id";
            "App Field ID" := FieldId;
            "Upgrade Table Id" := UpgradeTable."Upgrade Table Id";
            "Upgrade Field ID" := FieldId;
            OnBeforeInsertAppField(ADVUpgradeProjField);
            Insert();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAppField(var ADVUpgradeProjField: Record "Upgrade Project Field")
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterVerifyUpgradeTable(UpgradeTable: Record "Upgrade Project Table"; var Passed: Boolean)
    begin

    end;
}