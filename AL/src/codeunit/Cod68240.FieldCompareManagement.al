codeunit 68240 "Field Compare Management"
{
    // ©Dynamics.is


    trigger OnRun()
    begin
    end;

    var
        Window: Dialog;
        WindowLastUpdated: DateTime;
        SourceBaseVersionCode: Code[20];
        DestinationBaseVersionCode: Code[20];
        Total: Integer;
        Counter: Integer;
        NoOfTables: Integer;
        DeletedTxt: Label 'Field does not exist in destination version';
        NewTxt: Label 'Field is new in the destination version';
        LastTableNo: Integer;
        OptionValueChangedTxt: Label 'Option value changes';
        FieldLengthIncreasedTxt: Label 'Field length increased';
        FieldLengthDecreasedTxt: Label 'Field length decreased';
        FieldTypeChangedTxt: Label 'Field type changed';
        FieldDefChangedTxt: Label '%1 changed';
        FieldTypeChangedFromTextToCodeTxt: Label 'Field type changed from Text to Code';
        FieldTypeChangedFromCodeToTxt: Label 'Field type changed from Code to Text';
        DestinationTxt: Label ' in the destination version';
        ReadingSourceTxt: Label 'Reading Source  @1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\';
        ReadingDestinationTxt: Label 'Reading Destination @2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\';
        CheckingTablesTxt: Label 'Checking Tables  @3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';

    procedure Compare(CompareVersion: Record "Version Comparison")
    begin
        with CompareVersion do begin
            TestField("Source Version Code");
            TestField("Destination Version Code");
            FindBaseVersions(CompareVersion);
            Window.Open(ReadingSourceTxt + ReadingDestinationTxt + CheckingTablesTxt);
            WindowLastUpdated := CurrentDateTime();

            CompareSourceTables(CompareVersion);
            CompareDestinationTables(CompareVersion);
            CompareTables(CompareVersion);
            Window.Close();
        end;
    end;

    local procedure CompareSourceTables(CompareVersion: Record "Version Comparison")
    var
        SourceTable: Record "Table Version Field";
        DestinationTable: Record "Table Version Field";
    begin
        DestinationTable.SetRange("Table Version Code", CompareVersion."Destination Version Code");

        with SourceTable do begin
            SetRange("Table Version Code", CompareVersion."Source Version Code");
            Total := Count();
            Counter := 0;
            FindSet();
            repeat
                Counter += 1;
                if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                    Window.Update(1, Round(Counter / Total * 10000, 1));
                    WindowLastUpdated := CurrentDateTime();
                end;
                DestinationTable.SetRange("Table No.", "Table No.");
                DestinationTable.SetRange("Field No.", "Field No.");
                CompareSourceTableField(CompareVersion, SourceTable, DestinationTable);
            until Next() = 0;
            Window.Update(1, 10000);
        end;
    end;

    local procedure CompareDestinationTables(CompareVersion: Record "Version Comparison")
    var
        SourceTable: Record "Table Version Field";
        DestinationTable: Record "Table Version Field";
    begin
        SourceTable.SetRange("Table Version Code", CompareVersion."Source Version Code");

        with DestinationTable do begin
            SetRange("Table Version Code", CompareVersion."Destination Version Code");
            Total := Count();
            Counter := 0;
            Find('-');
            repeat
                Counter += 1;
                if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                    Window.Update(2, Round(Counter / Total * 10000, 1));
                    WindowLastUpdated := CurrentDateTime();
                end;
                SourceTable.SetRange("Table No.", "Table No.");
                SourceTable.SetRange("Field No.", "Field No.");
                CompareDestinationTableField(CompareVersion, SourceTable, DestinationTable);
            until Next() = 0;
            Window.Update(2, 10000);
        end;
    end;

    local procedure CompareTables(CompareVersion: Record "Version Comparison")
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareVersion.Code);
            Total := NoOfTables;
            Counter := 0;
            FindSet();
            repeat
                Counter += 1;
                if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                    Window.Update(3, Round(Counter / Total * 10000, 1));
                    WindowLastUpdated := CurrentDateTime();
                end;
                SetRange("Table No.", "Table No.");
                GetCompareTableStatus(CompareFieldResult);
                FindLast();
                SetRange("Table No.");
            until Next() = 0;
        end;
    end;

    local procedure CompareSourceTableField(CompareVersion: Record "Version Comparison"; var SourceTable: Record "Table Version Field"; var DestinationTable: Record "Table Version Field")
    var
        CompareResult: Option Identical,New,Modified,Deleted;
    begin
        with SourceTable do begin
            if IsSourceTableFieldOriginalNAV("Table No.", "Field No.") then exit;
            if not DestinationTable.FindFirst() then
                InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Deleted, DeletedTxt)
            else begin
                if "Data Per Company" <> DestinationTable."Data Per Company" then
                    InsertCompareTableResult(CompareVersion.Code, "Table No.", CompareResult::Modified);
                case true of
                    ("Field Type" = DestinationTable."Field Type") and (GetOptionString = DestinationTable.GetOptionString()):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Identical, '');
                    ("Field Type" = DestinationTable."Field Type") and (GetOptionString <> DestinationTable.GetOptionString):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, OptionValueChangedTxt + DestinationTxt);
                    (CopyStr("Field Type", 1, 4) = 'Text') and (CopyStr(DestinationTable."Field Type", 1, 4) = 'Code'):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, FieldTypeChangedFromTextToCodeTxt + DestinationTxt);
                    (CopyStr("Field Type", 1, 4) = 'Code') and (CopyStr(DestinationTable."Field Type", 1, 4) = 'Text'):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, FieldTypeChangedFromCodeToTxt + DestinationTxt);
                    (CopyStr("Field Type", 1, 4) in ['Code', 'Text']) and (CopyStr(DestinationTable."Field Type", 1, 4) in ['Code', 'Text']):
                        case true of
                            ToInt(CopyStr("Field Type", 5)) <= ToInt(CopyStr(DestinationTable."Field Type", 5)):
                                InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Identical, FieldLengthIncreasedTxt + DestinationTxt);
                            ToInt(CopyStr("Field Type", 5)) > ToInt(CopyStr(DestinationTable."Field Type", 5)):
                                InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, FieldLengthIncreasedTxt + DestinationTxt);
                            else
                                InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, '');
                        end;
                    ("Field Type" <> DestinationTable."Field Type"):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, FieldTypeChangedTxt + DestinationTxt);
                    ("SQL Data Type" <> DestinationTable."SQL Data Type"):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, StrSubstNo(FieldDefChangedTxt, FieldCaption("SQL Data Type")) + DestinationTxt);
                    ("Auto Increment" <> DestinationTable."Auto Increment"):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, StrSubstNo(FieldDefChangedTxt, FieldCaption("Auto Increment")) + DestinationTxt);
                    (Compressed <> DestinationTable.Compressed):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, StrSubstNo(FieldDefChangedTxt, FieldCaption(Compressed)) + DestinationTxt);
                    (SubType <> DestinationTable.SubType):
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, StrSubstNo(FieldDefChangedTxt, FieldCaption(SubType)) + DestinationTxt);
                    else
                        InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::Modified, '');
                end;
            end;
        end;
    end;

    local procedure CompareDestinationTableField(CompareVersion: Record "Version Comparison"; var SourceTable: Record "Table Version Field"; var DestinationTable: Record "Table Version Field")
    var
        CompareResult: Option Identical,New,Modified,Deleted;
    begin
        with DestinationTable do begin
            if IsDestinationTableFieldOriginalNAV("Table No.", "Field No.") then exit;
            if not SourceTable.FindFirst() then
                InsertCompareFieldResult(CompareVersion.Code, "Table No.", "Field No.", CompareResult::New, NewTxt);
        end;
    end;

    local procedure GetCompareTableStatus(CompareFieldResult: Record "Compare Field Result")
    var
        ResultMode: Option Identical,New,Modified,Deleted;
        ModeEmpty: array[4] of Boolean;
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", "Compare Version Code");
            SetRange("Table No.", "Table No.");
            for ResultMode := ResultMode::Identical to ResultMode::Deleted do begin
                // Identical,New,Modified,Deleted
                SetRange(Result, ResultMode);
                ModeEmpty[ResultMode + 1] := IsEmpty();
            end;
            SetRange(Result);
            Find();

            case true of
                ModeEmpty[1] and ModeEmpty[2] and ModeEmpty[3] and not ModeEmpty[4] and not IsSourceTableOriginalNAV("Table No."):
                    InsertCompareTableResult("Compare Version Code", "Table No.", ResultMode::Deleted);
                ModeEmpty[1] and not ModeEmpty[2] and ModeEmpty[3] and ModeEmpty[4] and not IsSourceTableOriginalNAV("Table No."):
                    InsertCompareTableResult("Compare Version Code", "Table No.", ResultMode::New);
                not ModeEmpty[1] and ModeEmpty[2] and ModeEmpty[3] and ModeEmpty[4]:
                    InsertCompareTableResult("Compare Version Code", "Table No.", ResultMode::Identical);
                else
                    InsertCompareTableResult("Compare Version Code", "Table No.", ResultMode::Modified);
            end;
        end;
    end;

    local procedure InsertCompareTableResult(VersionCode: Code[20]; TableNo: Integer; CompareResult: Option)
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        with CompareTableResult do begin
            Init();
            "Compare Version Code" := VersionCode;
            "Table No." := TableNo;
            if Find() then begin
                if Result < CompareResult then begin
                    Result := CompareResult;
                    Modify();
                end;
            end else begin
                Result := CompareResult;
                Insert();
            end;
        end;
    end;


    local procedure InsertCompareFieldResult(VersionCode: Code[20]; TableNo: Integer; TableFieldNo: Integer; CompareResult: Option; Desc: Text)
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        with CompareFieldResult do begin
            Init();
            "Compare Version Code" := VersionCode;
            "Table No." := TableNo;
            "Field No." := TableFieldNo;
            Result := CompareResult;
            Description := CopyStr(Desc, 1, MaxStrLen(Description));
            Insert();
        end;

        if LastTableNo <> TableNo then begin
            LastTableNo := TableNo;
            NoOfTables += 1;
        end;
    end;

    local procedure ToInt(LengthAsString: Text) Length: Integer
    begin
        Evaluate(Length, LengthAsString);
    end;

    local procedure IsSourceTableOriginalNAV(TableNo: Integer): Boolean
    var
        TableVersionField: Record "Table Version Field";
    begin
        if SourceBaseVersionCode = '' then exit(false);
        with TableVersionField do begin
            SetRange("Table Version Code", SourceBaseVersionCode);
            SetRange("Table No.", TableNo);
            exit(not IsEmpty());
        end;
    end;

    local procedure IsSourceTableFieldOriginalNAV(TableNo: Integer; TableFieldNo: Integer): Boolean
    var
        TableVersionField: Record "Table Version Field";
    begin
        if SourceBaseVersionCode = '' then exit(false);
        with TableVersionField do begin
            SetRange("Table Version Code", SourceBaseVersionCode);
            SetRange("Table No.", TableNo);
            SetRange("Field No.", TableFieldNo);
            exit(not IsEmpty());
        end;
    end;

    local procedure IsDestinationTableOriginalNAV(TableNo: Integer): Boolean
    var
        TableVersionField: Record "Table Version Field";
    begin
        if DestinationBaseVersionCode = '' then exit(false);
        with TableVersionField do begin
            SetRange("Table Version Code", DestinationBaseVersionCode);
            SetRange("Table No.", TableNo);
            exit(not IsEmpty());
        end;
    end;

    local procedure IsDestinationTableFieldOriginalNAV(TableNo: Integer; TableFieldNo: Integer): Boolean
    var
        TableVersionField: Record "Table Version Field";
    begin
        if DestinationBaseVersionCode = '' then exit(false);
        with TableVersionField do begin
            SetRange("Table Version Code", DestinationBaseVersionCode);
            SetRange("Table No.", TableNo);
            SetRange("Field No.", TableFieldNo);
            exit(not IsEmpty());
        end;
    end;

    local procedure FindBaseVersions(CompareVersion: Record "Version Comparison")
    var
        TableVersion: Record "Table Version";
    begin
        TableVersion.Get(CompareVersion."Source Version Code");
        SourceBaseVersionCode := TableVersion."Base Version Code";
        TableVersion.Get(CompareVersion."Destination Version Code");
        DestinationBaseVersionCode := TableVersion."Base Version Code";
    end;
}

