codeunit 60656 "Upgrade Project Data Trans"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ADVUpgradeProjTable: Record "Upgrade Project Table";
    begin
        ADVUpgradeProjTable.Get("Record ID to Process");
        ExecuteDataTransferForTable(ADVUpgradeProjTable);
    end;

    procedure ExecuteDataTransfer(var ADVUpgradeProjTable: Record "Upgrade Project Table")

    begin
        Window.Open(DialogMsg + '\\@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        with ADVUpgradeProjTable do begin
            Total := Count();
            SetAutoCalcFields("App Table Name");
            FindSet();
            repeat
                Counter += 1;
                Window.Update(1, "App Table Name");
                Window.Update(2, Round(Counter / Total * 10000, 1));
                ExecuteDataTransferForTable(ADVUpgradeProjTable);
            until Next() = 0;
        end;
        Window.Close();
    end;

    local procedure ExecuteDataTransferForTable(ADVUpgradeProjTable: Record "Upgrade Project Table")
    begin
        with ADVUpgradeProjTable do begin
            case "Data Upgrade Method" of
                "Data Upgrade Method"::Copy:
                    CopyData(ADVUpgradeProjTable);
                "Data Upgrade Method"::Move:
                    MoveData(ADVUpgradeProjTable);
            end;
            LogActivity(ADVUpgradeProjTable, GetExecutionContext());
        end;
    end;

    local procedure CopyData(ADVUpgradeProjTable: Record "Upgrade Project Table")
    var
        SrcRecRef: RecordRef;
        DestRecRef: RecordRef;
    begin
        InitializeReferences(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
        if SrcRecRef.FindSet() then
            repeat
                PopulatePrimaryKey(ADVUpgradeProjTable."App Package Id", SrcRecRef, DestRecRef);
                DestRecRef.Find();
                CopyFields(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
                OnBeforeModify(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
                DestRecRef.Modify();
            until SrcRecRef.Next() = 0;

    end;

    local procedure MoveData(ADVUpgradeProjTable: Record "Upgrade Project Table")
    var

        SrcRecRef: RecordRef;
        DestRecRef: RecordRef;
        Update: Boolean;
    begin
        InitializeReferences(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
        if SrcRecRef.FindSet() then
            repeat
                PopulatePrimaryKey(ADVUpgradeProjTable."App Package Id", SrcRecRef, DestRecRef);
                Update := DestRecRef.Find();
                CopyFields(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
                if Update then begin
                    OnBeforeModify(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
                    DestRecRef.Modify()
                end else begin
                    OnBeforeInsert(ADVUpgradeProjTable, SrcRecRef, DestRecRef);
                    DestRecRef.Insert();
                end;
            until SrcRecRef.Next() = 0;
        SrcRecRef.DeleteAll();
    end;

    local procedure InitializeReferences(ADVUpgradeProjTable: Record "Upgrade Project Table"; var SrcRecRef: RecordRef; var DestRecRef: RecordRef)
    begin
        with ADVUpgradeProjTable do begin
            SrcRecRef.Open("Upgrade Table Id");
            DestRecRef.Open("App Table Id");
        end;
    end;

    local procedure CopyFields(ADVUpgradeProjTable: Record "Upgrade Project Table"; SrcRecRef: RecordRef; var DestRecRef: RecordRef)
    var
        ADVUpgradeProjectField: Record "Upgrade Project Field";
        SrcFldRef: FieldRef;
        DestFldRef: FieldRef;
    begin
        FilterFields(ADVUpgradeProjTable, ADVUpgradeProjectField);
        with ADVUpgradeProjectField do begin
            FindSet();
            repeat
                SrcFldRef := SrcRecRef.Field("Upgrade Field ID");
                DestFldRef := DestRecRef.Field("App Field ID");
                CopyValue("App Package Id", "App Table Id", SrcFldRef, DestFldRef);
            until Next() = 0;
        end;
    end;

    local procedure FilterFields(ADVUpgradeProjTable: Record "Upgrade Project Table"; var ADVUpgradeProjectField: Record "Upgrade Project Field")
    begin
        ADVUpgradeProjectField.SetRange("App Package Id", ADVUpgradeProjTable."App Package Id");
        ADVUpgradeProjectField.SetRange("App Table Id", ADVUpgradeProjTable."App Table Id");
    end;

    local procedure PopulatePrimaryKey(AppPackageId: Guid; SrcRecRef: RecordRef; var DestRecRef: RecordRef)
    var
        SrcFldRef: FieldRef;
        DestFldRef: FieldRef;
        PrimaryKeyRef: KeyRef;
        FieldIndex: Integer;
    begin
        PrimaryKeyRef := DestRecRef.KeyIndex(1);
        for FieldIndex := 1 to PrimaryKeyRef.FieldCount() do begin
            DestFldRef := PrimaryKeyRef.FieldIndex(FieldIndex);
            SrcFldRef := SrcRecRef.Field(DestFldRef.Number());
            CopyValue(AppPackageId, DestRecRef.Number(), SrcFldRef, DestFldRef);
        end;
    end;

    local procedure CopyValue(AppPackageId: Guid; AppTableId: Integer; SrcFldRef: FieldRef; var DestFldRef: FieldRef)
    var
        ADVUpgradeProjectField: Record "Upgrade Project Field";
        TempBlog: Record TempBlob;
        FieldValue: Text;
    begin
        with ADVUpgradeProjectField do begin
            Get(AppPackageId, AppTableId, DestFldRef.Number());
            if UpperCase(Format(SrcFldRef.Type())) = 'BLOB' then
                SrcFldRef.CalcField();
            if GetWarning() <> '' then exit;
            if "Transformation Rule" <> '' then begin
                if UpperCase(Format(SrcFldRef.Type())) = 'BLOB' then begin
                    TempBlog.Blob := SrcFldRef.Value();
                    FieldValue := TempBlog.ReadAsText('', TextEncoding::Windows);
                end else
                    FieldValue := Format(SrcFldRef.Value(), 0, 9);
                ApplyTransformationRule("Transformation Rule", FieldValue);
                EvaluateFieldValue(FieldValue, DestFldRef);
            end else
                DestFldRef.Value(SrcFldRef.Value());
        end;
        OnAfterCopyValue(AppPackageId, AppTableId, SrcFldRef, DestFldRef);
    end;

    local procedure ApplyTransformationRule(TransformationRuleCode: Code[20]; var FieldValue: Text)
    var
        TransformationRule: Record "Transformation Rule";
    begin
        TransformationRule.Get(TransformationRuleCode);
        FieldValue := TransformationRule.TransformText(FieldValue);
    end;

    local procedure EvaluateFieldValue(FieldValue: Text; var DestFldRef: FieldRef)
    var
        TempBlob: Record TempBlob;
        DateformulaType: DateFormula;
        RecordIDType: RecordID;
        BooleanType: Boolean;
        DecimalType: Decimal;
        IntegerType: Integer;
        DateType: Date;
        DateTimeType: DateTime;
        OptionType: Option;
        BigIntegerType: BigInteger;
        TimeType: Time;
        GuidType: Guid;
    begin
        case UpperCase(Format(DestFldRef.Type())) of
            'TEXT':
                DestFldRef.Value := FieldValue;
            'DATETIME':
                begin
                    if FieldValue <> '' then
                        Evaluate(DateTimeType, FieldValue, 9)
                    else
                        DateTimeType := 0DT;
                    DestFldRef.Value := DateTimeType;
                end;
            'DATE':
                begin
                    if FieldValue <> '' then
                        Evaluate(DateType, FieldValue, 9)
                    else
                        DateType := 0D;
                    DestFldRef.Value := DateType;
                end;
            'TIME':
                begin
                    if FieldValue <> '' then
                        Evaluate(TimeType, FieldValue, 9)
                    else
                        TimeType := 0T;
                    DestFldRef.Value := TimeType;
                end;
            'DATEFORMULA':
                begin
                    if FieldValue <> '' then
                        Evaluate(DateformulaType, FieldValue, 9)
                    else
                        Clear(DateformulaType);
                    DestFldRef.Value := DateformulaType;
                end;
            'DECIMAL':
                begin
                    if FieldValue <> '' then
                        Evaluate(DecimalType, FieldValue, 9)
                    else
                        DecimalType := 0;
                    DestFldRef.Value := DecimalType;
                end;
            'BOOLEAN':
                begin
                    if FieldValue <> '' then
                        Evaluate(BooleanType, FieldValue, 9)
                    else
                        BooleanType := false;
                    DestFldRef.Value := BooleanType;
                end;
            'CODE':
                DestFldRef.Value := FieldValue;
            'OPTION':
                begin
                    if FieldValue <> '' then
                        Evaluate(OptionType, FieldValue, 9)
                    else
                        OptionType := 0;
                    DestFldRef.Value := OptionType;
                end;
            'INTEGER':
                begin
                    if FieldValue <> '' then
                        Evaluate(IntegerType, FieldValue, 9)
                    else
                        IntegerType := 0;
                    DestFldRef.Value := IntegerType;
                end;
            'BIGINTEGER':
                begin
                    if FieldValue <> '' then
                        Evaluate(BigIntegerType, FieldValue, 9)
                    else
                        IntegerType := 0;
                    DestFldRef.Value := BigIntegerType;
                end;
            'BLOB':
                begin
                    TempBlob.WriteAsText(FieldValue, TextEncoding::Windows);
                    DestFldRef.Value(TempBlob.Blob);
                end;
            'GUID':
                begin
                    if FieldValue <> '' then
                        Evaluate(GuidType, FieldValue, 9)
                    else
                        Clear(GuidType);
                    DestFldRef.Value := GuidType;
                end;
            'RECORDID':
                begin
                    if FieldValue <> '' then
                        Evaluate(RecordIDType, FieldValue, 9)
                    else
                        Clear(RecordIDType);
                    DestFldRef.Value := RecordIDType;
                end;
            else
                Error(FieldTypeNotSupportedErr, UpperCase(Format(DestFldRef.Type())));

        end;
    end;

    local procedure LogActivity(ADVUpgradeProjTable: Record "Upgrade Project Table"; Context: Text[30])
    var
        ActivityLog: Record "Activity Log";
        Status: Option Success,Failed;
    begin
        if ADVUpgradeProject."App Package Id" <> ADVUpgradeProjTable."App Package Id" then begin
            ADVUpgradeProject.SetRange("App Package Id", ADVUpgradeProjTable."App Package Id");
            ADVUpgradeProject.FindFirst();
        end;
        ActivityLog.LogActivity(
            ADVUpgradeProject,
            Status::Success,
            Context,
            StrSubstNo('%1', ADVUpgradeProjTable."Data Upgrade Method"),
            StrSubstNo('%1 (%2)', ADVUpgradeProjTable."App Table Name", ADVUpgradeProjTable."App Table Id"));
    end;

    local procedure GetExecutionContext(): Text[30]
    var
        SessionContext: ExecutionContext;
    begin
        SessionContext := Session.GetCurrentModuleExecutionContext();
        case SessionContext of
            SessionContext::Install:
                exit(CopyStr(InstallationMsg, 1, 30));
            SessionContext::Upgrade:
                exit(CopyStr(UpgradeMsg, 1, 30));
            SessionContext::Normal:
                exit(CopyStr(UserContextMsg, 1, 30));
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(ADVUpgradeProjTable: Record "Upgrade Project Table"; SrcRecRef: RecordRef; var DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsert(ADVUpgradeProjTable: Record "Upgrade Project Table"; SrcRecRef: RecordRef; var DestRecRef: RecordRef)
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyValue(AppPackageId: Guid; AppTableId: Integer; SrcFldRef: FieldRef; var DestFldRef: FieldRef)
    begin

    end;


    var
        ADVUpgradeProject: Record "Upgrade Project";
        DialogMsg: Label 'Executing Data Upgrade for table: #1##############################';
        FieldTypeNotSupportedErr: Label 'Field Type %1 not supported!';
        InstallationMsg: Label 'App Installation';
        UpgradeMsg: Label 'App Upgrade';
        UserContextMsg: Label 'Started by user';
        Window: Dialog;
        Total: Integer;
        Counter: Integer;
}