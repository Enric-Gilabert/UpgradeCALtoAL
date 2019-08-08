codeunit 60651 "Upgrade Project Table Mgt."
{
    trigger OnRun()
    begin

    end;

    procedure InitTableList(UpgradeProject: Record "Upgrade Project")
    var
        NAVAppObjMetadata: Record "NAV App Object Metadata";
        TempBlob: Record TempBlob;
    begin
        with NAVAppObjMetadata do begin
            SetRange("Object Type", "Object Type"::Table);
            SetRange("App Package ID", UpgradeProject."App Package Id");
            if FindSet() then
                repeat
                    InsertAppTable(UpgradeProject, "Object ID", TempBlob);
                until Next() = 0;

            SetRange("Object Type", "Object Type"::TableExtension);
            SetRange("App Package ID", UpgradeProject."App Package Id");
            SetAutoCalcFields("User AL Code", Metadata);
            if FindSet() then
                repeat
                    TempBlob.Blob := Metadata;
                    if "User AL Code".HasValue() then
                        InsertAppTable(UpgradeProject, FindStandardTableId(FindStandardTableName(NAVAppObjMetadata)), TempBlob);
                until Next() = 0;
        end;
    end;

    local procedure FindStandardTableName(NAVAppObjMetadata: Record "NAV App Object Metadata"): Text
    var
        TempBlob: Record Tempblob;
        TableExtensionDefinition: Text;
        TableNamePos: Integer;
    begin
        with NAVAppObjMetadata do begin
            TempBlob.Blob := "User AL Code";
            TableExtensionDefinition := TempBlob.ReadTextLine();
            TableNamePos := TableExtensionDefinition.IndexOf(' extends ');
            exit(DelChr(DelChr(TableExtensionDefinition.Substring(TableNamePos + 9), '<', '"'), '>', '"'))
        end;

    end;

    local procedure FindStandardTableId(StandardTableName: Text): Integer
    var
        AllObj: Record AllObj;
    begin
        with AllObj do begin
            SetRange("Object Type", "Object Type"::Table);
            SetRange("Object Name", StandardTableName);
            if not FindFirst() then begin
                SetRange("Object Name");
                SetFilter("Object ID", StandardTableName);
                if not FindFirst() then
                    Error(TableNotFoundErr, StandardTableName, TableCaption());
            end;
            exit("Object ID");
        end;
    end;

    local procedure InsertAppTable(UpgradeProject: Record "Upgrade Project"; AppTableId: Integer; TempBlob: Record TempBlob)
    var
        ADVUpgradeProjTable: Record "Upgrade Project Table";
    begin
        with ADVUpgradeProjTable do begin
            Init();
            "App Package Id" := UpgradeProject."App Package Id";
            "Table Extension Metadata" := TempBlob.Blob;
            Validate("App Table Id", AppTableId);
            Validate("Upgrade Table Id", FindUPGTable(AppTableId, "App Table Name"));
            OnBeforeInsertAppTable(ADVUpgradeProjTable);
            Insert(true);
        end;
    end;

    local procedure FindUPGTable(AppTableId: Integer; AppTableName: Text) UpgTableId: Integer
    var
        AllObj: Record AllObj;
    begin
        with AllObj do begin
            SetRange("Object Type", "Object Type"::Table);
            SetFilter("Object Name", StrSubstNo('UPG %1%2*', AppTableId, CopyStr(AppTableName, 1, 3)));
            if FindFirst() then
                UpgTableId := "Object ID";
        end;
    end;

    [IntegrationEvent(false, false)]

    local procedure OnBeforeInsertAppTable(var ADVUpgradeProjTable: Record "Upgrade Project Table")
    begin

    end;

    var
        TableNotFoundErr: Label 'Table %1 not found in %2';
}