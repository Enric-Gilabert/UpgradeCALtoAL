codeunit 68244 "To 2015 Upgrade Code Maker"
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
        CodeGenerator: Codeunit "To 2015 Code Generator";
        TableStream: OutStream;
        CodeunitStream: OutStream;
        Window: Dialog;
        WindowLastUpdated: DateTime;
        Total: Integer;
        Counter: Integer;
        VerifyingTxt: Label 'Verifying Actions @1@@@@@@@@@@\';
        BuildTableCodeTxt: Label 'Building Upgrade Tables @2@@@@@@@@@@\';
        BuildCodeunitCodeTxt: Label 'Building Codeunit @3@@@@@@@@@@\';
        BuildForceTableCodeAddinTxt: Label 'Building Mark Discontinued Tables @4@@@@@@@@@@';
        InTableTxt: Label ' in table no. %1';

    procedure UpgradeCode()
    var
        ErrorText: Text;
    begin
        CodeGenerator.Initialize();
        Window.Open(VerifyingTxt + BuildTableCodeTxt + BuildCodeunitCodeTxt + BuildForceTableCodeAddinTxt);
        WindowLastUpdated := CurrentDateTime();

        with CompareVersion do begin
            CalcFields("Step 1 Tables Object File", "Step 1 Codeunit Object File");
            Clear("Step 1 Tables Object File");
            Clear("Step 1 Codeunit Object File");
            "Step 1 Tables Object File".CreateOutStream(TableStream);
            "Step 1 Codeunit Object File".CreateOutStream(CodeunitStream);

            GetCompareTableResultErrors(Code, ErrorText);

            if ErrorText <> '' then
                Error(ErrorText);

            CreateUpgradeTables();
            CreateUpgradeCodeunit();

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
    begin
        CodeunitStream.WriteText(
          CodeGenerator.CodeunitBegin(
            CompareVersion."First Upgrade Codeunit ID",
            CopyStr('Upgrade ' + CodeGenerator.GetVariableName(CompareVersion.Name), 1, 30)));

        CreateTableSyncSetup();
        CreateTableDataUpgrade();
        //CreateMarkTableCode;

        CodeunitStream.WriteText(CodeGenerator.CodeunitEnd());
    end;

    local procedure CreateTableSyncSetup()
    var
        CompareTableResult: Record "Compare Table Result";
    begin
        with CompareTableResult do begin
            SetCurrentKey("Compare Version Code", "Step 1 Action");
            SetRange("Compare Version Code", CompareVersion.Code);
            SetRange(Result, Result::Modified, Result::Deleted);
            Total := Count();
            Counter := 0;
            if FindSet() then begin
                CodeunitStream.WriteText(CodeGenerator.TableSyncSetupBegin());
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(3, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    CodeunitStream.WriteText(
                      CodeGenerator.TableSyncSetupDefined("Table No.", "Upgrade Table ID", CodeGenerator.FunctionPrefix("Step 1 Action" + 1)));
                until Next() = 0;
                CodeunitStream.WriteText(CodeGenerator.TableSyncSetupEnd());
            end;
            Window.Update(3, 10000);
        end;
    end;

    local procedure CreateTableDataUpgrade()
    var
        CompareTableResult: Record "Compare Table Result";
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
            if FindSet() then
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(3, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    DestinationTableName := CodeGenerator.GetVariableName(GetDestinationTableName());
                    TempTableName := CodeGenerator.GetVariableName(GetSourceTempTableName());
                    ProcedureName := CodeGenerator.FunctionPrefix("Step 2 Action" + 1) + TempTableName;
                    ProcedureCode := CodeGenerator.TableUpgradeBegin(ProcedureName, Counter + 4, "Upgrade Table ID", TempTableName, "Table No.", DestinationTableName);
                    if CompareTableResult.Result = CompareTableResult.Result::New then
                        "Step 1 Action" := CompareTableResult.GetUpgradeTableStep1Action();
                    case true of
                        ("Step 1 Action" = "Step 1 Action"::Move) or (CompareTableResult.Result = CompareTableResult.Result::New):
                            begin
                                ProcedureCode += CodeGenerator.TableUpgradeLoopBegin(DestinationTableName);
                                DoCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.TableUpgradeLoopInitTable("Table No.", DestinationTableName);
                                if "Step 2 Transfer Fields" then
                                    if DestinationTableName <> '' then
                                        ProcedureCode += CodeGenerator.TableUpgradeLoopTransferfields(DestinationTableName, TempTableName)
                                    else
                                        TransferFieldsLoop(CompareTableResult, ProcedureCode);
                                DoCopyFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                DoInitFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                DoInsertFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                ProcedureCode += CodeGenerator.TableUpgradeLoopInsertTable(DestinationTableName);
                                ProcedureCode += CodeGenerator.TableUpgradeLoopEnd(DestinationTableName);
                            end;
                        else begin
                                ProcedureCode += CodeGenerator.TableUpgradeLoopBegin(DestinationTableName);
                                DoTempTableCalcFieldsLoop(CompareTableResult, ProcedureCode);
                                ProcedureCode += CodeGenerator.TableUpgradeLoopGetTable(DestinationTableName, TableVersionKey.GetPrimaryKeyList(CompareVersion."Destination Version Code", "Table No."));
                                if "Step 2 Transfer Fields" then
                                    ProcedureCode += CodeGenerator.TableUpgradeLoopTransferfields(DestinationTableName, TempTableName);
                                DoInsertFieldsLoop(CompareTableResult, DestinationTableName, ProcedureCode);
                                ProcedureCode += CodeGenerator.TableUpgradeLoopModifyTable(DestinationTableName);
                                ProcedureCode += CodeGenerator.TableUpgradeLoopEnd(DestinationTableName);
                            end;

                    end;
                    if "Step 2 Action" = "Step 2 Action"::Move then
                        ProcedureCode += CopyStr(CodeGenerator.TableUpgradeDeleteAll(), 3);
                    ProcedureCode += CodeGenerator.TableUpgradeEnd();
                    CodeunitStream.WriteText(ProcedureCode);
                until Next() = 0;

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
                    ProcedureCode += CodeGenerator.TableUpgradeLoopCalcfields(TableVersionField."Field Name");
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
                        ProcedureCode += CodeGenerator.TableUpgradeLoopCalcfields(CompareFieldResult.GetSourceFieldName());
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
                        ProcedureCode += CodeGenerator.TableUpgradeLoopNewfield(DestinationTableName, TableVersionField."Field Name");
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
                        ProcedureCode += CodeGenerator.TableUpgradeLoopCopyfield(DestinationTableName, GetDestinationFieldName(), TableVersionField."Field Name");
                    end else
                        if Result in [Result::Modified, Result::New] then begin
                            if TableVersionField.Get(CompareVersion."Source Version Code", CompareTableResult.GetUpgradeTableSourceID(), "Field No.") then begin
                                if TableVersionField2.Get(CompareVersion."Destination Version Code", "Table No.", "Field No.") then
                                    if (TableVersionField."Field Type" <> TableVersionField2."Field Type") or not CompareTableResult."Step 2 Transfer Fields" then
                                        if TableVersionField.IsCompatableType(TableVersionField."Field Type", TableVersionField2."Field Type") then
                                            ProcedureCode += CodeGenerator.TableUpgradeLoopCopyfield(DestinationTableName, GetDestinationFieldName(), TableVersionField."Field Name")
                                        else
                                            ProcedureCode += CodeGenerator.TableUpgradeLoopNewfield(DestinationTableName, GetDestinationFieldName());
                            end else
                                ProcedureCode += CodeGenerator.TableUpgradeLoopNewfield(DestinationTableName, GetDestinationFieldName());
                        end else
                            ProcedureCode += CodeGenerator.TableUpgradeLoopNewfield(DestinationTableName, GetDestinationFieldName());
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
                    ProcedureCode += CodeGenerator.TableUpgradeLoopCopyfield(DestinationTableName, GetDestinationFieldName(), GetSourceFieldName());
                until Next() = 0;
        end;
    end;

    local procedure TransferFieldsLoop(var CompareTableResult: Record "Compare Table Result"; var ProcedureCode: Text)
    var
        CompareFieldResult: Record "Compare Field Result";
    begin
        with CompareFieldResult do begin
            SetRange("Compare Version Code", CompareTableResult."Compare Version Code");
            SetRange("Table No.", CompareTableResult."Table No.");
            ProcedureCode += CodeGenerator.TableUpgradeLoopSetVariant();
            if FindSet() then
                repeat
                    ProcedureCode += CodeGenerator.TableUpgradeLoopCopyfield('', GetSourceFieldName(), GetSourceFieldName());
                until Next() = 0;
            ProcedureCode += CodeGenerator.TableUpgradeLoopGetVariant();
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
                CodeunitStream.WriteText(CodeGenerator.MarkDiscontinuedCodeBegin());
                repeat
                    Counter += 1;
                    if (CurrentDateTime() - WindowLastUpdated) > 100 then begin
                        Window.Update(4, Round(Counter / Total * 10000, 1));
                        WindowLastUpdated := CurrentDateTime();
                    end;
                    CodeunitStream.WriteText(CodeGenerator.MarkDiscontinuedTable(GetSourceTempTableName()));
                until Next() = 0;
                CodeunitStream.WriteText(CodeGenerator.MarkDiscontinuedCodeEnd());
                Window.Update(4, 10000);
            end;

        end;
    end;
}

