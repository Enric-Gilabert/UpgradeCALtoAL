codeunit 68242 "To 2013 Step 1 Code Maker"
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
        TableStream: OutStream;
        CodeunitStream: OutStream;
        DeleteDiscontinuedTablesStream: OutStream;
        FunctionBufferStream: OutStream;
        Window: Dialog;
        WindowLastUpdated: DateTime;
        Total: Integer;
        Counter: Integer;
        VerifyingTxt: Label 'Verifying Step 1 Actions @1@@@@@@@@@@\';
        BuildTableCodeTxt: Label 'Building Step 1 Upgrade Tables @2@@@@@@@@@@\';
        BuildCodeunitCodeTxt: Label 'Building Step 1 Codeunit @3@@@@@@@@@@\';
        BuildForceTableCodeAddinTxt: Label 'Building Step 1 Delete Discontinued Tables @4@@@@@@@@@@';
        DeleteDiscontinuedLinesCommentTxt: Label 'Add these lines to the DeleteDiscontinuedTables trigger of Codeunit ID 104002';
        InTableTxt: Label ' in table no. %1';

    procedure UpgradeCode()
    var
        ErrorText: Text;
    begin
        CodeGenerator.Initialize();
        Window.Open(VerifyingTxt + BuildTableCodeTxt + BuildCodeunitCodeTxt + BuildForceTableCodeAddinTxt);
        WindowLastUpdated := CurrentDateTime();

        with CompareVersion do begin
            CalcFields("Step 1 Tables Object File", "Step 1 Codeunit Object File", "Step 1 Delete Object File");
            Clear("Step 1 Tables Object File");
            Clear("Step 1 Codeunit Object File");
            Clear("Step 1 Delete Object File");
            "Step 1 Tables Object File".CreateOutStream(TableStream);
            "Step 1 Codeunit Object File".CreateOutStream(CodeunitStream);
            "Step 1 Delete Object File".CreateOutStream(DeleteDiscontinuedTablesStream);
            TempBlob.Blob.CreateOutStream(FunctionBufferStream);

            GetCompareTableResultErrors(CompareVersion.Code, ErrorText);

            if ErrorText <> '' then
                Error(ErrorText);

            CreateUpgradeTables();
            CreateUpgradeCodeunit();
            CreateDeleteTableCode();

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

    local procedure CreateUpgradeTables()
    var
        CompareTableResult: Record "Compare Table Result";
        TableProperty: Record "Table Version Field";
    begin
        with CompareTableResult do begin
            SetRange("Compare Version Code", CompareVersion.Code);
            SetFilter("Step 1 Action", '%1|%2|%3', "Step 1 Action"::Copy, "Step 1 Action"::Move, "Step 1 Action"::"Use Source Id");
            Total := Count();
            Counter := 0;
            if FindSet() then
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(2, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    TableProperty.SetRange("Table Version Code", CompareVersion."Source Version Code");
                    TableProperty.SetRange("Table No.", "Table No.");
                    if not TableProperty.FindFirst() then
                        TableProperty.Init();

                    TableStream.WriteText(CodeGenerator.TableHeader(TableProperty, "Upgrade Table ID", GetSourceTempTableName()));
                    CreateUpgradeTableFields("Table No.", "Step 1 Action" = "Step 1 Action"::Move);
                    TableStream.WriteText(CodeGenerator.TableKeys(CompareVersion."Source Version Code", "Table No."));
                    TableStream.WriteText(CodeGenerator.TableFooter());
                until Next() = 0;
            Window.Update(2, 10000);
        end;
    end;

    local procedure CreateUpgradeTableFields(TableNo: Integer; FullTable: Boolean)
    var
        CompareFieldResult: Record "Compare Field Result";
        CopyFieldResult: Record "Compare Field Result";
    begin
        with TableVersionKey do begin
            Reset();
            SetRange("Table Version Code", CompareVersion."Source Version Code");
            SetRange("Table No.", TableNo);
        end;

        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange("Table No.", TableNo);
            SetRange(Result, Result::Modified, Result::Deleted);
        end;

        with CopyFieldResult do begin
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange("Table No.", TableNo);
        end;

        with TableVersionField do begin
            Reset();
            SetRange("Table Version Code", CompareVersion."Source Version Code");
            SetRange("Table No.", TableNo);
            FindSet();
            repeat
                TableVersionKey.SetRange("Field No.", "Field No.");
                CompareFieldResult.SetRange("Field No.", "Field No.");
                CopyFieldResult.SetRange("Copy Value From Field No.", "Field No.");
                if FullTable or CompareFieldResult.FindFirst() or TableVersionKey.FindFirst() or CopyFieldResult.FindFirst() then
                    TableStream.WriteText(CodeGenerator.FieldLine(TableVersionField));
            until Next() = 0;
        end;
    end;

    local procedure CreateUpgradeCodeunit()
    var
        CompareTableResult: Record "Compare Table Result";
        InStr: InStream;
        SourceTableName: Text;
        TempTableName: Text;
        ProcedureName: Text;
        ProcedureCode: Text;
        ClearingLoopRequired: Boolean;
    begin
        with CompareTableResult do begin
            SetCurrentKey("Compare Version Code", "Step 1 Action");
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange("Step 1 Action", "Step 1 Action"::Copy, "Step 1 Action"::Force);
            Total := Count();
            Counter := 0;
            if FindSet() then begin
                CodeunitStream.WriteText(
                  CodeGenerator.CodeunitHeaderBegin(
                    CompareVersion."First Upgrade Codeunit ID",
                    CopyStr('Upgrade ' + CodeGenerator.GetVariableName(CompareVersion.Name), 1, 30), 104045));
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(3, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    ClearingLoopRequired := ClearingRequiresLoop(CompareTableResult);
                    SourceTableName := CodeGenerator.GetVariableName(GetSourceTableName());
                    TempTableName := CodeGenerator.GetVariableName(GetSourceTempTableName());
                    ProcedureName := CodeGenerator.FunctionPrefix("Step 1 Action" + 1) + SourceTableName;
                    CodeunitStream.WriteText(CodeGenerator.CodeunitCallProcedure(ProcedureName));
                    ProcedureCode := CodeGenerator.CodeunitProcedureFrameBegin(ProcedureName, Counter + 1, "Table No.", SourceTableName, "Upgrade Table ID", TempTableName);

                    case true of
                        ClearingLoopRequired and ("Step 1 Action" = "Step 1 Action"::Copy):
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopBegin();
                                DoCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopTransferfields(SourceTableName, TempTableName);
                                DoClearFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopModifyTable('');
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopEnd();
                            end;
                        "Step 1 Action" = "Step 1 Action"::Copy:
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopBegin();
                                DoCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopTransferfields(SourceTableName, TempTableName);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopEnd();
                                DoClearFields(CompareTableResult, ProcedureCode);
                            end;
                        "Step 1 Action" = "Step 1 Action"::Move:
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopBegin();
                                DoCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopTransferfields(SourceTableName, TempTableName);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopEnd();
                                ProcedureCode += CodeGenerator.CodeunitProcedureDeleteAll()
                            end;
                        (Result = Result::Deleted) and ("Step 1 Action" = "Step 1 Action"::Force):
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureForceBegin();
                                ProcedureCode += CodeGenerator.CodeunitProcedureDeleteAll();
                                ProcedureCode += CodeGenerator.CodeunitProcedureForceEnd();
                            end;
                        ClearingLoopRequired and ("Step 1 Action" = "Step 1 Action"::Force):
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopBegin();
                                DoClearFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopModifyTable('');
                                ProcedureCode += CodeGenerator.CodeunitProcedureLoopEnd();
                            end;
                        "Step 1 Action" = "Step 1 Action"::Force:
                            begin
                                ProcedureCode += CodeGenerator.CodeunitProcedureForceBegin();
                                DoClearFields(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.CodeunitProcedureForceEnd();
                            end;
                    end;
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
            SetRange("Table Version Code", CompareVersion."Source Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            SetRange("Field Type", 'BLOB');
            if FindSet() then
                repeat
                    ProcedureCode += CodeGenerator.CodeunitProcedureLoopCalcfields(TableVersionField."Field Name");
                until Next() = 0;
        end;
    end;

    local procedure DoClearFieldsLoop(var CompareTableResult: Record "Compare Table Result"; var ProcedureCode: Text)
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
                    ProcedureCode += CodeGenerator.CodeunitProcedureLoopClearfield(GetSourceFieldName(), GetSourceFieldType());
                until Next() = 0;
        end;
    end;

    local procedure DoClearFields(var CompareTableResult: Record "Compare Table Result"; var ProcedureCode: Text)
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
                    ProcedureCode += CodeGenerator.CodeunitProcedureClearField(GetSourceFieldName(), GetSourceFieldType());
                until Next() = 0;
        end;
    end;

    local procedure ClearingRequiresLoop(var CompareTableResult: Record "Compare Table Result"): Boolean
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
                    if GetSourceFieldType() in ['DateFormula', 'BLOB', 'GUID', 'Binary', 'RecordID', 'TableFilter'] then exit(true);
                until Next() = 0;
        end;
        exit(false);
    end;

    local procedure CreateDeleteTableCode()
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        with CompareTableResult do begin
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange(Result, Result::Deleted);
            SetRange("Step 1 Action", "Step 1 Action"::Move, "Step 1 Action"::Force);
            Total := Count();
            Counter := 0;
            if FindSet() then begin
                DeleteDiscontinuedTablesStream.WriteText(CodeGenerator.CommentLine(DeleteDiscontinuedLinesCommentTxt));
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(4, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    DeleteDiscontinuedTablesStream.WriteText(CodeGenerator.DeleteDiscontinedTable("Table No."));
                until Next() = 0;
                DeleteDiscontinuedTablesStream.WriteText(CodeGenerator.CommentLine(DeleteDiscontinuedLinesCommentTxt));
                Window.Update(4, 10000);
            end;
        end;
    end;
}

