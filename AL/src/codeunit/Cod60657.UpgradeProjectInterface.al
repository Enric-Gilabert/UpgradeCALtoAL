codeunit 60657 "Upgrade Project Interface"
{
    TableNo = "NAV App Installed App";

    trigger OnRun()
    begin
        if UpgradeProjectDefinitionsExist("App ID") then
            ExecuteDataUpgrade();
    end;

    local procedure UpgradeProjectDefinitionsExist(AppId: Guid): Boolean
    begin
        with ADVUpgradeProj do
            exit(Get(AppId));
    end;

    local procedure ExecuteDataUpgrade()
    var
        ADVCurrentUpgradeProjTable: Record "Upgrade Project Table";
        ADVUpgradeProjDataTrans: Codeunit "Upgrade Project Data Trans";
    begin
        with ADVUpgradeProjTable do begin
            SetRange("App Package ID", ADVUpgradeProj."App Package Id");
            if FindSet() then
                repeat
                    if TableExists("Upgrade Table Id") then begin
                        ADVCurrentUpgradeProjTable := ADVUpgradeProjTable;
                        ADVCurrentUpgradeProjTable.SetRecFilter();
                        ADVUpgradeProjDataTrans.ExecuteDataTransfer(ADVCurrentUpgradeProjTable);
                    end;
                until Next() = 0;
        end;
    end;

    local procedure TableExists(TableID: Integer): Boolean
    var
        AllObj: Record AllObj;
    begin
        with AllObj do begin
            SetRange("Object Type", "Object Type"::"Table");
            SetRange("Object ID", TableID);
            exit(not IsEmpty());
        end;
    end;

    var
        ADVUpgradeProj: Record "Upgrade Project";
        ADVUpgradeProjTable: Record "Upgrade Project Table";

}