object FormToolbar: TFormToolbar
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Toolbar configuration'
  ClientHeight = 202
  ClientWidth = 1049
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Scaled = False
  OnCreate = FormCreate
  TextHeight = 15
  object LabelSelect: TLabel
    Left = 24
    Top = 86
    Width = 48
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Select Project'
    WordWrap = True
  end
  object LabelConfiguration: TLabel
    Left = 93
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Project Configuration'
    WordWrap = True
  end
  object LabelOpen: TLabel
    Left = 180
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Open'#13#10'Project'
    WordWrap = True
  end
  object LabelOpenDeps: TLabel
    Left = 267
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Open Project'#13#10' and Deps'
    WordWrap = True
  end
  object LabelRun: TLabel
    Left = 354
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'ESPHome'#13#10'Run'
    WordWrap = True
  end
  object LabelCompile: TLabel
    Left = 441
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'ESPHome'#13#10'Compile'
    WordWrap = True
  end
  object LabelUpload: TLabel
    Left = 528
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'ESPHome'#13#10'Upload'
    WordWrap = True
  end
  object LabelShowLogs: TLabel
    Left = 615
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'ESPHome'#13#10'Logs'
    WordWrap = True
  end
  object LabelClean: TLabel
    Left = 702
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'ESPHome'#13#10'Clean'
    WordWrap = True
  end
  object LabelVisit: TLabel
    Left = 788
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Visit'#13#10'Project'
    WordWrap = True
  end
  object LabelHelp: TLabel
    Left = 871
    Top = 87
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Online'#13#10'Documentation'
    WordWrap = True
  end
  object LabelUpgrade: TLabel
    Left = 958
    Top = 86
    Width = 81
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 'Upgrade'#13#10'ESPHome'
    WordWrap = True
  end
  object LabelNote: TLabel
    Left = 24
    Top = 134
    Width = 449
    Height = 15
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 
      'Note: Notepad++ must be restarted to make the changes of the too' +
      'lbar applied.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object ImageSelect: TImage
    Left = 24
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageConfigure: TImage
    Left = 110
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageOpen: TImage
    Left = 197
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageOpenDeps: TImage
    Left = 283
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageRun: TImage
    Left = 370
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageCompile: TImage
    Left = 456
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageUpload: TImage
    Left = 543
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageShowLogs: TImage
    Left = 629
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageClean: TImage
    Left = 716
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageVisit: TImage
    Left = 802
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageHelp: TImage
    Left = 889
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ImageUpgrade: TImage
    Left = 976
    Top = 7
    Width = 48
    Height = 48
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Proportional = True
  end
  object ButtonClose: TButton
    Left = 488
    Top = 165
    Width = 75
    Height = 25
    Caption = 'Close'
    ModalResult = 1
    TabOrder = 0
  end
  object CheckBoxSelect: TCheckBox
    Left = 40
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 1
    OnClick = CheckBoxSelectClick
  end
  object CheckBoxConfigure: TCheckBox
    Left = 126
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 2
    OnClick = CheckBoxConfigureClick
  end
  object CheckBoxOpen: TCheckBox
    Left = 213
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 3
    OnClick = CheckBoxOpenClick
  end
  object CheckBoxOpenDeps: TCheckBox
    Left = 299
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 4
    OnClick = CheckBoxOpenDepsClick
  end
  object CheckBoxRun: TCheckBox
    Left = 386
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 5
    OnClick = CheckBoxRunClick
  end
  object CheckBoxCompile: TCheckBox
    Left = 472
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 6
    OnClick = CheckBoxCompileClick
  end
  object CheckBoxUpload: TCheckBox
    Left = 559
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 7
    OnClick = CheckBoxUploadClick
  end
  object CheckBoxShowLogs: TCheckBox
    Left = 645
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 8
    OnClick = CheckBoxShowLogsClick
  end
  object CheckBoxClean: TCheckBox
    Left = 732
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 9
    OnClick = CheckBoxCleanClick
  end
  object CheckBoxVisit: TCheckBox
    Left = 818
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 10
    OnClick = CheckBoxVisitClick
  end
  object CheckBoxHelp: TCheckBox
    Left = 905
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 11
    OnClick = CheckBoxHelpClick
  end
  object CheckBoxUpgrade: TCheckBox
    Left = 992
    Top = 62
    Width = 17
    Height = 17
    TabOrder = 12
    OnClick = CheckBoxUpgradeClick
  end
end
