table 68246 "Data Upgrade Cue"
{
    Caption = 'Data Upgrade Cue';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Table Versions"; Integer)
        {
            CalcFormula = Count ("Table Version");
            Caption = 'Table Versions';
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "Version comparasions to -2013"; Integer)
        {
            CalcFormula = Count ("Version Comparison" WHERE ("Upgrade Code Version" = CONST ("To 2013 R2")));
            Caption = 'Version comparasions to -2013';
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Version comparasions to +2015"; Integer)
        {
            CalcFormula = Count ("Version Comparison" WHERE ("Upgrade Code Version" = CONST ("To 2015")));
            Caption = 'Version comparasions to +2015';
            FieldClass = FlowField;
        }
        field(5; "Upgrade Project"; Integer)
        {
            CalcFormula = Count ("Upgrade Project");
            Caption = 'Upgrade Project';
            FieldClass = FlowField;
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

