codeunit 60655 "Upgrade Project Action"
{
    trigger OnRun()
    begin

    end;

    procedure UpdateProjectSuggestion(ADVUpgradeProj: Record "Upgrade Project")
    var
        ADVUpgradeProjTable: Record "Upgrade Project Table";
    begin
        with ADVUpgradeProjTable do begin
            SetRange("App Package Id", ADVUpgradeProj."App Package Id");
            if FindSet(true) then
                repeat
                    "Data Upgrade Method" := SuggestDataUpgradeAction(ADVUpgradeProjTable);
                    OnAfterSuggestAction(ADVUpgradeProjTable);
                    Modify();
                until Next() = 0;
        end;
    end;

    procedure SuggestDataUpgradeAction(ADVUpgradeProjTable: Record "Upgrade Project Table"): Integer
    var
        ADVUpgradeProjField: Record "Upgrade Project Field";
        DataUpgradeOption: Option Ignore,Copy,Move;
        HasWarning: Boolean;
    begin
        if ADVUpgradeProjTable."Upgrade Table Id" = 0 then exit(DataUpgradeOption::Ignore);
        with ADVUpgradeProjField do begin
            SetRange("App Package Id", ADVUpgradeProjTable."App Package Id");
            SetRange("App Table Id", ADVUpgradeProjTable."App Table Id");
            if IsEmpty() then exit(DataUpgradeOption::Ignore);
            FindSet();
            repeat
                HasWarning := HasWarning or (GetWarning() <> '');
            until Next() = 0;
            if HasWarning then
                exit(DataUpgradeOption::Copy)
            else
                exit(DataUpgradeOption::Move);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSuggestAction(var ADVUpgradeProjTable: Record "Upgrade Project Table")
    begin

    end;

}