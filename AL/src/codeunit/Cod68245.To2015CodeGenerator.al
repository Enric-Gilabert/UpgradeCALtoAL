codeunit 68245 "To 2015 Code Generator"
{
    // ©Dynamics.is


    trigger OnRun()
    begin
    end;

    var
        CrLf: Text[2];

    procedure Initialize()
    begin
        CrLf[1] := 13;
        CrLf[2] := 10;
    end;

    procedure CommentLine(CommentText: Text) CommentLineText: Text
    begin
        CommentLineText := '// ' + CommentText + CrLf;
    end;

    procedure TableHeader(TableProperty: Record "Table Version Field"; TableNo: Integer; TableName: Text) TableText: Text
    begin
        TableText :=
          StrSubstNo('OBJECT Table %1 %2', TableNo, TableName) + CrLf +
          '{' + CrLf +
          '  OBJECT-PROPERTIES' + CrLf +
          '  {' + CrLf +
          '    Date=04.08.14;' + CrLf +
          '    Time=12:00:00;' + CrLf +
          '    Version List=UPGW18.00.00;' + CrLf +
          '  }' + CrLf +
          '  PROPERTIES' + CrLf +
          '  {' + CrLf;

        if not TableProperty."Data Per Company" then
            TableText +=
              '    DataPerCompany=No' + CrLf;

        TableText +=
          '  }' + CrLf +
          '  FIELDS' + CrLf +
          '  {' + CrLf;
    end;

    procedure FieldLine(FieldProperty: Record "Table Version Field") FieldText: Text
    begin
        FieldText := '    { ' + Format(FieldProperty."Field No.", 0, 9);
        while StrLen(FieldText) < 10 do
            FieldText += ' ';
        FieldText += ';';
        while StrLen(FieldText) < 14 do
            FieldText += ' ';
        while StrLen(FieldProperty."Field Name") < 20 do
            FieldProperty."Field Name" += ' ';
        FieldText += ';' + FieldProperty."Field Name" + ';' + FieldProperty."Field Type";
        while StrLen(FieldText) < 50 do
            FieldText += ' ';
        if FieldProperty.GetOptionString() <> '' then
            FieldText += ';OptionString=[' + FieldProperty.GetOptionString() + ']'
        else
            if FieldProperty."Auto Increment" then
                FieldText += ';AutoIncrement=Yes'
            else
                if FieldProperty."SQL Data Type" <> '' then
                    FieldText += ';SQL Data Type=' + FieldProperty."SQL Data Type"
                else
                    if FieldProperty.Compressed and (FieldProperty.SubType > 0) then
                        FieldText +=
                          ';Compressed=Yes;' + CrLf +
                          StrSubstNo('SubType=%1 ', Format(FieldProperty.SubType))
                    else begin
                        if FieldProperty.Compressed then
                            FieldText += ';Compressed=Yes';
                        if FieldProperty.SubType > 0 then
                            FieldText += StrSubstNo(';SubType=%1', Format(FieldProperty.SubType));
                    end;


        FieldText += ' }' + CrLf;
    end;

    procedure TableKeys(VersionCode: Code[20]; TableNo: Integer) KeysText: Text
    var
        TableKeys: Record "Table Version Primary Key";
    begin
        KeysText :=
          '  }' + CrLf +
          '  KEYS' + CrLf +
          '  {' + CrLf +
          '    {    ;';

        with TableKeys do begin
            SetRange("Table Version Code", VersionCode);
            SetRange("Table No.", TableNo);
            SetAutoCalcFields("Field Name");
            FindSet();
            repeat
                KeysText += "Field Name" + ',';
            until Next() = 0;
        end;

        KeysText := DelChr(KeysText, '>', ',');
        while StrLen(KeysText) < 50 do
            KeysText += ' ';
        KeysText +=
          ';Clustered=Yes }' + CrLf +
          '  }' + CrLf;
    end;

    procedure TableFooter() TableText: Text
    begin
        TableText :=
          '  FIELDGROUPS' + CrLf +
          '  {' + CrLf +
          '  }' + CrLf +
          '  CODE' + CrLf +
          '  {' + CrLf +
          '' + CrLf +
          '    BEGIN' + CrLf +
          '      {' + CrLf +
          '        ©Dynamics.is Upgrade Table' + CrLf +
          '      }' + CrLf +
          '    END.' + CrLf +
          '  }' + CrLf +
          '}' + CrLf +
          '' + CrLf;
    end;

    procedure FunctionPrefix(Index: Integer) Prefix: Text
    begin
        Prefix := SelectStr(Index, 'Ignore,Copy,Move,Force,Check,Use Source Id');
    end;

    procedure CodeunitBegin(CodeunitNo: Integer; CodeunitName: Text[30]) CodeunitText: Text
    begin
        CodeunitText :=
          StrSubstNo('OBJECT Codeunit %1 %2', CodeunitNo, CodeunitName) + CrLf +
          '{' + CrLf +
          '  OBJECT-PROPERTIES' + CrLf +
          '  {' + CrLf +
          '    Date=04.08.14;' + CrLf +
          '    Time=12:00:00;' + CrLf +
          '    Version List=UPGW18.00.00;' + CrLf +
          '  }' + CrLf +
          '  PROPERTIES' + CrLf +
          '  {' + CrLf +
          '    Subtype=Upgrade;' + CrLf +
          '    OnRun=BEGIN' + CrLf +
          '          END;' + CrLf +
          '' + CrLf +
          '  }' + CrLf +
          '  CODE' + CrLf +
          '  {' + CrLf +
          '    VAR' + CrLf +
          '      DividerTxt@1000 : TextConst ''ENU=..'';' + CrLf +
          '      DataUpgradeMgt@1001 : Codeunit 9900;' + CrLf +
          '      DataTypeMgt@1002 : Codeunit 701;' + CrLf +
          '' + CrLf +
          '    [CheckPrecondition]' + CrLf +
          '    PROCEDURE CheckPreconditions@2();' + CrLf +
          '    BEGIN' + CrLf +
          '    END;' + CrLf +
          '' + CrLf;
    end;

    procedure TableSyncSetupBegin() CodeunitText: Text
    begin
        CodeunitText :=
          '    [TableSyncSetup]' + CrLf +
          '    PROCEDURE GetTableSyncSetup@3(VAR TableSynchSetup@1000 : Record 2000000135);' + CrLf +
          '    BEGIN' + CrLf +
          '      // The purpose of this method is to define how old and new tables will be available for dataupgrade' + CrLf +
          '' + CrLf +
          '      // The method is called at a point in time where schema changes have not yet been synchronized to' + CrLf +
          '      // the database so tables except virtual tables cannot be accessed' + CrLf +
          '' + CrLf +
          '      // TableSynchSetup."Table ID":' + CrLf +
          '      // Id of the table with schema changes (i.e the modified table).' + CrLf +
          '' + CrLf +
          '      // TableSynchSetup."Upgrade Table ID":' + CrLf +
          '      // Id of table where old data will be available in case the selected TableSynchSetup.Mode option is one of Copy or Move , otherwise 0' + CrLf +
          '' + CrLf +
          '      // TableSynchSetup.Mode:' + CrLf +
          '      // An option indicating how the data will be handled during synchronization' + CrLf +
          '      // Check: Synchronize without saving data in the upgrade table, fails if there is data in the modified field/table' + CrLf +
          '      // Copy: Synchronize with saving data in the upgrade table, the modified table contains data in matching fields' + CrLf +
          '      // Move: Synchronize with moving the data in the upgrade table,the changed table is empty; the upgrade logic is handled only by application code' + CrLf +
          '      // Force: Synchronize without saving data in the upgrade table, disregard if there is data in the modified field/table' + CrLf +
          '' + CrLf;
    end;

    procedure TableSyncSetupDefined(SourceTable: Integer; TemporaryTable: Integer; SyncSetupMode: Text) CodeunitText: Text
    begin
        if SyncSetupMode = 'Ignore' then exit;

        CodeunitText := StrSubstNo(
          '      DataUpgradeMgt.SetTableSyncSetup(%1,%2,TableSynchSetup.Mode::%3);', SourceTable, TemporaryTable, SyncSetupMode) + CrLf;
    end;

    procedure TableSyncSetupEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '    END;' + CrLf +
          '' + CrLf;
    end;

    procedure TableUpgradeBegin(ProcedureName: Text; Id: Integer; LoopTableNo: Integer; LoopTableName: Text; SecondTableNo: Integer; SecondTableName: Text) CodeunitText: Text
    begin
        CodeunitText :=
          '    [Upgrade]' + CrLf +
          StrSubstNo('    PROCEDURE %1@%2();', ProcedureName, Id) + CrLf +
          '    VAR' + CrLf +
          StrSubstNo('      %1@1000 : Record %2;', LoopTableName, LoopTableNo) + CrLf;
        if SecondTableNo > 0 then
            if SecondTableName <> '' then
                CodeunitText +=
                  StrSubstNo('      %1@1001 : Record %2;', SecondTableName, SecondTableNo) + CrLf
            else
                CodeunitText +=
                  '      RecRef@1001 : RecordRef;' + CrLf +
                  '      RecVariant@1002 : Variant;' + CrLf;
        CodeunitText +=
          '    BEGIN' + CrLf +
          StrSubstNo('      WITH %1 DO BEGIN', LoopTableName) + CrLf;
    end;

    procedure TableUpgradeLoopBegin(DestinationTableName: Text) CodeunitText: Text
    begin
        if DestinationTableName = '' then
            CodeunitText :=
              '        RecRef.OPEN(<Table No>);' + CrLf;
        CodeunitText +=
          '        IF FINDSET THEN' + CrLf +
          '          REPEAT' + CrLf;
    end;

    procedure TableUpgradeLoopGetTable(TableName: Text; PrimaryKeyList: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := StrSubstNo('            GET(%1);', PrimaryKeyList) + CrLf
        else
            CodeunitText := StrSubstNo('            "%1".GET(%2);', TableName, PrimaryKeyList) + CrLf;
    end;

    procedure TableUpgradeLoopInitTable(TableNo: Integer; TableName: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := '            RecRef.INIT;' + CrLf
        else
            CodeunitText := StrSubstNo('            "%1".INIT;', TableName) + CrLf;
    end;

    procedure TableUpgradeLoopCalcfields(FieldName: Text) CodeunitText: Text
    begin
        CodeunitText := StrSubstNo('            CALCFIELDS("%1");', FieldName) + CrLf;
    end;

    procedure TableUpgradeLoopSetVariant() CodeunitText: Text
    begin
        CodeunitText := '            RecVariant := RecRef;' + CrLf
    end;

    procedure TableUpgradeLoopCopyfield(DestinationTableName: Text; DestinationFieldName: Text; SourceFieldName: Text) CodeunitText: Text
    begin
        if DestinationTableName = '' then
            CodeunitText := StrSubstNo('            DataTypeMgt.SetFieldValue(RecVariant,''%1'',"%1");', SourceFieldName) + CrLf
        else
            CodeunitText := StrSubstNo('            "%1"."%2" := "%3";', DestinationTableName, DestinationFieldName, SourceFieldName) + CrLf;
    end;

    procedure TableUpgradeLoopTransferfields(DestinationTableName: Text; TableName: Text) CodeunitText: Text
    begin
        CodeunitText := StrSubstNo('            "%1".TRANSFERFIELDS("%2");', DestinationTableName, TableName) + CrLf;
    end;

    procedure TableUpgradeLoopGetVariant() CodeunitText: Text
    begin
        CodeunitText := '            RecRef := RecVariant;' + CrLf
    end;

    procedure TableUpgradeLoopNewfield(DestinationTableName: Text; DestinationFieldName: Text) CodeunitText: Text
    begin
        if DestinationTableName <> '' then
            CodeunitText := StrSubstNo('            //"%1"."%2" := ;', DestinationTableName, DestinationFieldName) + CrLf;
    end;

    procedure TableUpgradeLoopModifyTable(TableName: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := '            RecRef.MODIFY;' + CrLf
        else
            CodeunitText := StrSubstNo('            "%1".MODIFY;', TableName) + CrLf;
    end;

    procedure TableUpgradeLoopInsertTable(TableName: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := '            RecRef.INSERT;' + CrLf
        else
            CodeunitText := StrSubstNo('            "%1".INSERT;', TableName) + CrLf;
    end;

    procedure TableUpgradeLoopEnd(DestinationTableName: Text) CodeunitText: Text
    begin
        CodeunitText := '          UNTIL NEXT = 0;' + CrLf;
        if DestinationTableName = '' then
            CodeunitText += '          RecRef.CLOSE;' + CrLf;
    end;

    procedure TableUpgradeDeleteAll() CodeunitText: Text
    begin
        CodeunitText := '          DELETEALL;' + CrLf;
    end;

    procedure TableUpgradeEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '      END;' + CrLf +
          '    END;' + CrLf +
          '' + CrLf;
    end;

    procedure MarkDiscontinuedCodeBegin() CodeunitText: Text
    begin
        CodeunitText :=
          '    [Upgrade]' + CrLf +
          '    PROCEDURE MarkObjectsForDeletion@4000000();' + CrLf +
          '    BEGIN' + CrLf;
    end;

    procedure MarkDiscontinuedTable(TableName: Text) CodeunitText: Text
    begin
        CodeunitText :=
          StrSubstNo('      DataUpgradeMgt.MarkTableForDeletion(DATABASE::"%1");', TableName) + CrLf;
    end;

    procedure MarkDiscontinuedCodeEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '    END;' + CrLf +
          '' + CrLf;
    end;

    procedure CodeunitEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '    BEGIN' + CrLf +
          '      {' + CrLf +
          '        ©Dynamics.is upgrade codeunit' + CrLf +
          '      }' + CrLf +
          '    END.' + CrLf +
          '  }' + CrLf +
          '}' + CrLf +
          '' + CrLf;
    end;

    procedure GetVariableName(TableName: Text) VariableText: Text
    var
        Loop: Integer;
    begin
        for Loop := 1 to StrLen(TableName) do
            if ValidVariableChar(TableName[Loop]) then
                VariableText += CopyStr(TableName, Loop, 1);

        if UpperCase(VariableText) in ['EVENT', 'PROCEDURE'] then
            VariableText := 'Upgr' + VariableText;
    end;

    local procedure ValidVariableChar(Char: Integer): Boolean
    begin
        exit(
         Char in
          [
            48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
            65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
            95, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114,
            115, 116, 117, 118, 119, 120, 121, 122
          ]);
    end;
}

