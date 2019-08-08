codeunit 68243 "To 2013 Step 2 Code Maker"
{
    // ©Dynamics.is

    TableNo = "Version Comparison";

    trigger OnRun()
    begin
        CompareVersion.Copy(Rec);
        UpgradeCode();
        Rec := CompareVersion;
    end;

    var
        CompareVersion: Record "Version Comparison";
        TableVersionField: Record "Table Version Field";
        TableVersionKey: Record "Table Version Primary Key";
        TempBlob: Record TempBlob temporary;
        CodeGenerator: Codeunit "To 2013 Code Generator";
        CodeunitStream: OutStream;
        MarkDiscontinuedTablesStream: OutStream;
        FunctionBufferStream: OutStream;
        Window: Dialog;
        WindowLastUpdated: DateTime;
        Total: Integer;
        Counter: Integer;
        VerifyingTxt: Label 'Verifying Step 1 Actions @1@@@@@@@@@@\';
        BuildCodeunitCodeTxt: Label 'Building Step 1 Codeunit @3@@@@@@@@@@\';
        BuildForceTableCodeAddinTxt: Label 'Building Step 1 Mark Discontinued Tables @4@@@@@@@@@@';
        MarkDiscontinuedLinesCommentTxt: Label 'Add these lines to the OnRun trigger of Codeunit ID 104003';
        InTableTxt: Label ' in table no. %1';

    procedure UpgradeCode()
    var
        ErrorText: Text;
    begin
        CodeGenerator.Initialize();
        Window.Open(VerifyingTxt + BuildCodeunitCodeTxt + BuildForceTableCodeAddinTxt);
        WindowLastUpdated := CurrentDateTime();

        with CompareVersion do begin
            CalcFields("Step 2 Codeunit Object File", "Step 2 Mark Tables Object File");
            Clear("Step 2 Codeunit Object File");
            Clear("Step 2 Mark Tables Object File");
            "Step 2 Codeunit Object File".CreateOutStream(CodeunitStream);
            "Step 2 Mark Tables Object File".CreateOutStream(MarkDiscontinuedTablesStream);
            TempBlob.Blob.CreateOutStream(FunctionBufferStream);

            GetCompareTableResultErrors(CompareVersion.Code, ErrorText);

            if ErrorText <> '' then
                Error(ErrorText);

            CreateUpgradeCodeunit();
            CreateMarkTableCode();

            Modify();
            Commit();
        end;
    end;

    local procedure GetCompareTableResultErrors(VersionCode: Code[20]; var ErrorText: Text)
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        with CompareTableResult do begin
            SetRange("Compare Version Code", VersionCode);
            Total := Count();
            Counter := 0;
            FindSet();
            repeat
                Counter += 1;
                if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                    Window.Update(1, Round(Counter / Total * 10000, 1));
                    WindowLastUpdated := CurrentDateTime();
                end;
                ErrorText += VerifyTableActions(StrSubstNo(InTableTxt, "Table No."));
                ErrorText += VerifyFieldsActions(StrSubstNo(InTableTxt, "Table No."));
            until Next() = 0;
            Window.Update(1, 10000);
        end;
    end;

    local procedure CreateUpgradeCodeunit()
    var
        CompareTableResult: Record "Compare Table Result";
        InStr: InStream;
        DestinationTableName: Text;
        TempTableName: Text;
        ProcedureName: Text;
        ProcedureCode: Text;
    begin
        with CompareTableResult do begin
            SetCurrentKey("Compare Version Code", "Step 2 Action");
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange("Step 2 Action", "Step 2 Action"::Copy, "Step 2 Action"::Move);
            Total := Count();
            Counter := 0;
            if FindSet() then begin
                CodeunitStream.WriteText(
                  CodeGenerator.CodeunitHeaderBegin(
                    CompareVersion."First Upgrade Codeunit ID" + 1,
                    CopyStr('Upgrade ' + CodeGenerator.GetVariableName(CompareVersion.Name), 1, 30), 104048));

                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(3, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    DestinationTableName := CodeGenerator.GetVariableName(GetDestinationTableName());
                    TempTableName := CodeGenerator.GetVariableName(GetSourceTempTableName());
                    ProcedureName := CodeGenerator.FunctionPrefix("Step 2 Action" + 1) + DestinationTableName;
                    CodeunitStream.WriteText(CodeGenerator.CodeunitCallProcedure(ProcedureName));
                    ProcedureCode := CodeGenerator.CodeunitProcedureFrameBegin(ProcedureName, Counter + 1, "Upgrade Table ID", TempTableName, "Table No.", DestinationTableName);
                    if CompareTableResult.Result = CompareTableResult.Result::New then
                        "Step 1 Action" := CompareTableResult.GetUpgradeTableStep1Action();
                    case true of
                        ("Step 1 Action" = "Step 1 Action"::Move) or (CompareTableResult.Result = CompareTableResult.Result::New):
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopBegin;
                                DoCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopInitTable(DestinationTableName);
                                DoCopyFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                DoInitFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                DoInsertFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopInsertTable(DestinationTableName);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopEnd;
                            end;
                        else begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopBegin();
                                DoTempTableCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopGetTable(DestinationTableName, TableVersionKey.GetPrimaryKeyList(CompareVersion."Destination Version Code", "Table No."));
                                DoInsertFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopModifyTable(DestinationTableName);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopEnd();
                            end;

                    end;
                    if "Step 2 Action" = "Step 2 Action"::Move then
                        ProcedureCode += CopyStr(CodeGenerator.CodeunitProcedureDeleteAll(), 3);
                    ProcedureCode += CodeGenerator.CodeunitProcedureFrameEnd();
                    FunctionBufferStream.WriteText(ProcedureCode);
                until Next() = 0;
                CodeunitStream.WriteText(CodeGenerator.CodeunitHeaderEnd());
                TempBlob.Blob.CreateInStream(InStr);
                CopyStream(CodeunitStream, InStr);
                CodeunitStream.WriteText(CodeGenerator.CodeunitFooter());
            end;
            Window.Update(3, 10000);
        end;
    end;

    local procedure DoCalcFieldsLoop(var CompareTableResult: Record "Compare Table Result"; var ProcedureCode: Text)
    begin
        with TableVersionField do begin
            Reset();
            SetRange("Table Version Code", CompareVersion."Source Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            SetRange("Field Type", 'BLOB');
            if FindSet() then
                repeat
                    ProcedureCode += CodeGenerator.CodeunitProcedureLoopCalcfields(TableVersionField."Field Name");
                until Next() = 0;
        end;
    end;

    local procedure DoTempTableCalcFieldsLoop(var CompareTableResult: Record "Compare Table Result"; var ProcedureCode: Text)
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareTableResult."Compare Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            SetRange(Result, Result::Modified, Result::Deleted);
            FilterGroup(2);
            SetRange("Table Result Filter", CompareTableResult.Result);
            FilterGroup(0);
            if FindSet() then
                repeat
                    if CompareFieldResult.GetSourceFieldType() = 'BLOB' then
                        ProcedureCode += CodeGenerator.CodeunitProcedureLoopCalcfields(CompareFieldResult.GetSourceFieldName());
                until Next() = 0;
        end;
    end;

    local procedure DoInitFieldsLoop(var CompareTableResult: Record "Compare Table Result"; DestinationTableName: Text[50]; var ProcedureCode: Text)
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareTableResult."Compare Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            FilterGroup(2);
            SetRange("Table Result Filter", CompareTableResult.Result);
            FilterGroup(0);
        end;

        with TableVersionField do begin
            Reset();
            SetRange("Table Version Code", CompareVersion."Destination Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            if FindSet() then
                repeat
                    CompareFieldResult.SetRange("Field No.", "Field No.");
                    if CompareFieldResult.IsEmpty() then
                        ProcedureCode += CodeGenerator.CodeunitProcedureLoopNewfield(DestinationTableName, TableVersionField."Field Name");
                until Next() = 0;
        end;
    end;

    local procedure DoInsertFieldsLoop(var CompareTableResult: Record "Compare Table Result"; DestinationTableName: Text; var ProcedureCode: Text)
    var
        CompareFieldResult: Record "Compare Field Result";
        TableVersionField2: Record "Table Version Field";
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareTableResult."Compare Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            SetRange(Result, Result::New, Result::Modified);
            FilterGroup(2);
            SetRange("Table Result Filter", CompareTableResult.Result);
            FilterGroup(0);
            if FindSet() then
                repeat
                    if "Copy Value From Field No." <> 0 then begin
                        TableVersionField.Get(CompareVersion."Source Version Code", CompareTableResult.GetUpgradeTableSourceID(), "Copy Value From Field No.");
                        ProcedureCode += CodeGenerator.CodeunitProcedureLoopCopyfield(DestinationTableName, GetDestinationFieldName(), TableVersionField."Field Name");
                    end else
                        if Result = Result::Modified then begin
                            if TableVersionField.Get(CompareVersion."Source Version Code", CompareTableResult.GetUpgradeTableSourceID(), "Field No.") then begin
                                if TableVersionField2.Get(CompareVersion."Destination Version Code", "Table No.", "Field No.") then
                                    if TableVersionField.IsCompatableType(TableVersionField."Field Type", TableVersionField2."Field Type") then
                                        ProcedureCode += CodeGenerator.CodeunitProcedureLoopCopyfield(DestinationTableName, GetDestinationFieldName(), TableVersionField."Field Name")
                                    else
                                        ProcedureCode += CodeGenerator.CodeunitProcedureLoopNewfield(DestinationTableName, GetDestinationFieldName());
                            end else
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopNewfield(DestinationTableName, GetDestinationFieldName());
                        end else
                            ProcedureCode += CodeGenerator.CodeunitProcedureLoopNewfield(DestinationTableName, GetDestinationFieldName());
                until Next() = 0;
        end;
    end;

    local procedure DoCopyFieldsLoop(var CompareTableResult: Record "Compare Table Result"; DestinationTableName: Text[50]; var ProcedureCode: Text)
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareTableResult."Compare Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            SetRange(Result, Result::Identical);
            FilterGroup(2);
            SetRange("Table Result Filter", CompareTableResult.Result);
            FilterGroup(0);
            if FindSet() then
                repeat
                    ProcedureCode += CodeGenerator.CodeunitProcedureLoopCopyfield(DestinationTableName, GetDestinationFieldName(), GetSourceFieldName());
                until Next() = 0;
        end;
    end;

    local procedure CreateMarkTableCode()
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        with CompareTableResult do begin
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange("Step 2 Action", "Step 2 Action"::Move);
            Total := Count();
            Counter := 0;
            if FindSet() then begin
                MarkDiscontinuedTablesStream.WriteText(CodeGenerator.CommentLine(MarkDiscontinuedLinesCommentTxt));
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(4, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    MarkDiscontinuedTablesStream.WriteText(CodeGenerator.MarkDiscontinedTable("Upgrade Table ID"));
                until Next() = 0;
                MarkDiscontinuedTablesStream.WriteText(CodeGenerator.CommentLine(MarkDiscontinuedLinesCommentTxt));
                Window.Update(4, 10000);
            end;
        end;
    end;
}

