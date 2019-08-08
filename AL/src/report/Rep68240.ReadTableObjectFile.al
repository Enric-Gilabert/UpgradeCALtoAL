report 68240 "Read Table Object File"
{
    // ©Dynamics.is

    Caption = 'Read Table Object File';
    ProcessingOnly = true;
    ShowPrintStatus = false;
    UseRequestPage = false;

    dataset
    {
        dataitem(ReadFile; "Integer")
        {
            DataItemTableView = SORTING (Number) WHERE (Number = CONST (1));

            trigger OnAfterGetRecord()
            var
                SearchTableVersionField: Record "Table Version Field";
                Line: Text;
                ID: Text;
                LineValue: Text;
                PropertyPos: Integer;
                SeparatorPos: Integer;
                ReadingFields: Boolean;
                ReadingKey: Boolean;
                NewFieldAvailable: Boolean;
                FieldEnabled: Boolean;
                ReadingProperties: Boolean;
                BoolValue: Boolean;
                i: Integer;
            begin
                Window.Open(ReadingTableTxt);
                TempBlob.StartReadingTextLines(TextEncoding::MSDos);
                while TempBlob.MoreTextLines() do begin
                    Line := TempBlob.ReadTextLine();
                    ID := '';
                    case true of
                        ReadingFields and (CopyStr(Line, 1, 5) = '    {'):
                            begin
                                Line := CopyStr(Line, 6);
                                ID := ExtractFirstPartFromString(Line, ';', '');
                                Evaluate(TableVersionField."Field No.", ID);
                                FieldEnabled := ExtractFirstPartFromString(Line, ';', '') = '';
                                if FieldEnabled then begin
                                    TableVersionField."Field Name" := ExtractFirstPartFromString(Line, ';', '');
                                    TableVersionField."Field Type" := ExtractFirstPartFromString(Line, ';', '');
                                    TableVersionField.SetOptionString('');
                                    TableVersionField."Auto Increment" := false;
                                    TableVersionField.SubType := 0;
                                    TableVersionField.Compressed := false;
                                    TableVersionField."SQL Data Type" := '';
                                    if (StrPos(Line, 'FieldClass=FlowField') = 0) and (StrPos(Line, 'FieldClass=FlowFilter') = 0) then begin
                                        TableVersionField.Insert;
                                        NewFieldAvailable := true;
                                    end else
                                        NewFieldAvailable := false;
                                end else
                                    NewFieldAvailable := false;
                                if NewFieldAvailable and (StrPos(Line, 'OptionString=') > 0) then
                                    ReadOptionString(Line);
                                if NewFieldAvailable and (StrPos(Line, 'AutoIncrement=Yes') > 0) then
                                    SetAutoIncrement;
                                if NewFieldAvailable and (StrPos(Line, 'Compressed=') > 0) then
                                    SetCompressed(Line);
                                if NewFieldAvailable and (StrPos(Line, 'SQL Data Type=') > 0) then
                                    SetSqlDataType(Line);
                                if NewFieldAvailable and (StrPos(Line, 'SubType=') > 0) then
                                    SetSubtype(Line);
                            end;
                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'FieldClass=FlowField') > 0):
                            begin
                                TableVersionField.Delete;
                                NewFieldAvailable := false;
                            end;
                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'FieldClass=FlowFilter') > 0):
                            begin
                                TableVersionField.Delete;
                                NewFieldAvailable := false;
                            end;

                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'OptionString=') > 0):
                            ReadOptionString(Line);
                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'AutoIncrement=Yes') > 0):
                            SetAutoIncrement;
                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'Compressed=') > 0):
                            SetCompressed(Line);
                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'SubType=') > 0):
                            SetSubtype(Line);
                        ReadingFields and NewFieldAvailable and (StrPos(Line, 'SQL Data Type=') > 0):
                            SetSqlDataType(Line);
                        ReadingKey and (CopyStr(Line, 1, 5) = '    {'):
                            begin
                                Line := CopyStr(Line, 6);
                                ID := ExtractFirstPartFromString(Line, ';', '');
                                ID := ExtractFirstPartFromString(Line, ';', '');
                                ID := ID + ',';
                                i := 1;
                                TableVersionField."Field Name" := SelectStr(i, ID);
                                while TableVersionField."Field Name" <> '' do begin
                                    SearchTableVersionField.SetRange("Table Version Code", TableVersionField."Table Version Code");
                                    SearchTableVersionField.SetRange("Table No.", TableVersionField."Table No.");
                                    SearchTableVersionField.SetRange("Field Name", TableVersionField."Field Name");
                                    SearchTableVersionField.FindFirst;
                                    TableVersionKey.Init;
                                    TableVersionKey."Table Version Code" := SearchTableVersionField."Table Version Code";
                                    TableVersionKey."Table No." := SearchTableVersionField."Table No.";
                                    TableVersionKey."Field Index No." := i;
                                    TableVersionKey."Field No." := SearchTableVersionField."Field No.";
                                    TableVersionKey.Insert;
                                    i += 1;
                                    TableVersionField."Field Name" := SelectStr(i, ID);
                                end;
                                ReadingKey := false;
                            end;
                        ReadingProperties and (StrPos(Line, 'DataPerCompany=') > 0):
                            begin
                                LineValue := DelChr(Line, '>', ';');
                                PropertyPos := StrPos(LineValue, 'DataPerCompany');
                                SeparatorPos := StrPos(LineValue, '=');
                                BoolValue := CopyStr(LineValue, SeparatorPos + 1) = 'Yes';
                                TableVersionField.AddProperty(TableVersionField.FieldName("Data Per Company"), BoolValue);
                            end;
                        CopyStr(Line, 1, 13) = 'OBJECT Table ':
                            begin
                                i := 14;
                                while IsNumeric(CopyStr(Line, i, 1)) do begin
                                    ID := ID + CopyStr(Line, i, 1);
                                    i := i + 1;
                                end;
                                TableVersionField.Init;
                                TableVersionField."Table Version Code" := TableVersion.Code;
                                if GrabIDFromObjectName then begin
                                    TableVersionField."Table Name" := SelectStr(2, CopyStr(Line, i + 1));
                                    Evaluate(TableVersionField."Table No.", SelectStr(1, CopyStr(Line, i + 1)));
                                end else begin
                                    TableVersionField."Table Name" := CopyStr(Line, i + 1);
                                    Evaluate(TableVersionField."Table No.", ID);
                                end;
                                Window.Update(1, TableVersionField."Table No.");
                            end;
                        CopyStr(Line, 1, 14) = 'OBJECT [Table ':
                            begin
                                i := 15;
                                while IsNumeric(CopyStr(Line, i, 1)) do begin
                                    ID := ID + CopyStr(Line, i, 1);
                                    i := i + 1;
                                end;
                                TableVersionField.Init;
                                TableVersionField."Table Version Code" := TableVersion.Code;
                                TableVersionField."Table Name" := DelChr(CopyStr(Line, i + 1), '>', ']');
                                Evaluate(TableVersionField."Table No.", ID);
                                Window.Update(1, TableVersionField."Table No.");
                            end;
                        Line = '  }':
                            begin
                                ReadingFields := false;
                                ReadingProperties := false;
                            end;
                        Line = '  FIELDS':
                            ReadingFields := true;
                        Line = '  KEYS':
                            ReadingKey := true;
                        Line = '  PROPERTIES':
                            ReadingProperties := true;
                    end;
                end;

                Window.Close();
            end;

            trigger OnPreDataItem()
            var
                NVInStream: InStream;
                NVOutStream: OutStream;
            begin
                TempBlob.Init();

                if UploadIntoStream(ImportTxt, '', TextFileFilterLbl, FileName, NVInStream) then begin
                    TempBlob.Blob.CreateOutStream(NVOutStream);
                    CopyStream(NVOutStream, NVInStream);
                end else
                    CurrReport.Break();
                TempBlob.Insert();
            end;
        }
    }

    requestpage
    {
        Caption = 'Read Table Object File';

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        TableVersion.Find();
        TableVersionField.SetRange("Table Version Code", TableVersion.Code);
        if not TableVersionField.IsEmpty() then
            Error(VersionFieldsNotEmptyErr);
        TableVersionKey.SetRange("Table Version Code", TableVersion.Code);
        if not TableVersionKey.IsEmpty() then
            Error(VersionPrimaryKeysNotEmptyErr);
    end;

    var
        TableVersion: Record "Table Version";
        TableVersionField: Record "Table Version Field";

        TableVersionKey: Record "Table Version Primary Key";
        TempBlob: Record TempBlob temporary;
        FileMgt: Codeunit "File Management";
        Window: Dialog;
        FileName: Text;
        VersionFieldsNotEmptyErr: Label 'Version Fields Table exists, import not allowed !';
        VersionPrimaryKeysNotEmptyErr: Label 'Version Primary Keys exists, import not allowed !';
        ReadingTableTxt: Label 'Reading table no. #1##########';
        TextFileFilterLbl: Label 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*';
        ImportTxt: Label 'Import';
        GrabIDFromObjectName: Boolean;

    procedure SetTableVersion(SetToTableVersion: Record "Table Version"; SetIDFromObjectName: Boolean)
    begin
        TableVersion := SetToTableVersion;
        GrabIDFromObjectName := SetIDFromObjectName;
    end;

    local procedure IsNumeric(Ch: Text[1]): Boolean
    begin
        exit((Ch >= '0') and (Ch <= '9'));
    end;

    local procedure ExtractFirstPartFromString(var Text: Text; Separator: Text[1]; Delimiter: Text[1]) Token: Text
    var
        Pos: Integer;
    begin
        Pos := StrPos(Text, Separator);
        if Pos > 0 then begin
            Token := CopyStr(Text, 1, Pos - 1);
            if Pos + 1 <= StrLen(Text) then
                Text := CopyStr(Text, Pos + 1)
            else
                Text := '';
        end else begin
            Token := Text;
            Text := '';
        end;
        if Delimiter <> '' then
            if (CopyStr(Token, 1, 1) = Delimiter) and (CopyStr(Token, StrLen(Token), 1) = Delimiter) then
                Token := CopyStr(Token, 2, StrLen(Token) - 2);
        Token := DelChr(Token, '>', '}');
        Token := DelChr(Token, '>', ' ');
    end;

    local procedure ReadOptionString(Line: Text)
    var
        i: Integer;
    begin
        i := StrPos(Line, 'OptionString=');
        Line := CopyStr(Line, i + 13);
        i := StrPos(Line, ';');
        if i > 0 then
            Line := CopyStr(Line, 1, i - 1);
        i := StrPos(Line, '}');
        if i > 0 then
            Line := CopyStr(Line, 1, i - 2);
        TableVersionField.SetOptionString(DelChr(DelChr(Line, '>', ']'), '<', '['));
        TableVersionField.Modify();
    end;

    local procedure SetAutoIncrement()
    begin
        TableVersionField."Auto Increment" := true;
        TableVersionField.Modify();
    end;

    local procedure SetSubtype(Line: Text)
    var
        TypeHelper: Codeunit "Type Helper";
        LineValue: Text;
        TextValue: Text;
        SeparatorPos: Integer;
    begin
        LineValue := DelChr(Line, '>', ' }');
        SeparatorPos := StrPos(LineValue, '=');
        TextValue := CopyStr(LineValue, SeparatorPos + 1);
        TableVersionField.AddProperty(TableVersionField.FieldName(SubType), TypeHelper.GetOptionNo(TextValue, TableVersionField.GetOptionStringFromField(TableVersionField.FieldName(SubType))));
        TableVersionField.Modify();
    end;

    local procedure SetCompressed(Line: Text)
    var
        LineValue: Text;
        BoolValue: Boolean;
        SeparatorPos: Integer;
    begin
        LineValue := DelChr(Line, '>', ';');
        SeparatorPos := StrPos(LineValue, '=');
        BoolValue := CopyStr(LineValue, SeparatorPos + 1) = 'Yes';
        TableVersionField.AddProperty(TableVersionField.FieldName(Compressed), BoolValue);
        TableVersionField.Modify();
    end;

    local procedure SetSqlDataType(Line: Text)
    var
        LineValue: Text;
        SeparatorPos: Integer;
    begin
        LineValue := DelChr(Line, '>', ';');
        SeparatorPos := StrPos(LineValue, '=');
        TableVersionField.AddProperty(TableVersionField.FieldName("SQL Data Type"), CopyStr(LineValue, SeparatorPos + 1));
        TableVersionField.Modify();
    end;

}

