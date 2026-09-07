object FormToolbar: TFormToolbar
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Toolbar configuration'
  ClientHeight = 802
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 20
  object LabelInfo: TLabel
    Left = 11
    Top = 701
    Width = 503
    Height = 42
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    AutoSize = False
    Caption = 
      'Use checkbox to enable/disable the button.'#13#10'Use mouse Drag&&Drop' +
      ' or Ctrl+Up/Down to exchange the buttons order.'
    WordWrap = True
  end
  object TreeViewToolbar: TTreeView
    Left = 11
    Top = 11
    Width = 504
    Height = 680
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    CheckBoxes = True
    DragMode = dmAutomatic
    Images = VirtualImageList
    Indent = 30
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
    Left = 200
    Top = 773
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = ButtonSaveClick
  end
  object ButtonCancel: TButton
    Left = 421
    Top = 773
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object ButtonApply: TButton
    Left = 301
    Top = 773
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '&Apply'
    TabOrder = 3
    OnClick = ButtonSaveClick
  end
  object ButtonReset: TButton
    Left = 11
    Top = 773
    Width = 120
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '&Reset toolbar'
    TabOrder = 1
    OnClick = ButtonResetClick
  end
  object VirtualImageList: TVirtualImageList
    AutoFill = True
    Images = <>
    Width = 40
    Height = 40
    Left = 68
    Top = 40
  end
end
