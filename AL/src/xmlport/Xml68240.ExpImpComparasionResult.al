xmlport 68240 "Exp/Imp Comparasion Result"
{
    Caption = 'Exp/Imp Comparasion Result';
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    DefaultNamespace = 'http://navision.guru';
    UseDefaultNamespace = true;

    schema
    {
        textelement(ComparisonResult)
        {
            tableelement("Compare Table Result"; "Compare Table Result")
            {
                XmlName = 'Table';
                UseTemporary = true;
                fieldelement(TableNo; "Compare Table Result"."Table No.")
                {
                }
                fieldelement(Result; "Compare Table Result".Result)
                {
                }
                fieldelement(Step1Action; "Compare Table Result"."Step 1 Action")
                {
                }
                fieldelement(Step2Action; "Compare Table Result"."Step 2 Action")
                {
                }
                fieldelement(UpgradeTableID; "Compare Table Result"."Upgrade Table ID")
                {
                }
                fieldelement(UpgradeCodeunitID; "Compare Table Result"."Upgrade Codeunit ID")
                {
                }
            }
            tableelement("Compare Field Result"; "Compare Field Result")
            {
                XmlName = 'Field';
                UseTemporary = true;
                fieldelement(TableNo; "Compare Field Result"."Table No.")
                {
                }
                fieldelement(FieldNo; "Compare Field Result"."Field No.")
                {
                }
                fieldelement(Result; "Compare Field Result".Result)
                {
                }
                fieldelement(CopyValueFromFieldNo; "Compare Field Result"."Copy Value From Field No.")
                {
                }
                fieldelement(Description; "Compare Field Result".Description)
                {
                }
            }
        }
    }


    procedure SetTables(var TempCompareTable: Record "Compare Table Result"; var TempCompareField: Record "Compare Field Result")
    begin
        "Compare Table Result".Copy(TempCompareTable, true);
        "Compare Field Result".Copy(TempCompareField, true);
    end;

    procedure GetTables(var TempCompareTable: Record "Compare Table Result"; var TempCompareField: Record "Compare Field Result")
    begin
        TempCompareTable.Copy("Compare Table Result", true);
        TempCompareField.Copy("Compare Field Result", true);
    end;
}

