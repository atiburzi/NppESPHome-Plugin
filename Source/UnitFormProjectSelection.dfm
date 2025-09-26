object FormProjectSelection: TFormProjectSelection
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
    object ComboBoxProject: TComboBoxEx
      Left = 16
      Top = 24
      Width = 570
      Height = 24
      ItemsEx.SortType = stText
      ItemsEx = <>
      Style = csExDropDownList
      TabOrder = 0
      OnChange = ComboBoxProjectChange
      DropDownCount = 10
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
    Left = 240
    Top = 112
    Width = 129
    Height = 26
    Hint = 'Close this dialog window'
    Cancel = True
    Caption = '&Close'
    ModalResult = 1
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
    Left = 40
    Top = 88
  end
end
