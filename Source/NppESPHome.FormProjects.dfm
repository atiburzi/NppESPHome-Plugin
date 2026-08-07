object FormProjects: TFormProjects
  Left = 0
  Top = 0
  Anchors = [akTop, akRight]
  Caption = 'NppESPHome Plugin'
  ClientHeight = 1111
  ClientWidth = 483
  Color = clBtnFace
  DoubleBuffered = True
  DoubleBufferedMode = dbmRequested
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter: TSplitter
    Left = 0
    Top = 529
    Width = 483
    Height = 8
    Cursor = crVSplit
    Align = alTop
    AutoSnap = False
    Beveled = True
    ResizeStyle = rsUpdate
    OnMoved = SplitterMoved
  end
  object ToolBarCommands: TToolBar
    Left = 0
    Top = 0
    Width = 483
    Height = 29
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ButtonHeight = 36
    ButtonWidth = 37
    DoubleBuffered = True
    DrawingStyle = dsGradient
    Flat = False
    GradientEndColor = clBtnFace
    GradientStartColor = clBtnFace
    HotTrackColor = clActiveCaption
    Images = VirtualImageList24
    List = True
    ParentDoubleBuffered = False
    AllowTextButtons = True
    TabOrder = 0
    Transparent = True
    Wrapable = False
    object ToolButtonOpen: TToolButton
      Left = 0
      Top = 0
      Action = ActionOpen
    end
    object ToolButtonSep0: TToolButton
      Left = 32
      Top = 0
      Width = 8
      ImageIndex = 8
      ImageName = 'dependency'
      Style = tbsSeparator
    end
    object ToolButtonAddDeps: TToolButton
      Left = 40
      Top = 0
      Action = ActionAddDeps
    end
    object ToolButtonRemoveDep: TToolButton
      Left = 72
      Top = 0
      Action = ActionRemoveDep
    end
    object ToolButtonSep1: TToolButton
      Left = 104
      Top = 0
      Width = 5
      ImageName = 'remove'
      Style = tbsSeparator
    end
    object ToolButtonRun: TToolButton
      Left = 109
      Top = 0
      HelpType = htKeyword
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Action = ActionRun
    end
    object ToolButtonCompile: TToolButton
      Left = 141
      Top = 0
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Action = ActionCompile
    end
    object ToolButtonUpload: TToolButton
      Left = 173
      Top = 0
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Action = ActionUpload
    end
    object ToolButtonShowLogs: TToolButton
      Left = 205
      Top = 0
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Action = ActionShowLogs
    end
    object ToolButtonClean: TToolButton
      Left = 237
      Top = 0
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Action = ActionClean
    end
    object ToolButtonSep2: TToolButton
      Left = 269
      Top = 0
      Width = 6
      Style = tbsSeparator
    end
    object ToolButtonAddPrj: TToolButton
      Left = 275
      Top = 0
      Action = ActionAddProject
    end
    object ToolButtonRemovePrj: TToolButton
      Left = 307
      Top = 0
      Action = ActionRemoveProject
    end
    object ToolButtonSep3: TToolButton
      Left = 339
      Top = 0
      Width = 8
      Style = tbsSeparator
    end
    object ToolButtonSettings: TToolButton
      Left = 347
      Top = 0
      Action = ActionSettings
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 29
    Width = 483
    Height = 500
    Align = alTop
    BevelOuter = bvNone
    DoubleBuffered = True
    DoubleBufferedMode = dbmRequested
    ParentColor = True
    ParentDoubleBuffered = False
    TabOrder = 1
    object GroupBoxProjects: TGroupBox
      Left = 0
      Top = 0
      Width = 483
      Height = 494
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Active Project'
      DoubleBufferedMode = dbmRequested
      TabOrder = 0
      object VirtualStringTreeProjects: TVirtualStringTree
        Left = 2
        Top = 17
        Width = 479
        Height = 475
        Align = alClient
        BorderStyle = bsNone
        Colors.DropMarkColor = clWhite
        Colors.DropTargetColor = clCream
        Colors.DropTargetBorderColor = clWhite
        Colors.FocusedSelectionColor = clGrayText
        Colors.FocusedSelectionBorderColor = clGrayText
        Colors.SelectionRectangleBlendColor = clMenuHighlight
        Colors.SelectionRectangleBorderColor = clActiveCaption
        DefaultNodeHeight = 21
        Header.AutoSizeIndex = 0
        Header.Height = 15
        Header.MainColumn = -1
        HintMode = hmHint
        Images = VirtualImageList20
        ParentColor = True
        TabOrder = 0
        TreeOptions.PaintOptions = [toHideFocusRect, toShowDropmark, toShowRoot, toShowTreeLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
        TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect, toAlwaysSelectNode, toSelectNextNodeOnRemoval]
        OnChange = VirtualStringTreeProjectsChange
        OnCollapsing = VirtualStringTreeProjectsCollapsing
        OnCompareNodes = VirtualStringTreeProjectsCompareNodes
        OnDblClick = VirtualStringTreeProjectsDblClick
        OnGetText = VirtualStringTreeProjectsGetText
        OnGetImageIndex = VirtualStringTreeProjectsGetImageIndex
        OnGetHint = VirtualStringTreeProjectsGetHint
        OnGetPopupMenu = VirtualStringTreeProjectsGetPopupMenu
        OnNodeClick = VirtualStringTreeProjectsNodeClick
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <>
      end
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 537
    Width = 483
    Height = 574
    Align = alClient
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    DoubleBufferedMode = dbmRequested
    ParentColor = True
    TabOrder = 2
    DesignSize = (
      483
      574)
    object GroupBoxTemplates: TGroupBox
      Left = 0
      Top = 6
      Width = 479
      Height = 565
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Templates'
      DoubleBufferedMode = dbmRequested
      TabOrder = 0
      DesignSize = (
        479
        565)
      object LabelFilter: TLabel
        Left = 11
        Top = 24
        Width = 67
        Height = 15
        Caption = 'Filter by text:'
      end
      object LabelCategory: TLabel
        Left = 11
        Top = 51
        Width = 94
        Height = 15
        Caption = 'Filter by category:'
        FocusControl = ComboBoxCategories
      end
      object ButtonMenuTemplates: TSpeedButton
        Left = 451
        Top = 22
        Width = 20
        Height = 48
        Anchors = [akTop, akRight]
        ImageIndex = 34
        ImageName = 'more'
        Images = VirtualImageList24
        Flat = True
        OnClick = ButtonMenuTemplatesClick
      end
      object EditTextFilter: TButtonedEdit
        Left = 115
        Top = 22
        Width = 333
        Height = 20
        Anchors = [akLeft, akTop, akRight]
        AutoSelect = False
        AutoSize = False
        Ctl3D = False
        HideSelection = False
        Images = VirtualImageList16
        ParentColor = True
        ParentCtl3D = False
        RightButton.ImageIndex = 2
        RightButton.ImageName = 'cancel'
        RightButton.Visible = True
        TabOrder = 0
        OnChange = EditTextFilterChange
        OnRightButtonClick = EditTextFilterRightButtonClick
      end
      object ComboBoxCategories: TComboBox
        Left = 115
        Top = 48
        Width = 333
        Height = 26
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        ParentColor = True
        Sorted = True
        TabOrder = 1
        OnChange = ComboBoxCategoriesChange
      end
      object PanelStaticText: TPanel
        Left = 6
        Top = 480
        Width = 467
        Height = 78
        Anchors = [akLeft, akRight, akBottom]
        ParentColor = True
        TabOrder = 2
        object StaticTextDescription: TJvLinkLabel
          Left = 1
          Top = 1
          Width = 465
          Height = 76
          Caption = ''
          Text.Strings = (
            '')
          Transparent = True
          LinkColor = clHotLight
          LinkColorClicked = clFuchsia
          LinkColorHot = clRed
          OnLinkClick = StaticTextDescriptionLinkClick
          Align = alClient
        end
      end
      object PanelTemplates: TPanel
        Left = 6
        Top = 77
        Width = 467
        Height = 397
        Anchors = [akLeft, akTop, akRight, akBottom]
        ParentColor = True
        ShowCaption = False
        TabOrder = 3
        object VirtualStringTreeTemplates: TVirtualStringTree
          Left = 1
          Top = 1
          Width = 465
          Height = 395
          Align = alClient
          Colors.GridLineColor = clMedGray
          DefaultNodeHeight = 19
          Header.AutoSizeIndex = 0
          Header.Font.Charset = DEFAULT_CHARSET
          Header.Font.Color = clWindowText
          Header.Font.Height = -12
          Header.Font.Name = 'Segoe UI'
          Header.Font.Style = []
          Header.Options = [hoColumnResize, hoRestrictDrag, hoShowImages, hoVisible, hoDisableAnimatedResize]
          Header.ParentFont = False
          Header.SortColumn = 0
          HintMode = hmHint
          Images = VirtualImageList16
          ParentColor = True
          TabOrder = 0
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
          TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toShowDropmark, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
          TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect, toSelectNextNodeOnRemoval]
          OnChange = VirtualStringTreeTemplatesChange
          OnDblClick = VirtualStringTreeTemplatesDblClick
          OnEnter = VirtualStringTreeTemplatesDblClick
          OnGetText = VirtualStringTreeTemplatesGetText
          OnGetHint = VirtualStringTreeTemplatesGetHint
          Touch.InteractiveGestures = [igPan, igPressAndTap]
          Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
          Columns = <
            item
              CheckType = ctNone
              Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable, coStyleColor]
              Position = 0
              Text = 'Component'
              Width = 300
            end
            item
              CheckType = ctNone
              Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable, coStyleColor]
              Position = 1
              Text = 'Category'
              Width = 300
            end>
        end
      end
    end
  end
  object VirtualImageList24: TVirtualImageList
    AutoFill = True
    DisabledOpacity = 155
    DisabledGrayscale = True
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'adddep'
        Name = 'adddep'
      end
      item
        CollectionIndex = 1
        CollectionName = 'addprj'
        Name = 'addprj'
      end
      item
        CollectionIndex = 2
        CollectionName = 'cancel'
        Name = 'cancel'
      end
      item
        CollectionIndex = 3
        CollectionName = 'clean'
        Name = 'clean'
      end
      item
        CollectionIndex = 4
        CollectionName = 'cleanall'
        Name = 'cleanall'
      end
      item
        CollectionIndex = 5
        CollectionName = 'compile'
        Name = 'compile'
      end
      item
        CollectionIndex = 6
        CollectionName = 'configure'
        Name = 'configure'
      end
      item
        CollectionIndex = 7
        CollectionName = 'console'
        Name = 'console'
      end
      item
        CollectionIndex = 8
        CollectionName = 'dependency'
        Name = 'dependency'
      end
      item
        CollectionIndex = 9
        CollectionName = 'esphome'
        Name = 'esphome'
      end
      item
        CollectionIndex = 10
        CollectionName = 'explorer'
        Name = 'explorer'
      end
      item
        CollectionIndex = 11
        CollectionName = 'file_any'
        Name = 'file_any'
      end
      item
        CollectionIndex = 12
        CollectionName = 'file_cpp'
        Name = 'file_cpp'
      end
      item
        CollectionIndex = 13
        CollectionName = 'file_csv'
        Name = 'file_csv'
      end
      item
        CollectionIndex = 14
        CollectionName = 'file_h'
        Name = 'file_h'
      end
      item
        CollectionIndex = 15
        CollectionName = 'file_inc'
        Name = 'file_inc'
      end
      item
        CollectionIndex = 16
        CollectionName = 'file_txt'
        Name = 'file_txt'
      end
      item
        CollectionIndex = 17
        CollectionName = 'file_yaml'
        Name = 'file_yaml'
      end
      item
        CollectionIndex = 18
        CollectionName = 'help'
        Name = 'help'
      end
      item
        CollectionIndex = 19
        CollectionName = 'logs'
        Name = 'logs'
      end
      item
        CollectionIndex = 20
        CollectionName = 'mc_bk72xx'
        Name = 'mc_bk72xx'
      end
      item
        CollectionIndex = 21
        CollectionName = 'mc_esp32'
        Name = 'mc_esp32'
      end
      item
        CollectionIndex = 22
        CollectionName = 'mc_esp8266'
        Name = 'mc_esp8266'
      end
      item
        CollectionIndex = 23
        CollectionName = 'mc_host'
        Name = 'mc_host'
      end
      item
        CollectionIndex = 24
        CollectionName = 'mc_ln882x'
        Name = 'mc_ln882x'
      end
      item
        CollectionIndex = 25
        CollectionName = 'mc_rp2040'
        Name = 'mc_rp2040'
      end
      item
        CollectionIndex = 26
        CollectionName = 'mc_rtl87xx'
        Name = 'mc_rtl87xx'
      end
      item
        CollectionIndex = 27
        CollectionName = 'mi_bk72xx'
        Name = 'mi_bk72xx'
      end
      item
        CollectionIndex = 28
        CollectionName = 'mi_esp32'
        Name = 'mi_esp32'
      end
      item
        CollectionIndex = 29
        CollectionName = 'mi_esp8266'
        Name = 'mi_esp8266'
      end
      item
        CollectionIndex = 30
        CollectionName = 'mi_host'
        Name = 'mi_host'
      end
      item
        CollectionIndex = 31
        CollectionName = 'mi_ln882x'
        Name = 'mi_ln882x'
      end
      item
        CollectionIndex = 32
        CollectionName = 'mi_rp2040'
        Name = 'mi_rp2040'
      end
      item
        CollectionIndex = 33
        CollectionName = 'mi_rtl87xx'
        Name = 'mi_rtl87xx'
      end
      item
        CollectionIndex = 34
        CollectionName = 'more'
        Name = 'more'
      end
      item
        CollectionIndex = 35
        CollectionName = 'none'
        Name = 'none'
      end
      item
        CollectionIndex = 36
        CollectionName = 'npp'
        Name = 'npp'
      end
      item
        CollectionIndex = 37
        CollectionName = 'nppesphome'
        Name = 'nppesphome'
      end
      item
        CollectionIndex = 38
        CollectionName = 'open'
        Name = 'open'
      end
      item
        CollectionIndex = 39
        CollectionName = 'project'
        Name = 'project'
      end
      item
        CollectionIndex = 40
        CollectionName = 'refreshusb'
        Name = 'refreshusb'
      end
      item
        CollectionIndex = 41
        CollectionName = 'removedep'
        Name = 'removedep'
      end
      item
        CollectionIndex = 42
        CollectionName = 'removeprj'
        Name = 'removeprj'
      end
      item
        CollectionIndex = 43
        CollectionName = 'run'
        Name = 'run'
      end
      item
        CollectionIndex = 44
        CollectionName = 'select'
        Name = 'select'
      end
      item
        CollectionIndex = 45
        CollectionName = 'serial'
        Name = 'serial'
      end
      item
        CollectionIndex = 46
        CollectionName = 'showhide'
        Name = 'showhide'
      end
      item
        CollectionIndex = 47
        CollectionName = 'terminal'
        Name = 'terminal'
      end
      item
        CollectionIndex = 48
        CollectionName = 'upgrade'
        Name = 'upgrade'
      end
      item
        CollectionIndex = 49
        CollectionName = 'upload'
        Name = 'upload'
      end
      item
        CollectionIndex = 50
        CollectionName = 'wifi'
        Name = 'wifi'
      end
      item
        CollectionIndex = 51
        CollectionName = 'window'
        Name = 'window'
      end>
    ImageCollection = Resources.StandardImages
    PreserveItems = True
    Width = 24
    Height = 24
    Left = 280
    Top = 320
  end
  object VirtualImageList16: TVirtualImageList
    AutoFill = True
    DisabledOpacity = 155
    DisabledGrayscale = True
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'adddep'
        Name = 'adddep'
      end
      item
        CollectionIndex = 1
        CollectionName = 'addprj'
        Name = 'addprj'
      end
      item
        CollectionIndex = 2
        CollectionName = 'cancel'
        Name = 'cancel'
      end
      item
        CollectionIndex = 3
        CollectionName = 'clean'
        Name = 'clean'
      end
      item
        CollectionIndex = 4
        CollectionName = 'cleanall'
        Name = 'cleanall'
      end
      item
        CollectionIndex = 5
        CollectionName = 'compile'
        Name = 'compile'
      end
      item
        CollectionIndex = 6
        CollectionName = 'configure'
        Name = 'configure'
      end
      item
        CollectionIndex = 7
        CollectionName = 'console'
        Name = 'console'
      end
      item
        CollectionIndex = 8
        CollectionName = 'dependency'
        Name = 'dependency'
      end
      item
        CollectionIndex = 9
        CollectionName = 'esphome'
        Name = 'esphome'
      end
      item
        CollectionIndex = 10
        CollectionName = 'explorer'
        Name = 'explorer'
      end
      item
        CollectionIndex = 11
        CollectionName = 'file_any'
        Name = 'file_any'
      end
      item
        CollectionIndex = 12
        CollectionName = 'file_cpp'
        Name = 'file_cpp'
      end
      item
        CollectionIndex = 13
        CollectionName = 'file_csv'
        Name = 'file_csv'
      end
      item
        CollectionIndex = 14
        CollectionName = 'file_h'
        Name = 'file_h'
      end
      item
        CollectionIndex = 15
        CollectionName = 'file_inc'
        Name = 'file_inc'
      end
      item
        CollectionIndex = 16
        CollectionName = 'file_txt'
        Name = 'file_txt'
      end
      item
        CollectionIndex = 17
        CollectionName = 'file_yaml'
        Name = 'file_yaml'
      end
      item
        CollectionIndex = 18
        CollectionName = 'help'
        Name = 'help'
      end
      item
        CollectionIndex = 19
        CollectionName = 'logs'
        Name = 'logs'
      end
      item
        CollectionIndex = 20
        CollectionName = 'mc_bk72xx'
        Name = 'mc_bk72xx'
      end
      item
        CollectionIndex = 21
        CollectionName = 'mc_esp32'
        Name = 'mc_esp32'
      end
      item
        CollectionIndex = 22
        CollectionName = 'mc_esp8266'
        Name = 'mc_esp8266'
      end
      item
        CollectionIndex = 23
        CollectionName = 'mc_host'
        Name = 'mc_host'
      end
      item
        CollectionIndex = 24
        CollectionName = 'mc_ln882x'
        Name = 'mc_ln882x'
      end
      item
        CollectionIndex = 25
        CollectionName = 'mc_rp2040'
        Name = 'mc_rp2040'
      end
      item
        CollectionIndex = 26
        CollectionName = 'mc_rtl87xx'
        Name = 'mc_rtl87xx'
      end
      item
        CollectionIndex = 27
        CollectionName = 'mi_bk72xx'
        Name = 'mi_bk72xx'
      end
      item
        CollectionIndex = 28
        CollectionName = 'mi_esp32'
        Name = 'mi_esp32'
      end
      item
        CollectionIndex = 29
        CollectionName = 'mi_esp8266'
        Name = 'mi_esp8266'
      end
      item
        CollectionIndex = 30
        CollectionName = 'mi_host'
        Name = 'mi_host'
      end
      item
        CollectionIndex = 31
        CollectionName = 'mi_ln882x'
        Name = 'mi_ln882x'
      end
      item
        CollectionIndex = 32
        CollectionName = 'mi_rp2040'
        Name = 'mi_rp2040'
      end
      item
        CollectionIndex = 33
        CollectionName = 'mi_rtl87xx'
        Name = 'mi_rtl87xx'
      end
      item
        CollectionIndex = 34
        CollectionName = 'more'
        Name = 'more'
      end
      item
        CollectionIndex = 35
        CollectionName = 'none'
        Name = 'none'
      end
      item
        CollectionIndex = 36
        CollectionName = 'npp'
        Name = 'npp'
      end
      item
        CollectionIndex = 37
        CollectionName = 'nppesphome'
        Name = 'nppesphome'
      end
      item
        CollectionIndex = 38
        CollectionName = 'open'
        Name = 'open'
      end
      item
        CollectionIndex = 39
        CollectionName = 'project'
        Name = 'project'
      end
      item
        CollectionIndex = 40
        CollectionName = 'refreshusb'
        Name = 'refreshusb'
      end
      item
        CollectionIndex = 41
        CollectionName = 'removedep'
        Name = 'removedep'
      end
      item
        CollectionIndex = 42
        CollectionName = 'removeprj'
        Name = 'removeprj'
      end
      item
        CollectionIndex = 43
        CollectionName = 'run'
        Name = 'run'
      end
      item
        CollectionIndex = 44
        CollectionName = 'select'
        Name = 'select'
      end
      item
        CollectionIndex = 45
        CollectionName = 'serial'
        Name = 'serial'
      end
      item
        CollectionIndex = 46
        CollectionName = 'showhide'
        Name = 'showhide'
      end
      item
        CollectionIndex = 47
        CollectionName = 'terminal'
        Name = 'terminal'
      end
      item
        CollectionIndex = 48
        CollectionName = 'upgrade'
        Name = 'upgrade'
      end
      item
        CollectionIndex = 49
        CollectionName = 'upload'
        Name = 'upload'
      end
      item
        CollectionIndex = 50
        CollectionName = 'wifi'
        Name = 'wifi'
      end
      item
        CollectionIndex = 51
        CollectionName = 'window'
        Name = 'window'
      end>
    ImageCollection = Resources.StandardImages
    PreserveItems = True
    Left = 280
    Top = 176
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
    Title = 'Select an existing ESPHome project file'
    Left = 368
    Top = 72
  end
  object PopupMenuProjects: TPopupMenu
    Images = VirtualImageList20
    Left = 64
    Top = 72
    object PopupMenuOpen: TMenuItem
      Action = ActionOpen
    end
    object PopupMenuN1: TMenuItem
      Caption = '-'
    end
    object PopupMenuRun: TMenuItem
      Action = ActionRun
    end
    object PopupMenuCompile: TMenuItem
      Action = ActionCompile
    end
    object PopupMenuUpload: TMenuItem
      Action = ActionUpload
    end
    object PopupMenuShowLogs: TMenuItem
      Action = ActionShowLogs
    end
    object PopupMenuClean: TMenuItem
      Action = ActionClean
    end
    object PopupMenuCleanAll: TMenuItem
      Action = ActionCleanAll
    end
    object PopupMenuN2: TMenuItem
      Caption = '-'
    end
    object PopupMenuRefreshDevice: TMenuItem
      Action = ActionAddDeps
    end
    object PopupMenuN3: TMenuItem
      Caption = '-'
    end
    object PopupMenuSettings: TMenuItem
      Action = ActionSettings
    end
    object PopupMenuN4: TMenuItem
      Caption = '-'
    end
    object PopupMenuRemoveProject: TMenuItem
      Action = ActionRemoveProject
    end
  end
  object ActionList: TActionList
    Images = VirtualImageList20
    Left = 216
    Top = 72
    object ActionOpen: TAction
      Caption = 'Open project files'
      Hint = 'Open project files (main file and dependencies)'
      ImageIndex = 38
      ImageName = 'open'
      OnExecute = ActionOpenExecute
    end
    object ActionRun: TAction
      Caption = 'Run project'
      Hint = 'Starts ESPHome console with "run" command'
      ImageIndex = 43
      ImageName = 'run'
      OnExecute = ActionRunExecute
    end
    object ActionCompile: TAction
      Caption = 'Compile project'
      Hint = 'Starts ESPHome console with "compile" command'
      ImageIndex = 5
      ImageName = 'compile'
      OnExecute = ActionCompileExecute
    end
    object ActionUpload: TAction
      Caption = 'Upload last compile project'
      Hint = 'Starts ESPHome console with "upload" command'
      ImageIndex = 49
      ImageName = 'upload'
      OnExecute = ActionUploadExecute
    end
    object ActionShowLogs: TAction
      Caption = 'Show device logs'
      Hint = 'Starts ESPHome console with "logs" command'
      ImageIndex = 19
      ImageName = 'logs'
      OnExecute = ActionShowLogsExecute
    end
    object ActionClean: TAction
      Caption = 'Clean project files'
      Hint = 'Starts ESPHome console with "clean" command'
      ImageIndex = 3
      ImageName = 'clean'
      OnExecute = ActionCleanExecute
    end
    object ActionCleanAll: TAction
      Caption = 'Perform Clean All for project files'
      Hint = 'Starts ESPHome console with "clean-all" command'
      ImageIndex = 4
      ImageName = 'cleanall'
      OnExecute = ActionCleanAllExecute
    end
    object ActionSettings: TAction
      Caption = 'Project options'
      Hint = 'Open the configuration settings of the current ESPHome project'
      ImageIndex = 6
      ImageName = 'configure'
      OnExecute = ActionSettingsExecute
    end
    object ActionAddProject: TAction
      Caption = 'Add new project'
      Hint = 'Add a new project files among the known ESPHome projects'
      ImageIndex = 1
      ImageName = 'addprj'
      OnExecute = ActionAddProjectExecute
    end
    object ActionRemoveProject: TAction
      Caption = 'Remove selected project'
      Hint = 'Remove the current ESPHome project from the known ones'
      ImageIndex = 42
      ImageName = 'removeprj'
      OnExecute = ActionRemoveProjectExecute
    end
    object ActionAddDeps: TAction
      Caption = 'Add new dependencies files'
      Hint = 'Add a dependency file to the current ESPHome project'
      ImageIndex = 0
      ImageName = 'adddep'
      OnExecute = ActionAddDepsExecute
    end
    object ActionRemoveDep: TAction
      Caption = 'Remove selected dependency'
      Hint = 'Remove the selected dependency file from the related project'
      ImageIndex = 41
      ImageName = 'removedep'
      OnExecute = ActionRemoveDepExecute
    end
    object ActionTerminal: TAction
      Caption = 'Open an ESPHome Console'
      Hint = 'Open an Command Console from the project folder'
      ImageIndex = 47
      ImageName = 'terminal'
    end
    object ActionExplorer: TAction
      Caption = 'Open an Explorer window'
      Hint = 'Open an Explorer window from the project folder.'
      ImageIndex = 10
      ImageName = 'explorer'
    end
  end
  object PopupMenuTemplates: TPopupMenu
    MenuAnimation = [maLeftToRight]
    TrackButton = tbLeftButton
    OnPopup = PopupMenuTemplatesPopup
    Left = 64
    Top = 224
    object PopupMenuEditTemplatesXMLFile: TMenuItem
      Caption = 'Edit Templates XML file'
      OnClick = PopupMenuEditTemplatesXMLFileClick
    end
    object PopupMenuReloadXMLFileConfiguration: TMenuItem
      Caption = 'Reload XML file configuration'
      OnClick = PopupMenuReloadXMLFileConfigurationClick
    end
    object PopUpMenuN5: TMenuItem
      Caption = '-'
    end
    object PopupMenuDownloadTemplates: TMenuItem
      Caption = 'Download Templates file from GitHub'
      OnClick = PopupMenuDownloadTemplatesClick
    end
  end
  object VirtualImageList20: TVirtualImageList
    AutoFill = True
    DisabledOpacity = 155
    DisabledGrayscale = True
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'adddep'
        Name = 'adddep'
      end
      item
        CollectionIndex = 1
        CollectionName = 'addprj'
        Name = 'addprj'
      end
      item
        CollectionIndex = 2
        CollectionName = 'cancel'
        Name = 'cancel'
      end
      item
        CollectionIndex = 3
        CollectionName = 'clean'
        Name = 'clean'
      end
      item
        CollectionIndex = 4
        CollectionName = 'cleanall'
        Name = 'cleanall'
      end
      item
        CollectionIndex = 5
        CollectionName = 'compile'
        Name = 'compile'
      end
      item
        CollectionIndex = 6
        CollectionName = 'configure'
        Name = 'configure'
      end
      item
        CollectionIndex = 7
        CollectionName = 'console'
        Name = 'console'
      end
      item
        CollectionIndex = 8
        CollectionName = 'dependency'
        Name = 'dependency'
      end
      item
        CollectionIndex = 9
        CollectionName = 'esphome'
        Name = 'esphome'
      end
      item
        CollectionIndex = 10
        CollectionName = 'explorer'
        Name = 'explorer'
      end
      item
        CollectionIndex = 11
        CollectionName = 'file_any'
        Name = 'file_any'
      end
      item
        CollectionIndex = 12
        CollectionName = 'file_cpp'
        Name = 'file_cpp'
      end
      item
        CollectionIndex = 13
        CollectionName = 'file_csv'
        Name = 'file_csv'
      end
      item
        CollectionIndex = 14
        CollectionName = 'file_h'
        Name = 'file_h'
      end
      item
        CollectionIndex = 15
        CollectionName = 'file_inc'
        Name = 'file_inc'
      end
      item
        CollectionIndex = 16
        CollectionName = 'file_txt'
        Name = 'file_txt'
      end
      item
        CollectionIndex = 17
        CollectionName = 'file_yaml'
        Name = 'file_yaml'
      end
      item
        CollectionIndex = 18
        CollectionName = 'help'
        Name = 'help'
      end
      item
        CollectionIndex = 19
        CollectionName = 'logs'
        Name = 'logs'
      end
      item
        CollectionIndex = 20
        CollectionName = 'mc_bk72xx'
        Name = 'mc_bk72xx'
      end
      item
        CollectionIndex = 21
        CollectionName = 'mc_esp32'
        Name = 'mc_esp32'
      end
      item
        CollectionIndex = 22
        CollectionName = 'mc_esp8266'
        Name = 'mc_esp8266'
      end
      item
        CollectionIndex = 23
        CollectionName = 'mc_host'
        Name = 'mc_host'
      end
      item
        CollectionIndex = 24
        CollectionName = 'mc_ln882x'
        Name = 'mc_ln882x'
      end
      item
        CollectionIndex = 25
        CollectionName = 'mc_rp2040'
        Name = 'mc_rp2040'
      end
      item
        CollectionIndex = 26
        CollectionName = 'mc_rtl87xx'
        Name = 'mc_rtl87xx'
      end
      item
        CollectionIndex = 27
        CollectionName = 'mi_bk72xx'
        Name = 'mi_bk72xx'
      end
      item
        CollectionIndex = 28
        CollectionName = 'mi_esp32'
        Name = 'mi_esp32'
      end
      item
        CollectionIndex = 29
        CollectionName = 'mi_esp8266'
        Name = 'mi_esp8266'
      end
      item
        CollectionIndex = 30
        CollectionName = 'mi_host'
        Name = 'mi_host'
      end
      item
        CollectionIndex = 31
        CollectionName = 'mi_ln882x'
        Name = 'mi_ln882x'
      end
      item
        CollectionIndex = 32
        CollectionName = 'mi_rp2040'
        Name = 'mi_rp2040'
      end
      item
        CollectionIndex = 33
        CollectionName = 'mi_rtl87xx'
        Name = 'mi_rtl87xx'
      end
      item
        CollectionIndex = 34
        CollectionName = 'more'
        Name = 'more'
      end
      item
        CollectionIndex = 35
        CollectionName = 'none'
        Name = 'none'
      end
      item
        CollectionIndex = 36
        CollectionName = 'npp'
        Name = 'npp'
      end
      item
        CollectionIndex = 37
        CollectionName = 'nppesphome'
        Name = 'nppesphome'
      end
      item
        CollectionIndex = 38
        CollectionName = 'open'
        Name = 'open'
      end
      item
        CollectionIndex = 39
        CollectionName = 'project'
        Name = 'project'
      end
      item
        CollectionIndex = 40
        CollectionName = 'refreshusb'
        Name = 'refreshusb'
      end
      item
        CollectionIndex = 41
        CollectionName = 'removedep'
        Name = 'removedep'
      end
      item
        CollectionIndex = 42
        CollectionName = 'removeprj'
        Name = 'removeprj'
      end
      item
        CollectionIndex = 43
        CollectionName = 'run'
        Name = 'run'
      end
      item
        CollectionIndex = 44
        CollectionName = 'select'
        Name = 'select'
      end
      item
        CollectionIndex = 45
        CollectionName = 'serial'
        Name = 'serial'
      end
      item
        CollectionIndex = 46
        CollectionName = 'showhide'
        Name = 'showhide'
      end
      item
        CollectionIndex = 47
        CollectionName = 'terminal'
        Name = 'terminal'
      end
      item
        CollectionIndex = 48
        CollectionName = 'upgrade'
        Name = 'upgrade'
      end
      item
        CollectionIndex = 49
        CollectionName = 'upload'
        Name = 'upload'
      end
      item
        CollectionIndex = 50
        CollectionName = 'wifi'
        Name = 'wifi'
      end
      item
        CollectionIndex = 51
        CollectionName = 'window'
        Name = 'window'
      end>
    ImageCollection = Resources.StandardImages
    PreserveItems = True
    Width = 20
    Height = 20
    Left = 280
    Top = 248
  end
  object PopupMenuDeps: TPopupMenu
    Images = VirtualImageList20
    MenuAnimation = [maLeftToRight]
    TrackButton = tbLeftButton
    OnPopup = PopupMenuTemplatesPopup
    Left = 64
    Top = 296
    object PopupMenuRemoveDep: TMenuItem
      Action = ActionRemoveDep
    end
  end
end
