table 60651 "Upgrade Project Table"
{
    Caption = 'Upgrade Project Table';
    DataPerCompany = false;
    LookupPageId = "Upgrade Project Tables";

    fields
    {
        field(1; "App Package Id"; Guid)
        {
            Caption = 'App Package Id';
            DataClassification = SystemMetadata;
            TableRelation = "Upgrade Project"."App Package Id";
        }
        field(2; "App Table Id"; Integer)
        {
            Caption = 'App Table Id';
            NotBlank = true;
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = AllObj."Object ID" WHERE ("Object Type" = CONST (Table));
            trigger OnValidate()
            var
                ADVUpgradeProjMetadata: Codeunit "Upgrade Project Metadata";
            begin
                if not ADVUpgradeProjMetadata.GetMetadataFields(Rec) then
                    ADVUpgradeProjMetadata.GetAppTableFields(Rec);
                CalcFields("App Table Name");
            end;
        }
        field(4; "Upgrade Table Id"; Integer)
        {
            Caption = 'Upgrade Table Id';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = AllObj."Object ID" WHERE ("Object Type" = CONST (Table));
            trigger OnValidate()
            var
                ADVUpgradeProjFieldMgt: Codeunit "Upgrade Project Field Mgt.";
                ADVUpgradeProjAct: Codeunit "Upgrade Project Action";
            begin
                ADVUpgradeProjFieldMgt.InitTableFields(Rec);
                "Data Upgrade Method" := ADVUpgradeProjAct.SuggestDataUpgradeAction(Rec);
                CalcFields("Upgrade Table Name");
            end;
        }
        field(7; "App Table Name"; Text[250])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE ("Object Type" = CONST (Table), "Object ID" = FIELD ("App Table ID")));
            Caption = 'App Table Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(9; "Upgrade Table Name"; Text[250])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE ("Object Type" = CONST (Table),
                                                                           "Object ID" = FIELD ("Upgrade Table ID")));
            Caption = 'Upgrade Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; "Table Extension Metadata"; Blob)
        {
            DataClassification = SystemMetadata;
        }
        field(11; "Data Upgrade Method"; Option)
        {
            Caption = 'Data Upgrade Method';
            DataClassification = EndUserIdentifiableInformation;
            OptionMembers = Ignore,Copy,Move;
            OptionCaption = 'Ignore,Copy,Move';
        }
    }

    keys
    {
        key(PK; "App Package Id", "App Table Id")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "App Table Id", "App Table Name")
        {
        }
        fieldgroup(Brick; "App Table Id", "App Table Name")
        {
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        DeleteFields(Rec);
    end;

    trigger OnRename()
    begin
        DeleteFields(xRec);
    end;

    local procedure DeleteFields(UpgradeTable: Record "Upgrade Project Table")
    var
        ADVUpgradeProjField: Record "Upgrade Project Field";
        ADVUpgradeProjAppField: Record "Upgrade Project App Field";
    begin
        ADVUpgradeProjField.SetRange("App Package Id", UpgradeTable."App Package Id");
        ADVUpgradeProjField.SetRange("App Table Id", UpgradeTable."App Table Id");
        if not ADVUpgradeProjField.IsEmpty() then
            ADVUpgradeProjField.DeleteAll();

        ADVUpgradeProjAppField.SetRange("App Package Id", UpgradeTable."App Package Id");
        ADVUpgradeProjAppField.SetRange("App Table Id", UpgradeTable."App Table Id");
        if not ADVUpgradeProjAppField.IsEmpty() then
            ADVUpgradeProjAppField.DeleteAll();
    end;

    procedure GetJobQueueEntryStatus(): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Record ID to Process", RecordId());
        if JobQueueEntry.FindFirst() then
            exit(Format(JobQueueEntry.Status));
    end;

    procedure JobQueueEntryDrillDown()
    var
        JobQueueEntry: Record "Job Queue Entry";
        PageMgt: Codeunit "Page Management";
    begin
        JobQueueEntry.SetRange("Record ID to Process", RecordId());
        if JobQueueEntry.FindFirst() then
            Page.Run(PageMgt.GetDefaultCardPageID(Database::"Job Queue Entry"), JobQueueEntry);
    end;
}