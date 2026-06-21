object FormConfig: TFormConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Project Configuration'
  ClientHeight = 507
  ClientWidth = 623
  Color = clBtnFace
  ParentFont = True
  ShowHint = True
  OnCreate = FormCreate
  TextHeight = 15
  object ButtonClose: TButton
    Left = 542
    Top = 477
    Width = 75
    Height = 25
    Hint = 'Closes current window'
    Cancel = True
    Caption = 'Close'
    ModalResult = 1
    TabOrder = 2
  end
  object GroupBoxProject: TGroupBox
    Left = 8
    Top = 8
    Width = 609
    Height = 129
    Caption = 'Current Project'
    TabOrder = 0
    object VirtualImageMC: TVirtualImage
      Left = 500
      Top = 12
      Width = 102
      Height = 114
      Center = True
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = -1
    end
    object MemoProject: TMemo
      Left = 23
      Top = 21
      Width = 474
      Height = 97
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object GroupBoxOptions: TGroupBox
    Left = 8
    Top = 143
    Width = 609
    Height = 322
    Caption = 'Options'
    TabOrder = 1
    object TreeViewOptions: TTreeView
      Left = 19
      Top = 28
      Width = 190
      Height = 269
      Ctl3D = False
      HideSelection = False
      Images = VirtualImageList
      Indent = 20
      ParentColor = True
      ParentCtl3D = False
      ReadOnly = True
      RowSelect = True
      ShowButtons = False
      TabOrder = 1
      OnChange = TreeViewOptionsChange
      OnCollapsing = TreeViewOptionsCollapsing
      OnCustomDrawItem = TreeViewOptionsCustomDrawItem
      OnGetImageIndex = TreeViewOptionsGetImageIndex
      Items.NodeData = {
        070400000009540054007200650065004E006F00640065002D00000000000000
        0000000000000000FFFFFFFF000000000000000000000000000107500072006F
        006A0065006300740000002D000000000000000000000001000000FFFFFFFF00
        000000000000000005000000010745005300500048006F006D00650000003500
        0000000000000000000002000000FFFFFFFF0000000000000000000000000001
        0B520075006E00200043006F006D006D0061006E00640000003D000000000000
        000000000003000000FFFFFFFF00000000000000000000000000010F43006F00
        6D00700069006C006500200043006F006D006D0061006E00640000003B000000
        000000000000000004000000FFFFFFFF00000000000000000000000000010E55
        0070006C006F0061006400200043006F006D006D0061006E0064000000370000
        00000000000000000005000000FFFFFFFF00000000000000000000000000010C
        4C006F0067007300200043006F006D006D0061006E0064000000390000000000
        00000000000006000000FFFFFFFF00000000000000000000000000010D43006C
        00650061006E00200043006F006D006D0061006E006400000033000000000000
        000000000007000000FFFFFFFF00000000000000000000000000010A4E006F00
        740065007000610064002B002B00200000002D00000000000000000000000800
        0000FFFFFFFF00000000000000000000000000010743006F006E0073006F006C
        006500}
    end
    object CardPanelOptions: TCardPanel
      Left = 215
      Top = 20
      Width = 387
      Height = 277
      ActiveCard = CardRunOptions
      BevelOuter = bvNone
      Caption = 'CardPanelOptions'
      ParentColor = True
      TabOrder = 0
      object CardProjectOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardProjectOptions'
        CardIndex = 0
        ParentColor = True
        TabOrder = 2
        object LabelDependencies: TLabel
          Left = 24
          Top = 8
          Width = 261
          Height = 105
          Caption = 
            'Project files that depend on this project. '#13#10'They open in Notepa' +
            'd++ using the Open Project File and Dependencies command, and, i' +
            'f configured, are saved automatically before any ESPHome command' +
            ' runs.'#13#10#13#10'Dependencies:'
          WordWrap = True
        end
        object ListBoxDependencies: TListBox
          Left = 24
          Top = 121
          Width = 353
          Height = 118
          Hint = 
            'Project files to be automatically opened and saved by Notepad++ ' +
            'during development'
          BevelInner = bvNone
          BevelOuter = bvNone
          ItemHeight = 15
          MultiSelect = True
          ParentColor = True
          TabOrder = 0
        end
        object ButtonAddDeps: TButton
          Left = 242
          Top = 252
          Width = 65
          Height = 21
          Hint = 
            'Add a new existing file(s) among the current project dependencie' +
            's'
          Caption = 'Add'
          TabOrder = 1
          OnClick = ButtonAddDepsClick
        end
        object ButtonRemoveDeps: TButton
          Left = 313
          Top = 252
          Width = 65
          Height = 21
          Hint = 
            'Remove the selected file(s) among the current project dependenci' +
            'es'
          Caption = 'Remove'
          TabOrder = 2
          OnClick = ButtonRemoveDepsClick
        end
      end
      object CardESPHomeOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardESPHomeOptions'
        CardIndex = 1
        ParentColor = True
        TabOrder = 4
        object LabelLogLevel: TLabel
          Left = 23
          Top = 72
          Width = 108
          Height = 15
          Hint = 
            'Log level reported into the console window during the ESPHome co' +
            'mmand execution.'
          Caption = 'ESPHome Log Level:'
        end
        object LabelDevice: TLabel
          Left = 23
          Top = 11
          Width = 128
          Height = 15
          Caption = 'Target device (--device):'
          FocusControl = ComboBoxDevice
        end
        object LabelOptionESPHomeAdditionalParameters: TLabel
          Left = 23
          Top = 110
          Width = 273
          Height = 30
          Caption = 
            'Manually specify additional command line switches'#13#10'for the ESPHo' +
            'me command line:'
        end
        object LabelDeviceDesc: TLabel
          Left = 23
          Top = 34
          Width = 251
          Height = 15
          Caption = 'Applicable to Run, Upload and Logs commands.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsItalic]
          ParentFont = False
        end
        object SpeedButtonRefresh: TSpeedButton
          Left = 285
          Top = 6
          Width = 30
          Height = 29
          Hint = 'Refresh the current list of available USB ports'
          ImageName = 'refreshusb'
          Images = VirtualImageList
          Flat = True
          OnClick = SpeedButtonRefreshClick
        end
        object ComboBoxLogLevel: TJvImageComboBox
          Left = 171
          Top = 69
          Width = 113
          Height = 25
          Hint = 
            'Log level reported into the console window during the ESPHome co' +
            'mmand execution.'
          Style = csOwnerDrawVariable
          ButtonStyle = fsDark
          DroppedWidth = 145
          ImageHeight = 0
          ImageWidth = 0
          IndentSelected = True
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 2
          OnChange = ComboBoxLogLevelChange
          Items = <
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Critical'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Error'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Warning'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Info'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Debug'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Default'
            end>
        end
        object ComboBoxDevice: TJvImageComboBox
          Left = 171
          Top = 8
          Width = 113
          Height = 26
          Hint = 
            'Specify the serial port or host address to be used to upload fir' +
            'mware or retrieve logs by RUN, UPLOAD or LOGS ESPHome commands (' +
            '--device). '
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 145
          ImageHeight = 0
          ImageWidth = 0
          Images = VirtualImageList
          ItemHeight = 20
          ItemIndex = -1
          ParentColor = True
          TabOrder = 0
          OnChange = ComboBoxDeviceChange
          Items = <>
        end
        object EditOptionESPHomeAdditionalParameters: TJvEdit
          Left = 23
          Top = 144
          Width = 346
          Height = 21
          Flat = True
          ParentFlat = False
          ParentColor = True
          TabOrder = 3
          Text = ''
          OnChange = EditOptionESPHomeAdditionalParametersChange
        end
        object LinkLabelESPHome: TLinkLabel
          Left = 340
          Top = 8
          Width = 29
          Height = 19
          Caption = '<a href="https://esphome.io/guides/cli/#base-usage">Help</a>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardRunOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardRunOptions'
        CardIndex = 2
        ParentColor = True
        TabOrder = 5
        object LabelOptionRunAdditionalParameters: TLabel
          Left = 22
          Top = 109
          Width = 114
          Height = 75
          Caption = 
            'Manually specify additional command line switches when "Run" com' +
            'mand is executed:'
          WordWrap = True
        end
        object LabelOptionRunNoLogs: TLabel
          Left = 50
          Top = 10
          Width = 232
          Height = 30
          Caption = 
            'No Logs (Disable log view)'#13#10'Add "--no-logs" switch to "Run" comm' +
            'and.'
          FocusControl = CheckBoxOptionRunNoLogs
        end
        object LabelOptionRunReset: TLabel
          Left = 50
          Top = 59
          Width = 229
          Height = 30
          Caption = 
            'Reset (Reset the device before starting logs)'#13#10'Add "--reset" swi' +
            'tch to "Run" command.'
          FocusControl = CheckBoxOptionRunReset
        end
        object CheckBoxOptionRunNoLogs: TCheckBox
          Left = 22
          Top = 10
          Width = 123
          Height = 17
          TabOrder = 1
          OnClick = CheckBoxOptionRunNoLogsClick
        end
        object CheckBoxOptionRunReset: TCheckBox
          Left = 22
          Top = 59
          Width = 75
          Height = 17
          TabOrder = 2
          OnClick = CheckBoxOptionRunResetClick
        end
        object EditOptionRunAdditionalParameters: TJvEdit
          Left = 22
          Top = 143
          Width = 347
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 3
          Text = ''
          OnChange = EditOptionRunAdditionalParametersChange
        end
        object LinkLabelRunHelp: TLinkLabel
          Left = 340
          Top = 8
          Width = 29
          Height = 19
          Caption = '<a href="https://esphome.io/guides/cli/#run-command">Help</a>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardCompileOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardCompileOptions'
        CardIndex = 3
        ParentColor = True
        TabOrder = 6
        object LabelOptionCompileGenerateOnly: TLabel
          Left = 45
          Top = 10
          Width = 289
          Height = 30
          Caption = 
            'Generate Only (doesn'#39't compile firmware)'#13#10'Add "--only-generate" ' +
            'switch to "Compile" command.'
        end
        object LabelOptionCompileAdditionalParameters: TLabel
          Left = 22
          Top = 60
          Width = 257
          Height = 30
          Caption = 
            'Manually specify additional command line switches when "Compile"' +
            ' command is executed:'
          WordWrap = True
        end
        object CheckBoxOptionCompileGenerateOnly: TCheckBox
          Left = 22
          Top = 10
          Width = 131
          Height = 17
          TabOrder = 1
          OnClick = CheckBoxOptionCompileGenerateOnlyClick
        end
        object LinkLabelCompileHelp: TLinkLabel
          Left = 340
          Top = 8
          Width = 29
          Height = 19
          Caption = 
            '<a href="https://esphome.io/guides/cli/#compile-command">Help</a' +
            '>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnLinkClick = LinkLabelHelpLinkClick
        end
        object EditOptionCompileAdditionalParameters: TJvEdit
          Left = 22
          Top = 96
          Width = 347
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 2
          Text = ''
          OnChange = EditOptionCompileAdditionalParametersChange
        end
      end
      object CardUploadOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardUploadOptions'
        CardIndex = 4
        ParentColor = True
        TabOrder = 7
        object LabelOptionUploadAdditionalParameters: TLabel
          Left = 26
          Top = 8
          Width = 273
          Height = 30
          Caption = 
            'Manually specify additional command line switches'#13#10'when "Upload"' +
            ' command is executed:'
        end
        object EditOptionUploadAdditionalParameters: TJvEdit
          Left = 26
          Top = 42
          Width = 323
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 1
          Text = ''
          OnChange = EditOptionUploadAdditionalParametersChange
        end
        object LinkLabelUploadOptions: TLinkLabel
          Left = 340
          Top = 8
          Width = 29
          Height = 19
          Caption = '<a href="https://esphome.io/guides/cli/#upload-command">Help</a>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardLogsOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardLogsOptions'
        CardIndex = 5
        ParentColor = True
        TabOrder = 3
        object LabelOptionLogsReset: TLabel
          Left = 45
          Top = 8
          Width = 249
          Height = 30
          Caption = 
            'Reset (Reset the device before starting the logs)'#13#10'Add "--reset"' +
            ' switch to "Logs" command.'
        end
        object LabelOptionLogsAdditionalParameters: TLabel
          Left = 22
          Top = 59
          Width = 273
          Height = 30
          Caption = 
            'Manually specify additional command line switches'#13#10'when "Logs" c' +
            'ommand is executed:'
        end
        object CheckBoxOptionLogsReset: TCheckBox
          Left = 22
          Top = 8
          Width = 97
          Height = 17
          TabOrder = 0
          OnClick = CheckBoxOptionLogsResetClick
        end
        object EditOptionLogsAdditionalParameters: TJvEdit
          Left = 22
          Top = 92
          Width = 347
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 2
          Text = ''
          OnChange = EditOptionLogsAdditionalParametersChange
        end
        object LinkLabelLogsOptions: TLinkLabel
          Left = 340
          Top = 8
          Width = 29
          Height = 19
          Caption = '<a href="https://esphome.io/guides/cli/#logs-command">Help</a>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardCleanOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardCleanOptions'
        CardIndex = 6
        ParentColor = True
        TabOrder = 0
        object LabelOptionCleanAdditionalParameters: TLabel
          Left = 22
          Top = 8
          Width = 114
          Height = 75
          Caption = 
            'Manually specify additional command line switches when "Clean" c' +
            'ommand is executed:'
          WordWrap = True
        end
        object LinkLabelHelpOptions: TLinkLabel
          Left = 340
          Top = 8
          Width = 29
          Height = 19
          Caption = '<a href="https://esphome.io/guides/cli/#clean-command">Help</a>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnLinkClick = LinkLabelHelpLinkClick
        end
        object EditOptionCleanAdditionalParameters: TJvEdit
          Left = 22
          Top = 44
          Width = 347
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 1
          Text = ''
          OnChange = EditOptionCleanAdditionalParametersChange
        end
      end
      object CardNppOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardNppOptions'
        CardIndex = 7
        ParentColor = True
        TabOrder = 1
        object LabelAutosave: TLabel
          Left = 16
          Top = 8
          Width = 250
          Height = 15
          Hint = 
            'Select the way in which the project file(s) are auto saved befor' +
            'e ESPHome commands are started'
          Caption = 'Autosave before starting ESPHome commands:'
        end
        object ComboBoxOptionAutosave: TJvImageComboBox
          Left = 16
          Top = 28
          Width = 353
          Height = 25
          Hint = 
            'Select the way in which the project file(s) are auto saved befor' +
            'e ESPHome commands are started'
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 353
          ImageHeight = 0
          ImageWidth = 0
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 0
          OnChange = ComboBoxOptionAutosaveChange
          Items = <
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'None'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Current Project File Only'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Current Project File & Dependencies'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'All Opened Files (can save unwanted files)'
            end>
        end
      end
      object CardConsoleOptions: TCard
        Left = 0
        Top = 0
        Width = 387
        Height = 277
        Caption = 'CardConsoleOptions'
        CardIndex = 8
        ParentColor = True
        TabOrder = 8
        object LabelOptionConsoleAutoclose: TLabel
          Left = 23
          Top = 12
          Width = 276
          Height = 15
          Caption = 'When the ESPHome command finishes successfully:'
        end
        object LabelOptionConsoleAlwaysOnTop: TLabel
          Left = 52
          Top = 160
          Width = 75
          Height = 15
          Caption = 'Always on top'
        end
        object LabelOptionConsolePosition: TLabel
          Left = 23
          Top = 105
          Width = 227
          Height = 15
          Caption = 'Choose the console position on the screen:'
        end
        object LabelOptionConsoleMonitor: TLabel
          Left = 23
          Top = 59
          Width = 296
          Height = 15
          Caption = 'Choose the monitor where ESPHome Console will open:'
        end
        object LabelOptionConsoleSoloMode: TLabel
          Left = 191
          Top = 160
          Width = 128
          Height = 15
          Caption = 'Allows only one console'
        end
        object ComboBoxOptionConsoleAutoclose: TJvImageComboBox
          Left = 23
          Top = 30
          Width = 346
          Height = 25
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 346
          ImageHeight = 0
          ImageWidth = 0
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 0
          OnChange = ComboBoxOptionConsoleAutocloseChange
          Items = <
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Leave the console open'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Close the console automatically'
            end>
        end
        object CheckBoxOptionAlwaysOnTop: TCheckBox
          Left = 23
          Top = 154
          Width = 97
          Height = 30
          TabOrder = 3
          OnClick = CheckBoxOptionAlwaysOnTopClick
        end
        object ComboBoxOptionConsolePosition: TJvImageComboBox
          Left = 23
          Top = 122
          Width = 346
          Height = 25
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 346
          ImageHeight = 0
          ImageWidth = 0
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 2
          OnChange = ComboBoxOptionConsolePositionChange
          Items = <
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Let Windows decide'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Centered on the screen'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Top-left corner of the screen'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Bottom-left corner of the screen'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Top-right corner of the screen'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'Bottom-right corner of the screen'
            end>
        end
        object ComboBoxOptionConsoleMonitor: TJvImageComboBox
          Left = 23
          Top = 76
          Width = 346
          Height = 25
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 346
          ImageHeight = 0
          ImageWidth = 0
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 1
          OnChange = ComboBoxOptionConsoleMonitorChange
          Items = <>
        end
        object CheckBoxOptionSoloMode: TCheckBox
          Left = 167
          Top = 154
          Width = 130
          Height = 30
          TabOrder = 4
          OnClick = CheckBoxOptionSoloModeClick
        end
      end
    end
  end
  object VirtualImageList: TVirtualImageList
    AutoFill = True
    Images = <>
    Width = 20
    Height = 20
    Left = 304
    Top = 32
  end
  object FileOpenDialogDependency: TFileOpenDialog
    DefaultExtension = '*.yaml'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'ESPHome Files (yaml)'
        FileMask = '*.yaml'
      end
      item
        DisplayName = 'ESPHome File (yml)'
        FileMask = '*.yml'
      end
      item
        DisplayName = 'Partitions files (csv)'
        FileMask = '*.csv'
      end
      item
        DisplayName = 'C++ Header file'
        FileMask = '*.h'
      end
      item
        DisplayName = 'C++ Source File'
        FileMask = '*.cpp'
      end
      item
        DisplayName = 'Include Files'
        FileMask = '*.inc'
      end
      item
        DisplayName = 'Text Files'
        FileMask = '*.txt'
      end
      item
        DisplayName = 'Any file'
        FileMask = '*.*'
      end>
    Options = [fdoForceFileSystem, fdoAllowMultiSelect, fdoFileMustExist, fdoNoDereferenceLinks, fdoForceShowHidden]
    Left = 88
    Top = 31
  end
end
