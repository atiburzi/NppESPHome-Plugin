object FormSelection: TFormSelection
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Project Selection'
  ClientHeight = 152
  ClientWidth = 616
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ShowHint = True
  OnCreate = FormCreate
  TextHeight = 15
  object GroupBoxCurrentProject: TGroupBox
    Left = 8
    Top = 8
    Width = 601
    Height = 97
    Caption = 'Current Project'
    TabOrder = 0
    object ComboBoxProject: TComboBox
      Left = 16
      Top = 22
      Width = 570
      Height = 26
      Style = csOwnerDrawFixed
      DropDownCount = 10
      ItemHeight = 20
      ParentColor = True
      TabOrder = 0
      OnChange = ComboBoxProjectChange
    end
    object ButtonAddProject: TButton
      Left = 312
      Top = 54
      Width = 121
      Height = 27
      Hint = 
        'Add a new project to the known list of projects, selecting an ex' +
        'isting YAML ESPHome project file'
      Caption = '&Add Project'
      TabOrder = 1
      OnClick = ButtonAddProjectClick
    end
    object ButtonRemoveProject: TButton
      Left = 465
      Top = 54
      Width = 121
      Height = 27
      Hint = 
        'Remove the current selected project from the list of the known o' +
        'nes'
      Caption = '&Remove Project'
      TabOrder = 2
      OnClick = ButtonRemoveProjectClick
    end
  end
  object ButtonClose: TButton
    Left = 273
    Top = 119
    Width = 81
    Height = 25
    Cancel = True
    Caption = 'Close'
    ModalResult = 8
    TabOrder = 1
  end
  object FileOpenDialogProject: TFileOpenDialog
    DefaultExtension = '.yaml'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'ESPHome Project Files'
        FileMask = '*.yaml'
      end
      item
        DisplayName = 'ESPHome Project Files'
        FileMask = '*.yml'
      end>
    Options = [fdoStrictFileTypes, fdoForceFileSystem, fdoFileMustExist]
    Left = 80
    Top = 64
  end
end
