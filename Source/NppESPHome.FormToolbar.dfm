object FormToolbar: TFormToolbar
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Toolbar configuration'
  ClientHeight = 654
  ClientWidth = 421
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object LabelInfo: TLabel
    Left = 9
    Top = 561
    Width = 402
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    AutoSize = False
    Caption = 
      'Use checkbox to enable/disable the button.'#13#10'Use mouse Drag&&Drop' +
      ' or Ctrl+Up/Down to exchange the buttons order.'
    WordWrap = True
  end
  object TreeViewToolbar: TTreeView
    Left = 9
    Top = 9
    Width = 403
    Height = 544
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    CheckBoxes = True
    DragMode = dmAutomatic
    Images = VirtualImageList
    Indent = 24
    ParentColor = True
    RowSelect = True
    ShowButtons = False
    ShowLines = False
    ShowRoot = False
    TabOrder = 0
    OnDragDrop = TreeViewToolbarDragDrop
    OnDragOver = TreeViewToolbarDragOver
    OnEndDrag = TreeViewToolbarEndDrag
    OnKeyDown = TreeViewToolbarKeyDown
    OnMouseDown = TreeViewToolbarMouseDown
    OnStartDrag = TreeViewToolbarStartDrag
  end
  object ButtonOk: TButton
    Left = 160
    Top = 618
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = ButtonSaveClick
  end
  object ButtonCancel: TButton
    Left = 337
    Top = 618
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object ButtonApply: TButton
    Left = 241
    Top = 618
    Width = 75
    Height = 25
    Caption = '&Apply'
    TabOrder = 3
    OnClick = ButtonSaveClick
  end
  object ButtonReset: TButton
    Left = 9
    Top = 618
    Width = 96
    Height = 25
    Caption = '&Reset toolbar'
    TabOrder = 1
    OnClick = ButtonResetClick
  end
  object VirtualImageList: TVirtualImageList
    AutoFill = True
    Images = <>
    Width = 32
    Height = 32
    Left = 54
    Top = 32
  end
end
