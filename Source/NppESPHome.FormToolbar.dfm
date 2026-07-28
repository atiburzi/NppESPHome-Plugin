object FormToolbar: TFormToolbar
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Toolbar configuration'
  ClientHeight = 647
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
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
    OnClick = ButtonOkClick
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
    OnClick = ButtonOkClick
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
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'add'
        Name = 'add'
      end
      item
        CollectionIndex = 1
        CollectionName = 'clean'
        Name = 'clean'
      end
      item
        CollectionIndex = 2
        CollectionName = 'cleanall'
        Name = 'cleanall'
      end
      item
        CollectionIndex = 3
        CollectionName = 'compile'
        Name = 'compile'
      end
      item
        CollectionIndex = 4
        CollectionName = 'configure'
        Name = 'configure'
      end
      item
        CollectionIndex = 5
        CollectionName = 'explorer'
        Name = 'explorer'
      end
      item
        CollectionIndex = 6
        CollectionName = 'help'
        Name = 'help'
      end
      item
        CollectionIndex = 7
        CollectionName = 'open'
        Name = 'open'
      end
      item
        CollectionIndex = 8
        CollectionName = 'remove'
        Name = 'remove'
      end
      item
        CollectionIndex = 9
        CollectionName = 'run'
        Name = 'run'
      end
      item
        CollectionIndex = 10
        CollectionName = 'select'
        Name = 'select'
      end
      item
        CollectionIndex = 11
        CollectionName = 'showhide'
        Name = 'showhide'
      end
      item
        CollectionIndex = 12
        CollectionName = 'logs'
        Name = 'logs'
      end
      item
        CollectionIndex = 13
        CollectionName = 'terminal'
        Name = 'terminal'
      end
      item
        CollectionIndex = 14
        CollectionName = 'upgrade'
        Name = 'upgrade'
      end
      item
        CollectionIndex = 15
        CollectionName = 'upload'
        Name = 'upload'
      end>
    Width = 32
    Height = 32
    Left = 68
    Top = 40
  end
end
