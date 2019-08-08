xmlport 60650 "Upgrade Project XmlPort"
{
    Format = Xml;
    DefaultNamespace = 'http://navision.guru';
    UseDefaultNamespace = true;
    Encoding = UTF8;
    Direction = Both;

    schema
    {
        textelement(UpgradeProject)
        {
            tableelement(ADVUpgradeProject; "Upgrade Project")
            {
                fieldelement(AppId; ADVUpgradeProject."App Id")
                {
                }
                tableelement(ADVUpgradeProjectTable; "Upgrade Project Table")
                {
                    LinkTable = ADVUpgradeProject;
                    LinkFields = "App Package Id" = Field ("App Package Id");
                    MinOccurs = Zero;

                    fieldelement(AppTableId; ADVUpgradeProjectTable."App Table Id")
                    {
                        FieldValidate = No;
                    }
                    fieldelement(UpgradeTableId; ADVUpgradeProjectTable."Upgrade Table Id")
                    {
                        FieldValidate = No;
                    }
                    fieldelement(UpgradeAction; ADVUpgradeProjectTable."Data Upgrade Method")
                    {
                    }

                    tableelement(ADVUpgradeProjectField; "Upgrade Project Field")
                    {
                        LinkTable = ADVUpgradeProjectTable;
                        LinkFields = "App Package Id" = Field ("App Package Id"), "App Table Id" = Field ("App Table Id");
                        MinOccurs = Zero;

                        fieldelement(AppFieldID; ADVUpgradeProjectField."App Field ID")
                        {
                            FieldValidate = No;
                        }
                        fieldelement(UpgradeFieldID; ADVUpgradeProjectField."Upgrade Field ID")
                        {
                            FieldValidate = No;
                        }
                        fieldelement(TransformationRule; ADVUpgradeProjectField."Transformation Rule")
                        {
                            FieldValidate = No;
                            trigger OnBeforePassField()
                            begin
                                if ADVUpgradeProjectField."Transformation Rule" <> '' then
                                    if not TempTransformationRule.Get(ADVUpgradeProjectField."Transformation Rule") then begin
                                        TransformationRule.Get(ADVUpgradeProjectField."Transformation Rule");
                                        TempTransformationRule := TransformationRule;
                                        TempTransformationRule.Insert();
                                    end;

                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if ADVUpgradeProjectField.GetWarning() <> '' then
                                currXMLport.Skip();
                        end;

                        trigger OnBeforeInsertRecord()
                        begin
                            ADVUpgradeProjectField."App Package Id" := ADVUpgradeProject."App Package Id";
                            ADVUpgradeProjectField."App Table Id" := ADVUpgradeProjectTable."App Table Id";
                            ADVUpgradeProjectField."Upgrade Table Id" := ADVUpgradeProjectTable."Upgrade Table Id";
                        end;
                    }
                    tableelement(ADVUpgradeProjectAppField; "Upgrade Project App Field")
                    {
                        LinkTable = ADVUpgradeProjectTable;
                        LinkFields = "App Package Id" = Field ("App Package Id"), "App Table Id" = Field ("App Table Id");
                        MinOccurs = Zero;

                        fieldelement(AppFieldID; ADVUpgradeProjectAppField."App Field ID")
                        {
                            FieldValidate = No;
                        }
                        trigger OnBeforeInsertRecord()
                        begin
                            ADVUpgradeProjectAppField."App Package Id" := ADVUpgradeProject."App Package Id";
                            ADVUpgradeProjectAppField."App Table Id" := ADVUpgradeProjectTable."App Table Id";
                        end;
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if ADVUpgradeProjectTable."Upgrade Table Id" = 0 then
                            currXMLport.Skip();
                    end;

                    trigger OnBeforeInsertRecord()
                    begin
                        ADVUpgradeProjectField."App Package Id" := ADVUpgradeProject."App Package Id";
                    end;

                }

                tableelement(TempTransformationRule; "Transformation Rule")
                {
                    UseTemporary = true;
                    MinOccurs = Zero;

                    fieldelement(Code; TempTransformationRule."Code")
                    {
                    }
                    fieldelement(Description; TempTransformationRule."Description")
                    {
                    }
                    fieldelement(TransformationType; TempTransformationRule."Transformation Type")
                    {
                    }
                    fieldelement(FindValue; TempTransformationRule."Find Value")
                    {
                    }
                    fieldelement(ReplaceValue; TempTransformationRule."Replace Value")
                    {
                    }
                    fieldelement(StartingText; TempTransformationRule."Starting Text")
                    {
                    }
                    fieldelement(EndingText; TempTransformationRule."Ending Text")
                    {
                    }
                    fieldelement(StartPosition; TempTransformationRule."Start Position")
                    {
                    }
                    fieldelement(Length; TempTransformationRule."Length")
                    {
                    }
                    fieldelement(DataFormat; TempTransformationRule."Data Format")
                    {
                    }
                    fieldelement(DataFormattingCulture; TempTransformationRule."Data Formatting Culture")
                    {
                    }
                    fieldelement(NextTransformationRule; TempTransformationRule."Next Transformation Rule")
                    {
                    }
                    trigger OnBeforeInsertRecord()
                    begin
                        if not TransformationRule.Get(TempTransformationRule.Code) then begin
                            TransformationRule := TempTransformationRule;
                            TransformationRule.Insert();
                        end;
                    end;
                }
            }
        }
    }

    var
        TransformationRule: Record "Transformation Rule";
}
