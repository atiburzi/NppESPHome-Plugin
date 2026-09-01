object FormConsole: TFormConsole
  Left = 0
  Top = 0
  Caption = 'Console'
  ClientHeight = 280
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnResize = FormResize
  TextHeight = 15
  object RichEditConsole: TRichEdit
    Left = 0
    Top = 37
    Width = 720
    Height = 243
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    EditMargins.Auto = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Consolas'
    Font.Pitch = fpFixed
    Font.Style = []
    HideSelection = False
    ParentFont = False
    PlainText = True
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
    WordWrap = False
    OnKeyDown = RichEditConsoleKeyDown
    OnKeyPress = RichEditConsoleKeyPress
    OnSelectionChange = RichEditConsoleSelectionChange
  end
  object PanelCommands: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 37
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    ParentBackground = False
    ParentColor = True
    TabOrder = 1
    ExplicitWidth = 718
    object SpeedButtonStop: TSpeedButton
      Left = 652
      Top = 0
      Width = 68
      Height = 35
      Hint = 'Stops the current running command.'
      Align = alRight
      Caption = 'Stop'
      ImageIndex = 53
      ImageName = 'stop'
      Images = VirtualImageList
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Spacing = 5
      Visible = False
      OnClick = SpeedButtonStopClick
    end
    object SpeedButtonClear: TSpeedButton
      Left = 584
      Top = 0
      Width = 68
      Height = 35
      Hint = 'Clears the console output.'
      Align = alRight
      Caption = 'Clear'
      ImageIndex = 11
      ImageName = 'eraser'
      Images = VirtualImageList
      Flat = True
      OnClick = SpeedButtonClearClick
    end
    object SpeedButtonSave: TSpeedButton
      Left = 504
      Top = 0
      Width = 80
      Height = 35
      Hint = 'Saves the console output to a file.'
      Align = alRight
      Caption = 'Save'
      ImageIndex = 47
      ImageName = 'save'
      Images = VirtualImageList
      Enabled = False
      Flat = True
      Spacing = 5
      OnClick = SpeedButtonSaveClick
    end
    object SpeedButtonCopy: TSpeedButton
      Left = 424
      Top = 0
      Width = 80
      Height = 35
      Hint = 'Copies the selected console text.'
      Align = alRight
      Caption = 'Copy'
      ImageIndex = 9
      ImageName = 'copy'
      Images = VirtualImageList
      Enabled = False
      Flat = True
      Spacing = 5
      OnClick = SpeedButtonCopyClick
    end
    object SpeedButtonSelectAll: TSpeedButton
      Left = 326
      Top = 0
      Width = 98
      Height = 35
      Hint = 'Selects all console output.'
      Align = alRight
      Caption = 'Select all'
      ImageIndex = 50
      ImageName = 'selectall'
      Images = VirtualImageList
      Flat = True
      Spacing = 5
      OnClick = SpeedButtonSelectAllClick
    end
    object SpeedButtonFollow: TSpeedButton
      Left = 238
      Top = 0
      Width = 80
      Height = 35
      Hint = 'Following new output. Click to pause.'
      Align = alRight
      AllowAllUp = True
      GroupIndex = 1
      Down = True
      Caption = 'Follow'
      ImageIndex = 48
      ImageName = 'scrolldown'
      Images = VirtualImageList
      Flat = True
      Spacing = 5
      OnClick = SpeedButtonFollowClick
    end
    object PanelSpace: TPanel
      Left = 318
      Top = 0
      Width = 8
      Height = 35
      Align = alRight
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
    end
    object PanelIndicator: TPanel
      Left = 0
      Top = 0
      Width = 36
      Height = 35
      Align = alLeft
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      TabOrder = 1
      object PaintBoxActivity: TPaintBox
        Left = 0
        Top = 0
        Width = 36
        Height = 35
        Align = alClient
        OnPaint = PaintBoxActivityPaint
      end
    end
    object PanelSession: TPanel
      Left = 36
      Top = 0
      Width = 202
      Height = 35
      Align = alClient
      BevelOuter = bvNone
      Padding.Left = 6
      ParentBackground = False
      ParentColor = True
      TabOrder = 2
      object LabelTitle: TLabel
        Left = 6
        Top = 0
        Width = 196
        Height = 17
        Align = alTop
        AutoSize = False
        Caption = 'Console'
        EllipsisPosition = epEndEllipsis
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        Layout = tlBottom
      end
      object LabelStatus: TLabel
        Left = 6
        Top = 17
        Width = 196
        Height = 18
        Align = alClient
        AutoSize = False
        Caption = 'Ready'
        EllipsisPosition = epEndEllipsis
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object TimerUI: TTimer
    Interval = 33
    OnTimer = TimerUITimer
    Left = 640
    Top = 90
  end
  object SaveDialogLog: TSaveDialog
    DefaultExt = 'log'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 700
    Top = 90
  end
  object VirtualImageList: TVirtualImageList
    AutoFill = True
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
        CollectionName = 'console2'
        Name = 'console2'
      end
      item
        CollectionIndex = 9
        CollectionName = 'copy'
        Name = 'copy'
      end
      item
        CollectionIndex = 10
        CollectionName = 'dependency'
        Name = 'dependency'
      end
      item
        CollectionIndex = 11
        CollectionName = 'eraser'
        Name = 'eraser'
      end
      item
        CollectionIndex = 12
        CollectionName = 'esphome'
        Name = 'esphome'
      end
      item
        CollectionIndex = 13
        CollectionName = 'explorer'
        Name = 'explorer'
      end
      item
        CollectionIndex = 14
        CollectionName = 'file_any'
        Name = 'file_any'
      end
      item
        CollectionIndex = 15
        CollectionName = 'file_cpp'
        Name = 'file_cpp'
      end
      item
        CollectionIndex = 16
        CollectionName = 'file_csv'
        Name = 'file_csv'
      end
      item
        CollectionIndex = 17
        CollectionName = 'file_h'
        Name = 'file_h'
      end
      item
        CollectionIndex = 18
        CollectionName = 'file_inc'
        Name = 'file_inc'
      end
      item
        CollectionIndex = 19
        CollectionName = 'file_txt'
        Name = 'file_txt'
      end
      item
        CollectionIndex = 20
        CollectionName = 'file_yaml'
        Name = 'file_yaml'
      end
      item
        CollectionIndex = 21
        CollectionName = 'help'
        Name = 'help'
      end
      item
        CollectionIndex = 22
        CollectionName = 'logs'
        Name = 'logs'
      end
      item
        CollectionIndex = 23
        CollectionName = 'mc_bk72xx'
        Name = 'mc_bk72xx'
      end
      item
        CollectionIndex = 24
        CollectionName = 'mc_esp32'
        Name = 'mc_esp32'
      end
      item
        CollectionIndex = 25
        CollectionName = 'mc_esp8266'
        Name = 'mc_esp8266'
      end
      item
        CollectionIndex = 26
        CollectionName = 'mc_host'
        Name = 'mc_host'
      end
      item
        CollectionIndex = 27
        CollectionName = 'mc_ln882x'
        Name = 'mc_ln882x'
      end
      item
        CollectionIndex = 28
        CollectionName = 'mc_rp2040'
        Name = 'mc_rp2040'
      end
      item
        CollectionIndex = 29
        CollectionName = 'mc_rtl87xx'
        Name = 'mc_rtl87xx'
      end
      item
        CollectionIndex = 30
        CollectionName = 'mi_bk72xx'
        Name = 'mi_bk72xx'
      end
      item
        CollectionIndex = 31
        CollectionName = 'mi_esp32'
        Name = 'mi_esp32'
      end
      item
        CollectionIndex = 32
        CollectionName = 'mi_esp8266'
        Name = 'mi_esp8266'
      end
      item
        CollectionIndex = 33
        CollectionName = 'mi_host'
        Name = 'mi_host'
      end
      item
        CollectionIndex = 34
        CollectionName = 'mi_ln882x'
        Name = 'mi_ln882x'
      end
      item
        CollectionIndex = 35
        CollectionName = 'mi_rp2040'
        Name = 'mi_rp2040'
      end
      item
        CollectionIndex = 36
        CollectionName = 'mi_rtl87xx'
        Name = 'mi_rtl87xx'
      end
      item
        CollectionIndex = 37
        CollectionName = 'more'
        Name = 'more'
      end
      item
        CollectionIndex = 38
        CollectionName = 'none'
        Name = 'none'
      end
      item
        CollectionIndex = 39
        CollectionName = 'npp'
        Name = 'npp'
      end
      item
        CollectionIndex = 40
        CollectionName = 'nppesphome'
        Name = 'nppesphome'
      end
      item
        CollectionIndex = 41
        CollectionName = 'open'
        Name = 'open'
      end
      item
        CollectionIndex = 42
        CollectionName = 'project'
        Name = 'project'
      end
      item
        CollectionIndex = 43
        CollectionName = 'refreshusb'
        Name = 'refreshusb'
      end
      item
        CollectionIndex = 44
        CollectionName = 'removedep'
        Name = 'removedep'
      end
      item
        CollectionIndex = 45
        CollectionName = 'removeprj'
        Name = 'removeprj'
      end
      item
        CollectionIndex = 46
        CollectionName = 'run'
        Name = 'run'
      end
      item
        CollectionIndex = 47
        CollectionName = 'save'
        Name = 'save'
      end
      item
        CollectionIndex = 48
        CollectionName = 'scrolldown'
        Name = 'scrolldown'
      end
      item
        CollectionIndex = 49
        CollectionName = 'select'
        Name = 'select'
      end
      item
        CollectionIndex = 50
        CollectionName = 'selectall'
        Name = 'selectall'
      end
      item
        CollectionIndex = 51
        CollectionName = 'serial'
        Name = 'serial'
      end
      item
        CollectionIndex = 52
        CollectionName = 'showhide'
        Name = 'showhide'
      end
      item
        CollectionIndex = 53
        CollectionName = 'stop'
        Name = 'stop'
      end
      item
        CollectionIndex = 54
        CollectionName = 'terminal'
        Name = 'terminal'
      end
      item
        CollectionIndex = 55
        CollectionName = 'upgrade'
        Name = 'upgrade'
      end
      item
        CollectionIndex = 56
        CollectionName = 'upload'
        Name = 'upload'
      end
      item
        CollectionIndex = 57
        CollectionName = 'wifi'
        Name = 'wifi'
      end
      item
        CollectionIndex = 58
        CollectionName = 'window'
        Name = 'window'
      end>
    ImageCollection = Resources.StandardImages
    PreserveItems = True
    Width = 26
    Height = 26
    Left = 770
    Top = 90
  end
end
