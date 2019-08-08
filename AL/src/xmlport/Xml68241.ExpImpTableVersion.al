xmlport 68241 "Exp/Imp Table Version"
{
    Caption = 'Exp/Imp Table Version';
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    DefaultNamespace = 'http://navision.guru';
    UseDefaultNamespace = true;

    schema
    {
        textelement(TableVersion)
        {
            tableelement("Table Version"; "Table Version")
            {
                XmlName = 'Version';
                fieldelement(Code; "Table Version".Code)
                {
                }
                fieldelement(Name; "Table Version".Name)
                {
                }
                fieldelement(BaseVersion; "Table Version"."Base Version")
                {
                }
                fieldelement(BaseVersionCode; "Table Version"."Base Version Code")
                {
                }
                tableelement("Table Version Field"; "Table Version Field")
                {
                    LinkFields = "Table Version Code" = FIELD (Code);
                    LinkTable = "Table Version";
                    XmlName = 'Field';
                    fieldelement(VersionCode; "Table Version Field"."Table Version Code")
                    {
                    }
                    fieldelement(TableNo; "Table Version Field"."Table No.")
                    {
                    }
                    fieldelement(FieldNo; "Table Version Field"."Field No.")
                    {
                    }
                    fieldelement(FieldType; "Table Version Field"."Field Type")
                    {
                    }
                    fieldelement(TableName; "Table Version Field"."Table Name")
                    {
                    }
                    fieldelement(FieldName; "Table Version Field"."Field Name")
                    {
                    }
                    fieldelement(OptionString1; "Table Version Field"."Option String 1")
                    {
                    }
                    fieldelement(OptionString2; "Table Version Field"."Option String 2")
                    {
                    }
                    fieldelement(OptionString3; "Table Version Field"."Option String 3")
                    {
                    }
                    fieldelement(OptionString4; "Table Version Field"."Option String 4")
                    {
                    }
                }
                tableelement("Table Version Primary Key"; "Table Version Primary Key")
                {
                    LinkFields = "Table Version Code" = FIELD (Code);
                    LinkTable = "Table Version";
                    XmlName = 'Key';
                    fieldelement(VersionCode; "Table Version Primary Key"."Table Version Code")
                    {
                    }
                    fieldelement(TableNo; "Table Version Primary Key"."Table No.")
                    {
                    }
                    fieldelement(FieldIndexNo; "Table Version Primary Key"."Field Index No.")
                    {
                    }
                    fieldelement(FieldNo; "Table Version Primary Key"."Field No.")
                    {
                    }
                }
            }
        }
    }

    procedure SetVersion(VersionCode: Code[20])
    begin
        "Table Version".SetRange(Code, VersionCode);
    end;
}

