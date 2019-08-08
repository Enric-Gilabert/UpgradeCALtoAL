codeunit 68241 "To 2013 Code Generator"
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
          '    Date=11.02.14;' + CrLf +
          '    Time=12:11:11;' + CrLf +
          '    Version List=UPGW18.00.00;' + CrLf +
          '  }' + CrLf +
          '  PROPERTIES' + CrLf +
          '  {' + CrLf;
        if not TableProperty."Data Per Company" then
            TableText += '    DataPerCompany=No' + CrLf;
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

    procedure DeleteDiscontinedTable(TableNo: Integer) DeleteTableText: Text
    begin
        DeleteTableText := StrSubstNo('DeleteTable(%1);', TableNo) + CrLf;
    end;

    procedure MarkDiscontinedTable(TableNo: Integer) MarkTableText: Text
    begin
        MarkTableText := StrSubstNo('MarkTable(%1);', TableNo) + CrLf;
    end;

    procedure FunctionPrefix(Index: Integer) Prefix: Text
    begin
        Prefix := SelectStr(Index, 'Ignore,Copy,Move,Force,Check,Use Source Id');
    end;

    procedure CodeunitHeaderBegin(CodeunitNo: Integer; CodeunitName: Text[30]; CallFromCodeunitNo: Integer) CodeunitText: Text
    begin
        CodeunitText :=
          StrSubstNo('OBJECT Codeunit %1 %2', CodeunitNo, CodeunitName) + CrLf +
          '{' + CrLf +
          '  OBJECT-PROPERTIES' + CrLf +
          '  {' + CrLf +
          '    Date=11.02.14;' + CrLf +
          '    Time=12:11:11;' + CrLf +
          '    Version List=UPGW18.00.00;' + CrLf +
          '  }' + CrLf +
          '  PROPERTIES' + CrLf +
          '  {' + CrLf +
          '  }' + CrLf +
          '  CODE' + CrLf +
          '  {' + CrLf +
          '    VAR' + CrLf +
          '      TimeLog@1000 : Record 104001;' + CrLf +
          '' + CrLf +
          '    PROCEDURE Upgrade@1(VAR StateIndicator@1000 : Record 104037);' + CrLf +
          '    BEGIN' + CrLf +
          StrSubstNo('      // Call this function from the top of the Upgrade trigger in Codeunit ID %1', CallFromCodeunitNo) + CrLf;
    end;

    procedure CodeunitCallProcedure(ProcedureName: Text) CodeunitText: Text
    begin
        CodeunitText := StrSubstNo('      %1(StateIndicator);', ProcedureName) + CrLf;
    end;

    procedure CodeunitHeaderEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '    END;' + CrLf +
          '' + CrLf;
    end;

    procedure CodeunitProcedureFrameBegin(ProcedureName: Text; Id: Integer; LoopTableNo: Integer; LoopTableName: Text; SecondTableNo: Integer; SecondTableName: Text) CodeunitText: Text
    begin
        CodeunitText :=
          StrSubstNo('    LOCAL PROCEDURE %1@%2(VAR StateIndicator@1002 : Record 104037);', ProcedureName, Id) + CrLf +
          '    VAR' + CrLf +
          StrSubstNo('      %1@1000 : Record %2;', LoopTableName, LoopTableNo) + CrLf;
        if SecondTableNo > 0 then
            CodeunitText +=
              StrSubstNo('      %1@1001 : Record %2;', SecondTableName, SecondTableNo) + CrLf;
        CodeunitText +=
          '    BEGIN' + CrLf +
          StrSubstNo('      WITH %1 DO', LoopTableName) + CrLf +
          '        IF StateIndicator.UpdateTable(TABLENAME) THEN BEGIN' + CrLf +
          '          TimeLog.TimeLogInsert(TimeLog,TABLENAME,TRUE);' + CrLf;
    end;

    procedure CodeunitProcedureLoopBegin() CodeunitText: Text
    begin
        CodeunitText :=
          '          IF FINDSET(TRUE) THEN' + CrLf +
          '            REPEAT' + CrLf +
          '              StateIndicator.Update;' + CrLf;
    end;

    procedure CodeunitProcedureLoopGetTable(TableName: Text; PrimaryKeyList: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := StrSubstNo('              GET(%1);', PrimaryKeyList) + CrLf
        else
            CodeunitText := StrSubstNo('              "%1".GET(%2);', TableName, PrimaryKeyList) + CrLf;
    end;

    procedure CodeunitProcedureLoopInitTable(TableName: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := '              INIT;' + CrLf
        else
            CodeunitText := StrSubstNo('              "%1".INIT;', TableName) + CrLf;
    end;

    procedure CodeunitProcedureLoopCalcfields(FieldName: Text) CodeunitText: Text
    begin
        CodeunitText := StrSubstNo('              CALCFIELDS("%1");', FieldName) + CrLf;
    end;

    procedure CodeunitProcedureLoopTransferfields(LoopTableName: Text; SecondTableName: Text) CodeunitText: Text
    begin
        CodeunitText :=
          StrSubstNo('              %1.INIT;', SecondTableName) + CrLf +
          StrSubstNo('              %1.TRANSFERFIELDS(%2);', SecondTableName, LoopTableName) + CrLf +
          StrSubstNo('              %1.INSERT;', SecondTableName) + CrLf;
    end;

    procedure CodeunitProcedureLoopClearfield(FieldName: Text; FieldType: Text) CodeunitText: Text
    begin
        case true of
            FieldType in ['Decimal', 'Integer', 'Option', 'BigInteger', 'Duration']:
                CodeunitText := StrSubstNo('              "%1" := 0;', FieldName) + CrLf;
            FieldType in ['Boolean']:
                CodeunitText := StrSubstNo('              "%1" := FALSE;', FieldName) + CrLf;
            FieldType in ['Date']:
                CodeunitText := StrSubstNo('              "%1" := 0D;', FieldName) + CrLf;
            FieldType in ['Time']:
                CodeunitText := StrSubstNo('              "%1" := 0T;', FieldName) + CrLf;
            FieldType in ['DateTime']:
                CodeunitText := StrSubstNo('              "%1" := 0DT;', FieldName) + CrLf;
            FieldType in ['DateFormula', 'BLOB', 'GUID', 'Binary', 'RecordID', 'TableFilter']:
                CodeunitText := StrSubstNo('              CLEAR("%1");', FieldName) + CrLf;
            else
                CodeunitText := StrSubstNo('              "%1" := '''';', FieldName) + CrLf;
        end;
    end;

    procedure CodeunitProcedureLoopCopyfield(DestinationTableName: Text; DestinationFieldName: Text; SourceFieldName: Text) CodeunitText: Text
    begin
        CodeunitText := StrSubstNo('              "%1"."%2" := "%3";', DestinationTableName, DestinationFieldName, SourceFieldName) + CrLf;
    end;

    procedure CodeunitProcedureLoopNewfield(DestinationTableName: Text; DestinationFieldName: Text) CodeunitText: Text
    begin
        CodeunitText := StrSubstNo('              //"%1"."%2" := ;', DestinationTableName, DestinationFieldName) + CrLf;
    end;

    procedure CodeunitProcedureLoopModifyTable(TableName: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := '              MODIFY;' + CrLf
        else
            CodeunitText := StrSubstNo('              "%1".MODIFY;', TableName) + CrLf;
    end;

    procedure CodeunitProcedureLoopInsertTable(TableName: Text) CodeunitText: Text
    begin
        if TableName = '' then
            CodeunitText := '              INSERT;' + CrLf
        else
            CodeunitText := StrSubstNo('              "%1".INSERT;', TableName) + CrLf;
    end;

    procedure CodeunitProcedureLoopEnd() CodeunitText: Text
    begin
        CodeunitText := '            UNTIL NEXT = 0;' + CrLf;
    end;

    procedure CodeunitProcedureForceBegin() CodeunitText: Text
    begin
        CodeunitText :=
          '          IF FINDFIRST THEN BEGIN' + CrLf +
          '            StateIndicator.Update;' + CrLf;
    end;

    procedure CodeunitProcedureForceEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '          END;' + CrLf;
    end;

    procedure CodeunitProcedureClearField(FieldName: Text; FieldType: Text) CodeunitText: Text
    begin
        case true of
            FieldType in ['Decimal', 'Integer', 'Option', 'BigInteger', 'Duration']:
                CodeunitText := StrSubstNo('            MODIFYALL("%1",0);', FieldName) + CrLf;
            FieldType in ['Boolean']:
                CodeunitText := StrSubstNo('            MODIFYALL("%1",FALSE);', FieldName) + CrLf;
            FieldType in ['Date']:
                CodeunitText := StrSubstNo('            MODIFYALL("%1",0D);', FieldName) + CrLf;
            FieldType in ['Time']:
                CodeunitText := StrSubstNo('            MODIFYALL("%1",0T);', FieldName) + CrLf;
            FieldType in ['DateTime']:
                CodeunitText := StrSubstNo('            MODIFYALL("%1",0DT);', FieldName) + CrLf;
            else // Text, Code
                CodeunitText := StrSubstNo('            MODIFYALL("%1",'''');', FieldName) + CrLf;
        end;
    end;

    procedure CodeunitProcedureDeleteAll() CodeunitText: Text
    begin
        CodeunitText := '            DELETEALL;' + CrLf;
    end;

    procedure CodeunitProcedureFrameEnd() CodeunitText: Text
    begin
        CodeunitText :=
          '          TimeLog.TimeLogInsert(TimeLog,TABLENAME,FALSE);' + CrLf +
          '          StateIndicator.EndUpdateTable(TABLENAME);' + CrLf +
          '        END;' + CrLf +
          '    END;' + CrLf +
          '' + CrLf;
    end;

    procedure CodeunitFooter() CodeunitText: Text
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
            65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
            95, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114,
            115, 116, 117, 118, 119, 120, 121, 122
          ]);
    end;
}

