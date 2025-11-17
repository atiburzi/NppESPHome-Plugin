object FormConfig: TFormConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Project Configuration'
  ClientHeight = 409
  ClientWidth = 602
  Color = clBtnFace
  ParentFont = True
  ShowHint = True
  OnCreate = FormCreate
  TextHeight = 15
  object ButtonClose: TButton
    Left = 268
    Top = 374
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
    Width = 585
    Height = 129
    Caption = 'Current Project'
    TabOrder = 0
    object VirtualImageStatus: TVirtualImage
      Left = 516
      Top = 18
      Width = 48
      Height = 48
      ParentCustomHint = False
      Center = True
      ImageCollection = ImageCollectionBlack
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = 9
      ImageName = 'wifi-disabled'
    end
    object LabelStatus: TLabel
      Left = 499
      Top = 63
      Width = 85
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'Status'
    end
    object MemoProject: TMemo
      Left = 23
      Top = 21
      Width = 474
      Height = 97
      BorderStyle = bsNone
      ParentColor = True
      ReadOnly = True
      TabOrder = 0
    end
    object ButtonRefresh: TButton
      Left = 510
      Top = 92
      Width = 61
      Height = 25
      Hint = 
        'Checks the online status and the available serial ports for the ' +
        'current project'
      Caption = 'Refresh'
      TabOrder = 1
      OnClick = ButtonRefreshClick
    end
  end
  object GroupBoxOptions: TGroupBox
    Left = 8
    Top = 143
    Width = 585
    Height = 217
    Caption = 'Options'
    TabOrder = 1
    object TreeViewOptions: TTreeView
      Left = 19
      Top = 28
      Width = 190
      Height = 171
      Ctl3D = False
      HideSelection = False
      Images = VirtualImageListBlack
      Indent = 20
      ParentColor = True
      ParentCtl3D = False
      ReadOnly = True
      RowSelect = True
      ShowButtons = False
      TabOrder = 0
      OnChange = TreeViewOptionsChange
      OnCollapsing = TreeViewOptionsCollapsing
      OnCustomDrawItem = TreeViewOptionsCustomDrawItem
      Items.NodeData = {
        070300000009540054007200650065004E006F00640065003D0000000B000000
        0B00000001000000FFFFFFFF00000000000000000006000000010F4500530050
        0048006F006D00650020004F007000740069006F006E00730000003D0000000E
        0000000E00000008000000FFFFFFFF00000000000000000000000000010F4300
        6F006E0073006F006C00650020004F007000740069006F006E00730000003500
        0000000000000000000002000000FFFFFFFF0000000000000000000000000001
        0B520075006E00200043006F006D006D0061006E00640000003D000000010000
        000100000003000000FFFFFFFF00000000000000000000000000010F43006F00
        6D00700069006C006500200043006F006D006D0061006E00640000003B000000
        020000000200000004000000FFFFFFFF00000000000000000000000000010E55
        0070006C006F0061006400200043006F006D006D0061006E0064000000370000
        00030000000300000005000000FFFFFFFF00000000000000000000000000010C
        4C006F0067007300200043006F006D006D0061006E0064000000390000000400
        00000400000006000000FFFFFFFF00000000000000000000000000010D43006C
        00650061006E00200043006F006D006D0061006E00640000003D0000000C0000
        000C00000000000000FFFFFFFF00000000000000000000000000010F50007200
        6F006A0065006300740020004F007000740069006F006E007300000041000000
        0D0000000D00000007000000FFFFFFFF0000000000000000000000000001114E
        006F00740065007000610064002B002B0020004F007000740069006F006E0073
        00}
    end
    object CardPanelOptions: TCardPanel
      Left = 215
      Top = 20
      Width = 349
      Height = 184
      ActiveCard = CardUploadOptions
      BevelOuter = bvNone
      Caption = 'CardPanelOptions'
      ParentColor = True
      TabOrder = 1
      object CardProjectOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardProjectOptions'
        CardIndex = 0
        ParentColor = True
        TabOrder = 0
        object LabelDependencies: TLabel
          Left = 16
          Top = 8
          Width = 310
          Height = 60
          Caption = 
            'Project files that depend on this project. They will open in Not' +
            'epad++ with the '#39'Open Project File and Dependencies'#39' command and' +
            ', if configured, will be saved automatically before any ESPHome ' +
            'command runs:'
          WordWrap = True
        end
        object ListBoxDependencies: TListBox
          Left = 16
          Top = 77
          Width = 329
          Height = 76
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
          Left = 210
          Top = 159
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
          Left = 281
          Top = 159
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
        Width = 349
        Height = 184
        Caption = 'CardESPHomeOptions'
        CardIndex = 1
        ParentColor = True
        TabOrder = 1
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
          TabOrder = 1
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
          Height = 25
          Hint = 
            'Specify the serial port or host address to be used to upload fir' +
            'mware or retrieve logs by RUN, UPLOAD or LOGS ESPHome commands (' +
            '--device). '
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 145
          ImageHeight = 0
          ImageWidth = 0
          Images = VirtualImageListBlack
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 0
          OnChange = ComboBoxDeviceChange
          Items = <>
        end
        object EditOptionESPHomeAdditionalParameters: TJvEdit
          Left = 23
          Top = 144
          Width = 322
          Height = 21
          Flat = True
          ParentFlat = False
          ParentColor = True
          TabOrder = 2
          Text = ''
          OnChange = EditOptionESPHomeAdditionalParametersChange
        end
        object LinkLabelESPHome: TLinkLabel
          Left = 320
          Top = 8
          Width = 29
          Height = 19
          Caption = '<a href="https://esphome.io/guides/cli/#options">Help</a>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardRunOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardRunOptions'
        CardIndex = 2
        ParentColor = True
        TabOrder = 2
        object LabelOptionRunAdditionalParameters: TLabel
          Left = 22
          Top = 109
          Width = 273
          Height = 30
          Caption = 
            'Manually specify additional command line switches'#13#10'when "Run" co' +
            'mmand is executed:'
        end
        object LabelOptionRunNoLogs: TLabel
          Left = 50
          Top = 10
          Width = 232
          Height = 30
          Caption = 
            'No Logs (Disable starting log view)'#13#10'Add "--no-logs" switch to "' +
            'Run" command.'
          FocusControl = CheckBoxOptionRunNoLogs
        end
        object LabelOptionRunReset: TLabel
          Left = 50
          Top = 59
          Width = 249
          Height = 30
          Caption = 
            'Reset (Reset the device before starting the logs)'#13#10'Add "--reset"' +
            ' switch to "Run" command.'
          FocusControl = CheckBoxOptionRunReset
        end
        object CheckBoxOptionRunNoLogs: TCheckBox
          Left = 22
          Top = 10
          Width = 123
          Height = 17
          TabOrder = 0
          OnClick = CheckBoxOptionRunNoLogsClick
        end
        object CheckBoxOptionRunReset: TCheckBox
          Left = 22
          Top = 59
          Width = 75
          Height = 17
          TabOrder = 1
          OnClick = CheckBoxOptionRunResetClick
        end
        object EditOptionRunAdditionalParameters: TJvEdit
          Left = 22
          Top = 143
          Width = 323
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 2
          Text = ''
          OnChange = EditOptionRunAdditionalParametersChange
        end
        object LinkLabelRunHelp: TLinkLabel
          Left = 320
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
          TabOrder = 3
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardCompileOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardCompileOptions'
        CardIndex = 3
        ParentColor = True
        TabOrder = 3
        object LabelOptionCompileGenerateOnly: TLabel
          Left = 45
          Top = 10
          Width = 289
          Height = 30
          Caption = 
            'Generate Only (doesn'#39't compile firmware)'#13#10'Add "--only-generate" ' +
            'switch to "Compile" command.'
        end
        object CheckBoxOptionCompileGenerateOnly: TCheckBox
          Left = 22
          Top = 10
          Width = 131
          Height = 17
          TabOrder = 0
          OnClick = CheckBoxOptionCompileGenerateOnlyClick
        end
        object LinkLabelCompileHelp: TLinkLabel
          Left = 320
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
          TabOrder = 1
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardUploadOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardUploadOptions'
        CardIndex = 4
        ParentColor = True
        TabOrder = 4
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
          TabOrder = 0
          Text = ''
          OnChange = EditOptionUploadAdditionalParametersChange
        end
        object LinkLabelUploadOptions: TLinkLabel
          Left = 320
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
          TabOrder = 1
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardLogsOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardLogsOptions'
        CardIndex = 5
        ParentColor = True
        TabOrder = 5
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
          Width = 323
          Height = 21
          Flat = True
          ParentFlat = False
          AutoSize = False
          ParentColor = True
          TabOrder = 1
          Text = ''
          OnChange = EditOptionLogsAdditionalParametersChange
        end
        object LinkLabelLogsOptions: TLinkLabel
          Left = 320
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
          TabOrder = 2
          OnLinkClick = LinkLabelHelpLinkClick
        end
      end
      object CardCleanOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardCleanOptions'
        CardIndex = 6
        ParentColor = True
        TabOrder = 6
        object LabelOptionCleanAdditionalParameters: TLabel
          Left = 22
          Top = 8
          Width = 186
          Height = 30
          Caption = 'Command "Clean" doesn'#39't support'#13#10'additional parameters.'
        end
        object LinkLabelHelpOptions: TLinkLabel
          Left = 320
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
      end
      object CardNppOptions: TCard
        Left = 0
        Top = 0
        Width = 349
        Height = 184
        Caption = 'CardNppOptions'
        CardIndex = 7
        ParentColor = True
        TabOrder = 7
        object LabelAutosave: TLabel
          Left = 16
          Top = 8
          Width = 284
          Height = 15
          Hint = 
            'Select the way in which the project file(s) are auto saved befor' +
            'e ESPHome commands are started'
          Caption = 'Autosave scope before starting ESPHome commands:'
        end
        object ComboBoxOptionAutosave: TJvImageComboBox
          Left = 16
          Top = 25
          Width = 313
          Height = 25
          Hint = 
            'Select the way in which the project file(s) are auto saved befor' +
            'e ESPHome commands are started'
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 332
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
              Text = 'Current Project File & Dependencies (can flash)'
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
        Width = 349
        Height = 184
        Caption = 'CardConsoleOptions'
        CardIndex = 8
        ParentColor = True
        TabOrder = 8
        object LabelAutoclose: TLabel
          Left = 23
          Top = 8
          Width = 264
          Height = 30
          Caption = 
            'Specify how the console should behave '#13#10'after ESPHome commands c' +
            'omplete successfully:'
        end
        object ComboBoxAutoclose: TJvImageComboBox
          Left = 23
          Top = 44
          Width = 298
          Height = 25
          Style = csOwnerDrawVariable
          ButtonStyle = fsLighter
          DroppedWidth = 298
          ImageHeight = 0
          ImageWidth = 0
          ItemHeight = 19
          ItemIndex = -1
          ParentColor = True
          TabOrder = 0
          OnChange = ComboBoxAutocloseChange
          Items = <
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'The console is left opened'
            end
            item
              Brush.Style = bsClear
              Indent = 0
              Text = 'The console is automatically closed'
            end>
        end
      end
    end
  end
  object VirtualImageListBlack: TVirtualImageList
    AutoFill = True
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'Run'
        Name = 'Run'
      end
      item
        CollectionIndex = 1
        CollectionName = 'Compile'
        Name = 'Compile'
      end
      item
        CollectionIndex = 2
        CollectionName = 'Upload'
        Name = 'Upload'
      end
      item
        CollectionIndex = 3
        CollectionName = 'ShowLogs'
        Name = 'ShowLogs'
      end
      item
        CollectionIndex = 4
        CollectionName = 'Clean'
        Name = 'Clean'
      end
      item
        CollectionIndex = 5
        CollectionName = 'none'
        Name = 'none'
      end
      item
        CollectionIndex = 6
        CollectionName = 'question'
        Name = 'question'
      end
      item
        CollectionIndex = 7
        CollectionName = 'serial'
        Name = 'serial'
      end
      item
        CollectionIndex = 8
        CollectionName = 'wifi'
        Name = 'wifi'
      end
      item
        CollectionIndex = 9
        CollectionName = 'wifi-disabled'
        Name = 'wifi-disabled'
      end
      item
        CollectionIndex = 10
        CollectionName = 'wifi-offline'
        Name = 'wifi-offline'
      end
      item
        CollectionIndex = 11
        CollectionName = 'esphome'
        Name = 'esphome'
      end
      item
        CollectionIndex = 12
        CollectionName = 'project'
        Name = 'project'
      end
      item
        CollectionIndex = 13
        CollectionName = 'npp'
        Name = 'npp'
      end
      item
        CollectionIndex = 14
        CollectionName = 'console'
        Name = 'console'
      end>
    ImageCollection = ImageCollectionBlack
    Left = 200
    Top = 32
  end
  object ImageCollectionBlack: TImageCollection
    Images = <
      item
        Name = 'Run'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000432494441547801EC9C3FFB0C3110C7F7A7A2532AE994943A1D3A25AF
              009D5287574047A7C42BA053D2D12929757474ECDC3D73B2B9CCEC6FEF36997F
              F15C2E9B643799F97E9E5D93B1E7CCD0FF882AD00188CA3F0C1D400720AC80F0
              F2FD0EE8008415105EBEDF011D80B002C2CB4BDC017F479F3597D1BC761F0900
              EDBC5BBED29BE5971C77454C00B4660FE8A13A231DC054D75FD366FD5607F05F
              E3E6E2C3D21D00A8B02DF7B755DB6F4D004E46D75B947199E2E76DB1B772A726
              00955DDD4C7F79F3ADE82B1A801784F6CDC34FB4231A80EBE87856370F3F71FD
              6800D0EFBC168980C08848001E83C38522263ED81209C01370B85044C24FB4A3
              21005C525D2D127EA20A51005C4187B5D55100BC2284170B3FD19E2800A83B40
              2CFC8C04E02C3A5BA8452320B027C21DA032FC04F1A14400F0081C2D14D1F013
              ED8900007DCD6BD1F0138DF10EE0063AAAB5F60EE03921BC78F88976790740E5
              FF9B859F2834557B06A03AFC44209E013C4327B35A3CF64FEDF10C800A33A9FE
              549766C79E015022AA083FD138AF006EA38385FA98F7523F16E63BAACB2B00EA
              F97F9458E3C5D7C6B2EAC72B808BABAAB49DECD2B65AF7DB23002EFC3C543DD8
              B87D3FF462EE3A8F00A87F7CE174981BBB3B77C2A1E31E01DC39540CE2BA7344
              FF2ADD1E019C0CC3B0E41DD31F03FD07DEA4F8430F1F3FE211C01255EE8D275F
              184BE903C23F2D0DACD9171DC04B46CCAA8F1E5C373200D890A10E797D2BEFA8
              D58E0A80DBA841B8F9BE96E0F9BC1101C03EE1612E44D2AEB2E14AE69F1C4604
              F07BA2C0B47175DAACDF8A06E01D23E9A771ECCB589A7E340180BF149794A542
              417EE82673D1EA893666ADDD9026003BA32A1D7C63E66DFADC4FED8802E06BEA
              74765C2DD196AD536CAE08A038BF864EF85D18F57604D8572DD10693CF950800
              3E302234D9ED32EBBBFF4FFB7E32CE574FB4316BEF8624EE8025994A387767EC
              C20348B49D27AE69926823D69E744B00981850A901BB5DF144DB697CF30A80DB
              ED364BB44505A026D11611003CF3D524DA2202E0A29EE689B66800D425DA2201
              809FA18A24DA4E2332778E9728E833E3A458A28DB16937E4010097E5144DB4ED
              54660EAC038097B020CF4FB9289A68A38C4AFBAD03789D3A931D8B27DA327B8A
              4DCB00B8905345A2ADA878D66919006CBA3277364D3589B68D35335F960150AE
              9978F4A0F1DE00A84AB4A1C85CED0940D337DA3851978C7902A07AC34541B109
              60DF1B9589B67D33F77B3C001079A36D5FCAC37A3C001079A3ED30B9F7AFB20E
              C0E4733FC5601980FA445B2A34756C1980FA441B257ADA6F1580A9DD6E2A787E
              6C118099445B2E76A96D0D80A9445B49F0BCCF1A00378F1E04610980B9441B8A
              CCD50B0070D3541F3399683B8D2A560098DF7051302C00309B68A3444FFB2D00
              68FED3D154A0DAC71600D4D64074FE0E4054FEC1FD6FC484E59D5FBEDF01F31A
              553DA303A82AEFFCE41DC0BC4655CFE80066E4AD3DFC0F0000FFFF0AF07BA100
              0000064944415403001D3192C19EAC71350000000049454E44AE426082}
          end>
      end
      item
        Name = 'Compile'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000636494441547801EC5C49CC6453142EF318096281C49C481022C2CE10
              84105686A520B1B210ECC44C6287958518165684955962DC1044083B53101662
              4CCF737F5F75FECEA95BF7DED3F7BD77DE79DDFFE97CA7DEBDE7DC7BA6AF5ED5
              FBABAADFFEB3F8E7DA8120C0B5FDB3591010043877C0397C9C01418073079CC3
              C71910043877C0397C9C01418073079CC3AFCE33C0B9E9327C1020BBE130F624
              E05DD4BB6322F216F2708117016CFE552E15E7835E03B50B095E044CA9F9E8FD
              1C24613E18F3C18B80316B9C742C2F023E9960573EF0C8C98B804B51EC6B90A9
              E05524720564747811C0426FC4C37E05813A8BD2FA549FDD0C65BA6E657E136C
              2EF024C0A5E0A9050D029C19199100E74A271A3E087026260808029C3BE01C3E
              CE8020C0B903CEE1E30C08029C3BE01C3ECE8020C0B903CEE1E30C302640731F
              04681D32B60701C60DD6DC07015A878CED4180718335F74180D621637B1060DC
              60CD7D10A075C8D81E04183758731F04681D32B60701C60DD6DCEF9B0468554F
              C81E043893110404014B1D387E49339CC2D277A72CA776061C842AFE805881BE
              19C3CA7FB3DFA911B0B95201FF3B53C5BC60AAADADC5587032C6644A046C550A
              6EC9555BABC5525219CEAC253A5CA4BAA7BF603E0052C2E12543455FDBC3588C
              59D93E8E690A047C89528F859470060C1B20ADE01EEE2DED63CCCF4BC6B1F4DE
              04BC80422F8094703D0C3F42BA827BE9A3B4FF42189E87B8C19380DB51F56D90
              129E80E10D485FD0077D95FC308F5B4B466BFD800434A5AA3DF3DE87B7FB2043
              81BEE8B3E4EF45186A6722CC36F020E01894527BEDFD15F62B2143833E7FAB38
              E57B1173AB2C19DE343601BCFAF8BB5206AFD14FAED8FB9A4E8203C6C0210BE6
              366A4F460D8692B5EBEF43B026C54350F4116C5F402E865CB04D4EACC7631250
              7BE6B14E9E1D3C4AE14BD5C350F411FA808B05E462C9059BE4C4723C1601BFA3
              88DA6730BC26DF8E35124F63C2376B1C7A813EE84B3A612CC6943A393E1813E6
              8C832DC62080B72538A152C645B0FD0391B80E93BB204381BEE853FA634CC696
              3A3966CE1F4B85C5D89A003EF32EAE247E076C5F4024F846F9BA540C34A64FFA
              96EE189B39489D1C5F82C993103358127033B2E6330F872C5E82F63988C48198
              FC02B1027D3386F4CF1C988BD4C9F1DD98DC00318115016723DB9721257C0DC3
              2D90145B5285C13C1783B930A75238DECC833595EC9DF516041C856CBE8394F0
              1F0CE743526C4C1586F35C2CE6C4DC4A6159D391A9B1EF7C680278F791FF2B49
              F18B92A333F6EFA1D3AECFB16430301663A60E991B734CF52BF33518B0461C86
              C1D004F0F2AE96592EDE2BD850FBD8186613302663A7CE7339CA355A8D72AD3A
              D682A90EC482F5629C1B1E9651F20AC4ED5E3DC887B19903860BC8E52A1768B5
              CAB5D5F15004FC8428B5A44F833D7DDD3D0FBA6721DE600ECC45E6C15C99B3D4
              C9316BFD412ABA8E872080B77B3CB592C0B5B0FD0C91380293DA5507CCA382B9
              30271994393377A993E3D3317913D20B7D09E06734B5DB3D3E8EECDE86A4589B
              2A2630CFE5C4DC5943293D12747FC9B827FA3E04B0F1FC94B214E73D181E80A4
              18F5D3C634B832CFE5C61A584B69EB63305C0DE984AE04F0F5912F3DA5A0FC8B
              3397D49FD8D03526B69A83B931C734106B614DA97E65FE0E06B5976198F360C0
              BCA5ACE51B10BFEC2EADE047B9A7648C1F41771C64EA608E1F6692644DAC2D63
              9AAB782172E87CD4F0D08500ED122C97C4A3C889F70AC561AFC065C8F211488A
              5C6D720D7F0A23E7EAB895806F158F397F97630F5F47711808E3B87910614804
              0E0BC8D528177C2327DA587396EE3F27558839BFD0CEFD19CF5B02F3CFF7BD51
              F8B2294A9C0F59236B9D4F320FE7667445550B016715BDCC66FC49C7BF15FBBE
              6662ADACB954D7992543AA6F2180DF10A5FB39E78FABBEE26095096B66EDB9B2
              4FCC2973BA16023ECD39808E3F6AE269B91A85B5A3054BF86C495350B410B0AE
              E023D4CB1DD0AE1477EF6821809B9EE14348B5034D3D6A25E0CE6AE830B2034D
              3D6A258001BAECE1BED520CDBD69DE802EF2CD96D7F44F611CD8D501FE74853D
              616F7669F6F0B10B012BAEEFC180414366B37BD18B4E6820A093FFD8A4742008
              501A646D0E02AC3BACF80F029406599B8300EB0E2BFE8300A541D6E620C0BAC3
              8AFF20406990B53908B0EEB0E23F08501A646D0E02940E5B9B77020000FFFFD6
              B87CAC00000006494441540300FD2C0CD0D95F87480000000049454E44AE4260
              82}
          end>
      end
      item
        Name = 'Upload'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000009F2494441547801EC9D67A8244510C7D7ACA78839A26238C52C06CC11
              339831A360C008A2E8171551414550F4931941C19CB39830A0A2A28282398B39
              82F94CE7FFE7BD79BBB3AFABA77BA66766776F1F55AF7B2A76574DECE9E99DB3
              33FE6B3502E304B41AFE4E679C8071025A8E40CBEEC747C038012D47A065F7E3
              23609C809623D0B2FB413F0256567C2E11BE2B9C29FC5C5804F74900D9F7549E
              2F5C4438B03068095853917A424800C10F553F45385D180A734C08AEA6F20CE1
              8F426CCD5079B270A060101230AF22F2A49020BDA97207611D809F4B657866A7
              D3C1D7B1AAB70E6D266075F5FE57217BE6762A9B862BE5904470CA52B51D6823
              01CBAAABFF08DF114E13B60D7BA80124E235958D43D309F8583DFC42D8B45FB9
              2C84F52441226E56D9183415887DD4233AB792CA5878450A0708B9B82EAFB208
              D8A391DD5B822F0863E12029D0D62D54D60E4D24803B99BB227AF2AF648F1112
              447063D56F17C6C2BD52D85C880DF03CD563E039097F20AC15EA4CC07C6A397B
              12F7F2AA16C2C392986B02AF51991ACE924112B1844A4E832A0A611549D08755
              55D6027525807BF03F025BCC3997C0EC2E79F67E15B5C2F7B2CEA98C64BFAE7A
              11BC2581DA8E843A12C02D254FA16AB717D80B09FC215EA9FA98247B7D99E748
              E5614DD529F091286B096B83D409E0C2C54355518379E2652F2C926B82FFA79C
              2C26DC4CD80B5F6B8353908AFA206502365233B970A93081C39FBDFE6D53A23D
              C68B724DDB5E52C911B18CCADA21550218F07AD9DFDACE759D4E870BA08A8186
              4DD53A8E0815F543AA04B0C7F85A7BB4984708C7D017811409E01CDA6736B7B9
              ADB6AE158E1A2CA00E718BAAA23C544DC083723D8FD0029E809FB198434C6720
              F1B789F67F3351962AAA24604579E4DE5D85138E13F51EE1A8013B15038959BF
              9654E5706129A892804F3C1E9F15EF2AE1A801EF135CC32AD797ED68D904DCE0
              71F8BB785B0B4711F6F574AAE82ED0A95A3601873AADCD224E9B5534F2FF1C79
              01553402BED15C9E837CD7436703CB2480D7864E63223294ABA21120F067CB13
              485DD54680A778CB11431716CF498F4D00F256037E90875B854D000127F0992F
              EAD0B2ED3A4B9EE2DF301C30BC32B7C1739209A893611099B160B03ABC6AB478
              29E9049A80F7DB8406AF9F5EC7F63A1EA34FF7F28AEAB10960A4D365F355118B
              1EC8245219083081B60CC143C6E2A7A45B2F8918900CF6139380D33C56B90079
              D8495804960017194306D922B9AA7C5E935A368EB218FDF498045CD4AF3CB1CD
              B8FE44B5B6828012D85007C8A2132A5F56CEBA21097EA3179300AB911B5A8C44
              7402494063CDA1836EAC5E8CFC368630C3DA062B4F0E4DC0F179B5DC162F2E72
              84841B0490409635892E36CAEA17E9F17EC39239D262F4D243136075E28E5E63
              89EBF8248055CD62035B55ED58FA771B8C8B0D7A8E1C9A80A5725ADD8DE08B4D
              5725A846C0085C90708010B6B019201A2D72A2A1B1A841CF9143139053EAD9F8
              A9A79EAA4AA008582A7B991D6C623BDB4E557E59C5504802EA9AADEC6A370122
              502E5E469B3FAB384A1F0F716CE3837A13B86791939004EC6818F18D881A2A5E
              328121403E2102CC6C6A4B061E32161F3A3EF0453D15DE68183AD8A04F924312
              B0FDA474BE92725A37012130790FF92D024B80F3D4A95B333A9D0EB253395D0A
              BEF0D9A554ABDD69A8EF62D027C92109E89F2F932987CCFFC9647D258120203E
              19021A12FCCC06B2E864DBAE129FF876F162690F180A8517E2900418B63BDF59
              8C083A0120103E150249407D322E1E3AE8BA78190DDFB421DB2E5BFE25451EBE
              5C28960D5512605B0DE3D07102E093268004D227E3E3A18B0D9F0C6DA02D3E99
              DA786D25800ED3715FC798B349007D32213C6C0C6C12DA484068F0530E6F0F6C
              12DA4800D3C27D7B2E7B7ECAE067BE4802B6B36D5759D436974E255A1B09E043
              09EB6B15025447F0B320611B1FD9766F499B685B2FADF67A1B09A05374F4422A
              3D486008500FA9962A3EF0D56BBC95E0D380B61280EFD3F52F4B020121302235
              02F8C227CE68033B04F5C63124013F1BAD4AF1DD1449602E0D0131DCD446C627
              BE694355274CCF67A2AE0BBDB64312F0A861A16F90CE902A26FF5D2C529B442A
              DFFB192DB4A6AF4C8A574940E140D3A497D1AF583305F954D6DBFB90043C6458
              B006E90CF191265BB1B8A2A8D72109F8ACC8C8986F46A03076210930AD8BB1B6
              7076874A33C14313609DCB52BF9419C6645E6634DA9A3997130F4DC04939ADEE
              C606DDEA6C5B5BD7E8F909063D470E4DC0A739ADFCC626F9CDD96A6B4B4F6F83
              DE978426003FCFF3CF81451F673B54468664CD167F24B4873109D8DF30CAD364
              F6586F888C24993E83AECE15CE86C8946212E09B841BB29C64E67354CAFF1724
              717486E10886391CACA9A49804A07D20FF1CB8B868BEEFA7C41E295858BD5941
              E882A8219AD804DCE6F238418BFE3E6A426F180BDF05F6A9980EC52600DBD65C
              4866045C8EC08823CBA971DD7375732F17D1472B93005F9099C6BE90CFE190F3
              8897F5013AE7FEE8C96A182C1313DFFDAFF5FEA08C1F4B87A3CD85967C2ABAEF
              E25AEAFD48D904F04CC067A956C7BEB218434EB7C6FD595AB3D435B06C028823
              773E942E5C5AC4511C27624C6C67F5AD1F585AB39F16B45D250138F0AD9DC04B
              0A16B7406E94F03175662B6106D687EB19DF5B564D009FE770F8594E582E9E25
              E42DFEB0D2197E610C8CA39C2FE74BF7A36A0270CCE1C7E454EA2EE447145C4B
              BCB8648789C6EA2887556D708A04D006D6E6A7B490458E0A5F505BCA53E82344
              48950042C21A6A9416B2002A8BA51625CBD26F8ACEB8D6B74D394B9900962A2E
              7A08E3DE9D399A03F1EB157D416607E1616A39D1595EB39124A44C80DADDE117
              3142D6DCE4D72BF811073A8A5EDBC89203FDA748DAE61BF349D2E6D409A051AC
              218A5DF626B62D4486BD8C87B6A223C7B251957E8B0CD04EEB5692671DDF03A7
              D4AB0141A866C1AD4DA7B0EDFB943FD3E4A18DE18B5F44B0D65E102B19B0CA21
              B78EB4D11A5EEF75C6B4C3A2EB5BAF7C549D204529440A73189F1AA8B3A0E458
              EC88C0F05B022C8B295212E0B498EDEDACF3B946A0555E2D122316220C548913
              C3789C46BC343FC4C61E446043B5779520CB62A2C3B582E0ED265A2830578759
              693C9F60832331646FEFB5CF91493B7A69C9EB4D248046738784AF32773FE811
              3CA648860CF7DE2F87ACD6CBC2B173AB1E0B174881BB358E1455EB053A57AF87
              BCF5ABB549E71E573968C0D33A6D3BB3C986359D80AC6F3BA942674988AAAD02
              6DA02DD65073AD8D8B48402DEDE09444E739C5709AAAC589C328D706A68EE09B
              3638449A21B59D80AC97BCECE7424D403877F36C90F152953C9F30448E0F8643
              B856A4B25DDACEA024A0B703BC73650D52020532EC7BAE047CC3DE62E7E07D6D
              F19B05D9A90E3BDC8ADE24FA40C12026A03F400CFBF27137C3DE9C36FAF9FDDB
              FC92DE7411F9D58E41BCD8AB695D188604745B3B82B571025A4EEA3801E304B4
              1C8196DD8F8F8071025A8E40CBEEC747404102EA66FF070000FFFF643943E900
              0000064944415403000E6A46D0330D68FC0000000049454E44AE426082}
          end>
      end
      item
        Name = 'ShowLogs'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000004D3494441547801EC9CD9EB4D5114C7B7E141DE4CE5C9FC0F484894E2
              8132940CC99094C8238F2825BCF128529221C9F044224AA284FC051E0C29195F
              0C91B0BE7EBFC3B9A7BDF6D9EB9EBBEFDEFBFCD66DAD33ECB5F6DAE77E3FBF73
              EF3DFB9C7EC38DBEA22AA000A2CA6F8C0250009115883CBC9E010A20B2029187
              D7334001445620F2F07A062880C80A441E7E689E0191452F0FAF00CA6A44D896
              02584FC7F893FCB7BAB169006DD69136DE2601F091AA5E201F41AE665700DA5C
              A4D07B722FF305808263BC2A6A121418478B77E4B5E60360155541415AA90914
              184FB92BC99DE603E092B382065D0A5C710511F30180CF35E4AACB151859D7C5
              070057631805D48D293430DDBC9A00E8663CED535140015404E9F76E1F01F4FB
              ADE5319E0288CC49012880C80A441EBECD67C00ED2B69830DB49DB495A5B019C
              25B58F9317768C364E9327676D0480F7B4C9A2F4164B5BF4261C6CF483E8F101
              BC76D4BBEC884509B50DC0245271223967ABB940ACF6B60178EE21E4198F9CBE
              A5B409C006520D1363B472DA6667B4C7C1BA726D0270BEEECD96E2274ADB5137
              DB02E09450C5EDC2FC60E96D01B09551E807D38EE62358C4F6360078E61011F7
              B25F31F1DD4C7B5F9B7307801BDFD319C59E52FB67F219E49C1DE202FD6A6F02
              A09867E9C5FA6E976FF88DA3DFACC1183E86B8BC3D94D38BE3470D2A25B72600
              E4A3F13D1652E83EB9C4965232F7C040F52F7B1AE52669A9008038F3B110F80D
              47EEBE4AEC1BEDBF254FCE520200716E63E1E1471D390B98D854A63D6A736A00
              167BAAB18BC9C35FFA0326F695DA5F922765A9018038D7B070387EDD7061FC2A
              32868B1A3399422FC893B1260030EFD2C439219739D4194DB199E4367B448DF8
              2BA795D3A650B4C971737DA9ACDC9A00908FD6D9A3F899D8D93AB0C7CDDB7F18
              085B9773ADAD8937C60400699E606171DBBC3D041E65C945D37E2C72F4D80066
              3B443B57893DACEC97770F947772DA8E0D005A3DC6C2E21B4B6D7B4BDBD54D9C
              19D5B66CF6530030C7A1D6C9C1D8C1C17575F5851AF0E54BAB3C2D0500508E3B
              0BB651F00E396713B8402EEDA900709D058B183171C1850B2F269C47732A00A0
              96F4A3849B7240AD6C3C2500922F53D7977236E2E3407B0800E51ABBEF5970B8
              F1488914480D80CF59E0BA824E4456FFC3480D008EDC75C1855B8CDC1C12FA66
              E7290298E7501137D91DE1FC422902808A37B1A8F82DDAC7FD5D5AB5C7520580
              FBBDF74A32E3426D4969BF359BA90280C0B8515FCCBDBB2ED4909BADA70C205B
              512507AE00246A05C8550001449594540012B52CB94D9B144053051BF657000D
              056CDABD09003C90AA6E4CA141572C7C00FCEAAAB2768202808335EB3E00D6B2
              BD3550A7C09ABA041F0057A9C8277235990278880CDA397BF9004081B1B44041
              5AA9792880FFB35AF79CEADF32BE00908C822B68E33BB99A5D0168B39C42DE4F
              6B4800505D832797F178603149A66BF3EFBF26420B6873DD085E520082D29AEA
              A3409E007CDE5926390A20322805A000222B107978DB1980CB67F5FF733CBDD6
              A203B90D404782EE8455400184D5B7B6BA02A895286C820208AB6F6D7505502B
              51D8041B00CC69A89B8E399E5EEA61CA2F1B8072BCB4AD9B21145000215415D4
              540002B142A42A8010AA0A6A2A0081582152154008550535158040AC10A90A20
              84AA829A0A402056885405104255414D05502356E8F01F000000FFFF5B5CF47D
              000000064944415403001D8860D0181917670000000049454E44AE426082}
          end>
      end
      item
        Name = 'Clean'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000004D7494441547801EC9DC9EE0D4F14C7FBFF1776E2014C6FC02B8844C4
              B81462C1CE1E910831059188F00A4484A5182212EF202C6C4D2FC08E98CEE9EB
              DEF450DF9ABACBA9EE3ABF9CEAA1EAD4A93E9F6FEAB8EEEF5EFEAFF44794800A
              208ABFAA540015409880F0F253DC019789D9576ABF3B8DFB788CBAA7635312E0
              336165E817E8BC9E5AD7B88FC7D8E7537730D7FB2908B09FE031D48D74F6B54D
              E4C873F6D1396BCB5D807344EF09B5587B4A13CF52CBD67216E02051BB4A6DA8
              5DA7001C8B4EF959CE023C1E11D798B1467CAC7CFF1EF0C191E54D1AFFAFD36E
              D1BDCDDEAF0633BAC875076CB13062F0670CE3A7A9CF96CF561ACFCE6C0F2CF5
              B0372C0BAFB18CF110BFF2B1F9F09F07EC974DCB518093800E979D5F60ACD9CD
              3EB79B1D8D6BDE258D5BF9CB1C05580BB098CA0E70AD908828368A93BC3F4701
              92279DD3022A80B01A2A800A204C407879DD012A803001E1E5FFE10E10CE34D3
              E555006161540015409880F0F2BA0354006102C2CBEB0E50018409082FAF3B40
              05102620BCBCEE80C402B8C2AB002E4289C75580C4805DE1550017A1C4E32A40
              62C0AEF02A808B50E27115203160577815C04528F1B80A9018B02BBC0AE02294
              785C05480CD8157E9E02B8B2CE685C051016630C01D6510ECFA8F167F3C76814
              CA68A1B18D41A833340EF2E72F000EFEB4F550011E5142DFA8EDA5569AF15760
              BF53D20FA845DB1001F88BD387A2579ECFC42394CA476A51162B00AB1EF2C5E9
              A8879BD0A4CDF4ACF7A9055B8C00FC2539563D78B1994F384AF9311B3AF95B8C
              000FFDC317E7C9952128E9180150DD67F54B6A26D0874D9DB6BE18016CF1742C
              90800A10086C6CF7110518FBD1CA88A70208EBAC02A800C2048497D71DA00208
              13105E5E77800A204C4078F9D01DB043F879A7B07C10A350012E5A08A0DF1CCD
              B51FA1B031EACD09152048DDDE6A33EC30A414C4285400C37ADA358440880041
              CA0E79A819CCF566152200AA6DA7085849BF0768E6CAB953FA3D43AC7A8E2102
              2055EFF4A296D3817247AC7A644204E84DFEDBC1FF4CE4DFCBE24E8373F71500
              29FAA538E4FD841103C4AC15C1570054D3AEB4A29579831820662D4ABE022035
              510D6C2D32F31BC400316BE1F015A035A97133B80636624DF57210031F019092
              A8F64D15E490E7462C10BBD55A3E02A05A866ADF2A78E7E239DD2FDF177A45D7
              F1B69899533CC402B15B6440471F01908AA8F651D89EBDA09E3DD496B6932E5E
              528BB5DCE2211688DD2A6F1F0156CE9D8B90DAB7BB33976F77F121B2E5162F84
              452B659700484154F35AC10BBB414C10C31A8F4B0054C350CDAB83167A404C10
              C31A934B00A41EAA7975D0420F88096258637209503B190ED135CF106B2E5D51
              4C6C0220E550AD9B0BC82179203688656513E004781254EB807B51DD880D6269
              1500FDF77FA8D615451A248BD81C00FE56017E824951B50EC49A5B3762F30325
              6A2B41EFDA93EA3B54E3EA413DD4044C8C4C2C6B679B00A6BAB581662DDFCF09
              39D334A385C468FA1A835167D327E49AA61A2D24C6D2971975839958D63E3601
              5ED71E7A1883C01B14C42600CFD9CE076D83086CB3CD7609C0CA5DB305D0312B
              017E59FAD6E6E11280E79EA7C3716A6A61048E91BBF57D201AB7BE0CE5F165BB
              4B17FC81A44B7456B31360E8CCEA9EDD6D31EAB303169E8BE3653A71706D5585
              1870D9A97C7F4205F08DAB7E9E0454004F50A9DC540007D9D4C37F000000FFFF
              5A4FCD9E00000006494441540300923517D000DB33780000000049454E44AE42
              6082}
          end>
      end
      item
        Name = 'none'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000458494441547801EC9CC9AA153110868F23822EDCBA1044D085E323A8
              A0A02E7C0D5DA8A8088A13080EA088D3429F4270A30B05F10D9C50D48520F804
              BA71F6FF8586BA8713FAA43AE94ABA4BAA4ED29D4E55E7FF6E8E3DE4DEC513FF
              67AA800330957F3271000EC05801E3F43E031C80B102C6E97D06380063058CD3
              FB0C7000C60A18A71FE70C30165DA67700520D83BA0330105DA61C13809518F8
              09F87BF8DF807FC0FE43F045F05E6C0C00EE40490AFE0DE50DF84678C836A0E1
              1EFC0F9C7DEEA3CC6A43067015CA51C42328B576101D19E312CA2C3644001CD3
              2FA8751A9ECACE2210412C4399D478B249031A07DB86FCBFE14BE039EC07826E
              8727B32101D80D555EC273DB0B24D8074F624301B0056A3C81F7658F90883951
              74B32100E0D7CD6B850CBCD4941E1B8239993BB6DF82E37B04B0206FCA8D9F29
              8345C6E2FF09915D161E5E3B800B180E7F8A519818F5E315923A3903A83B17D0
              F16201E7D0E91EA16600D70B10BF3905DEF435F5A8B2660027A3469AF760F54D
              5FAD0056E4D553155D75975C2B003ED554A994B1D3714DEC5A011CD60C36731F
              D539D50A604D663135E1D76A3AD50A4033D622FB3880CC58DAC23B80368532B7
              3B80CC02B78577006D0A656EAF15C097CCBA68C27FD674AA1500573A68C62BFB
              F01DAF74D9A6A9ABCEA9560037350A65EE734B13BF5600962F61423A733140A8
              2DB8BF56001CD0357E14E2EA77021A00F27B33677D578BB8A75ADADB9A3FE100
              BE4DA3B38E4DB59DD7F6D400D0E68AEDF7608E0E97E7382674C87AD120EB62F7
              5CD5C1BE925C3DC7F0CFE118CE4214C2FAAB720DE9952EE94A9E011CD7437EB4
              F8F296F650B3FCDA91F5D0F1B3F6AB5EC2C840A50338204F3650E73A50CD72C1
              7588C7D943671D9B51B619477306A0D05BE90038B2E7FC68F15768DF0FEFCBF6
              20D15B7867D300E055439FBE63CE513EC6715C9C8B22AB6D42F4A7F024A60190
              2471A6205C2EB814B13B7F3520C6B4F1468B4B11DF4D3774D91E1A006AD10875
              861B89FC18E264013B4400D0EABF71B114BF2AD577A988C26B7CC6B88D7A161B
              32804630DEA55244AE25E2D2918F4DC38CF20DF61D85F3D2967D3A5DE3234EAB
              8D014023C27754F8C492BFA4477167F9561C7317DEDBC3BE310180AEE5594200
              E50DAE86337200C6941C80033056C038BD6606F0E1550DFE15DAEE84176D1A00
              450F489CDC2AD49FC19B1F16FEDD87BDD82ECA860C605A68FEDD073EB09BDE6F
              BA3D2600A64287923B8090323DED77003D091D4AA30130EB194A4DFB425AA8F6
              77EDA401D035A7F7170A3800218645D50158A82E723A00218645D50158A82E72
              3A00218645D50158A82E723A00218645D50158A82E723A002186455503A079BE
              6E574E265D725BE81CCCA901100CE60DF10A388078CD92F6700049E58C0FE600
              E2354BDAC3012495333E9806404D2F5F669D6BBC4A197B6800643C9DF1857600
              C6CC1D80033056C0387DC40C303ED381A67700C6601D80033056C038BDCF0007
              60AC80717A9F010EC05801E3F43E031C80B102C6E97D06B400C8DDFC0F0000FF
              FFBB798F9C000000064944415403006E88CFC122BC98C10000000049454E44AE
              426082}
          end>
      end
      item
        Name = 'question'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000004BB494441547801EC9DBBABD44014C6E31345C1B7A08D88956F1004AD
              C44205F181E0ABB31714142CFC07AC2D142CAC6C544451504410B4D44A50B152
              502BC1C75504DFAFEF73EF426E76924CEE66E664668E9C936CCE4C7266BEDFCE
              BA99247B2766FA4F540105202A7F9629000520AC80707A1D010A405801E1F43A
              021480B002C2E95D8F8083E8DF2FF8DF449C7DDD8FBE5A9B4B001FD08A8BF049
              F0548C7DBD8CCEBE835B992B006CC01CAB164854729F731E52BC85D79A0B007B
              90950DC02A699B8FDEEF82579A0B00572A33A65578B5AEBB2E00F073B02E6F2A
              E593EB3AEA024059CE092888D9D1BDE6E61340F3D625B087021086AC001480B0
              02C2E975040400A06C1E47B8E971A4F73802BC0A360BD966C23B6FB100380CA5
              F323F523B63FC3F3B13BD89E0EEF94850EE000D4A4C867B1AEB3ADA8F005FE04
              DE190B190085BC340E2557611F429B86B5B8850A80D71A28E430027EC5CE9C1A
              C14ACE4204700372955D6BF889B263F0B5F00DF023F037F032FB5156E02B1E1A
              80B910A66C8E9DA24F45F969F863F843F819F82238DFE9A60B249CADDC867231
              0B0DC08B12A5F8794ED14B8AFF871762F90C5EB4DBC580CFEDD000CC3088B311
              B1EF701B5B69A8C4D16108FB098506801F315320CD7D38ED13160FE04D8C17CD
              8BF5671703BEB64303405D78EBC766BCE03B7731D64DEDBC6187D586582BA1BA
              83840820DF279E58E5B76D5E3F3754E2A83284DD874207301E85D618767A6588
              7909A508E0B841D9B26F5786AAED865204B0A95D09873B5A6A004CE701878693
              70B8BD5302700B522D87E7ED37362EC0C52C15004FA1F07678D1C4BEFDF41B92
              02009E3798CE809740044E4B632567B103A0C0A65B25D741F2D770718B1900DF
              F92681391A1E990A24627102C8327EDB31BDF33965CD3209AD8D396304B0023D
              2D7EDB4128DB8B45DD9435AAF8B51801DC3548C8A986DA7BF50DFB390FC50880
              57C08AC22D2B06BAB21D230093B63CE132C5C5632900782FAE724503520070AF
              A2FFE2453102E0D5B2BC9F1057B9A2013102E0F5E2BCBFACE8BF78518C00C445
              6DD20005D0442D07755B04E0A075091C324600BC0591B3A07D3FD5658EB101A0
              E8FC8D86BCE627B1711DDE498B09006FC42D1379775981743C26007C4CA94ACF
              F555855265310128BB00D3D7F65BFF4597D63101385A232C1F69AAA9E2BF3826
              00E720DF08DC645B4CC12EC46202403DF9044DFE3F634E432F4581E9220DC2F2
              161B002ACAE7C278EB3A9D8F20E95C105589D587ED578C2360584DBCEEAF00BC
              CA3D984C010C6AE235A200BCCA3D984C010C6AE235A200BCCA3D98CC27004E15
              C7EC83EA5A445C00F8639137952A7CC355F6D505807D9519D32AE40DC1953D76
              01E01A32964D8AA12819E31D79D4A2B2C32E00302127C5D800BE6EDFBB7F44FE
              FD84E2A55163AB5D0160323660275ED8FE9209AA066FECEB0EF46201DCCA5C02
              60036E62C1DFF2E1CC640ACEBEF2715874DBCE5C03B06B45C2B51480307C05A0
              008415104EAF232060003CCD4ED15B45663302746EA755C9C71ECC0680CEED8C
              D5ACD52D1B009CCF18C9B256F3EAC14615B001C0AAA9CFED5003276E0B80C953
              9CDB61BF9D7A13006C486A733BA6F92BEAD09A3705D05A623D504F0105D0D341
              6CA900C4A4EF2556003D1DC4960A404CFA5E6205D0D3416CA9006AA4775DFC0F
              0000FFFF86101DF000000006494441540300C8E526D0EFBFEE3C000000004945
              4E44AE426082}
          end>
      end
      item
        Name = 'serial'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000462494441547801EC9DBDCF0D4114C617118444A35590A0225149741A
              898244242A85462474FC013E7A9D8F44A35209898E6854A25228297C968884C4
              8B04CF937893FB317B776676CF9C39778F9CB33B3B73CE9C99E76793D7DA7BDF
              B58DFF5155C001A8CADF340EC001282BA05CDEEF0007A0AC807279BF031C80B2
              02CAE5ADDF01E7A01F1D279B6619C066487EE3BFB38DA63DB30CE0FB84DC93ED
              89EE966645DD5601BC086818EA0B84D5D56511C03148B81F3E6BECE3D86C7FD5
              D7D600AC839A0FE16DC631C6B48D57D76F0DC0AF0805636222A629136209C063
              4812B35EC63016E1F51B175BFF2A9BE6001679181E6B8C654E6CBC5A9C1500CF
              3314CAC9C928D32FC502801F3DB6D827B747D9F8D4DA01DCC15636C2738DB99C
              23375F3CAF6600BBB0FBD3F0BEC6393857DF7944F20B02485EFFABE48CF68421
              E76AAF9231522B804F197BE94A9198B3AB66E778AD00B661E56B16388682B628
              87730693343B6B05A0A949D1DA0EA0A8DCF3C51CC0BC26457B1C4051B9E78B39
              80794D8AF63880A272CF177300F39A14ED7100C272774D5F02C06D2CE2EF8CBF
              C4F576B8961D45E1D935C55E23753893047006CBE4A6784673CAF6E2EA3DFC2B
              7CD42605E03854E5DF7C9C16DA568C7E838FD6A4003C4850740B622FC0476912
              00F8BA60AA98D7521396255E0240EECBB2126BA99E534D9BDE57BD5A020BAC09
              4095CFEB05349F9AB22600265FAE9D5233E34202C0C78C7530E50B0F63730900
              0733447C9D91D39E62684402C007ECFF0D3CC5F6A4042F53AC0400EAB3138715
              788CED40101F59E0343E9302402537E1B0E871C4678CF35DFEB7388FD6240150
              D4B33CB4387FECFCD33226DDFD0C050ECD382E83161B174CEEEA9406D0555F6B
              9C77DF53149F745C066D3286ED60506EE75801E4EA35789E03185CD2B4091D40
              9A5E83473B80C1254D9BD001A4E93578F48000065FDB28267400CA981D800350
              5640B97C893BE067CB1EF9002ED75BA66C72E7635E684EF18FB996007033B433
              237DB7A4D7590280E5777E2E2E0300EEE1240FC6FC4489F596B803B88F7B3858
              82C0B5A6BCDD87EDE55929005C1D21F063A4577151E377FAF08785CB581BD7C8
              B5A2296F2501ACEEE6121A1BE0DC68AE233D68B9F3318FDF2B712538EB82CEBE
              431A00FAAE79A9F21D80324E07E0009415502EEF778003505640B9BCDF010E40
              5901E5F27E073800650594CB5BBC03569A76D162DFC86E9FA1F0882500EBA10D
              FFE78ACF91D00C1AC71863665F66160AB9539EA0FE46BC09B302E07CA29ADC17
              BF2E2131AD7C38175ABE6A7AC5EBE929CDFD8C9CE2295600E408C367FC397945
              739619405121738B39805CE506CA73000309993B8D1500293F82AE6A9193B39A
              5BEC6C0540CE07B9771753B147A104003DAAF44FE567899F244CC3D87709F16A
              A156005020FE66A4BB6C74386318DB1156C7B0250054EC140E7C7FE711CEB3C6
              3E8E316676ACDA6B6B002824DF603B8206FFA135E9ECE31886EC98450076D48D
              58A90388104932C40148AA1B31B70388104932C40148AA1B31B70388104932C4
              0174A82B3DFC0F0000FFFFE159D49E00000006494441540300014186C1FE3C26
              170000000049454E44AE426082}
          end>
      end
      item
        Name = 'wifi'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000009A6494441547801EC9C65C86D451780CFFD82AF3F0B1B31B1C1005B31
              105B04BBB10345B1C042C5FE612B7677FF105B540CAC1F2616B6D8DD5DCFA3EE
              F7EEF7DC73CEBB6776EBBEAC75D7EC99B5D6AC596BC7CC9A39EF5F7ADDBF5A3D
              D005A056F7F77A5D00BA00D4EC819ABBEF9E802E00357BA0E6EEBB27A00B40CD
              1EA8B9FBEE09E80250B3076AEEFECFF904D4ECF474F75D00D2DEA8A1DC05A006
              A7A7BBEC0290F6460DE52E0035383DDD651780B4376A283739004BE38F7DC0EB
              C037C19F03F10DF8955587BAB86C1E34210033E296A3C14FC1B4931FE4FA3870
              7D701630146645405975A82BADDBBE8EA2DDBE21F5411D019881E19E0F260E79
              87F201E0FFC1AAC0BE0EA433FB4EEC388FEBE9C14AA1AA002CC9A89E011DECBB
              D06DC1A6C17618F41EA88D4F4397004B873203F06FACBF1B74400F431700DB02
              0B62E823A0B6DF05752C90E2A18C006C8E991AFE257425F077682D5919CB1D8B
              63DA8C72A15064002EC6328DBC0CFA4785CB199863BC085A081411809BB044A3
              B682FE59606B06EA986F84E6823C0138879E35622D6819F01D4A6F00F7041706
              2705A232CAAA435D88170E6BA3511F9C0D8D82980024EFF81DA27A1C2CF412D5
              7B817EEC1247FF83EBF5C053406725902050465975A82BD16B1FF6F57290B6D1
              CC3BD26C20368506414800A642F3F76011EFF81FD1E30A3571CA3C5C9F047E0D
              960DF6615F73D391FDEB837D296B1324175C81B43E9A1A9A09EC3C0BE3A5307D
              02FE0D8C05EF909D1176D0EA3981721340BB8EC7106DD2366DB48EAA2850CFC7
              485E024E081305605A3468CC16D058B81A4107665FD1EF4A745405DAA8ADDAAC
              EDB1FD6E89A0BE9B063A14EC6858A34BF50F873566A8DF061E07B109B4ADA0ED
              8E21CFCAFD2306AF2F2153C2B000BC0DABC92A4830AC888446173657465FDD70
              210638A6D885A5BE34A38B9AF1D01F80BFD3EC633313341436444023EF85FE51
              E11E06E618378266821493195D7DAB8FC7AAD3015894DA98F9B2330A8D32F78E
              8A52C1F7E952F4E0FB7577A859D483A17B80BE265680569162BE967E1CB3D35C
              8A41A08F174924920038A77F2CA9CC483F804F239C53532C0CFE8A26BF1F3E49
              DE3169F47DFA10EDCE304E85BA8F7004F464D014B732E9147322EB2BF518788A
              0E8E0B3D7DA05DA8CF0C8FC3B93DF8EBEF03CCE1B8AAF53A2BFA712A32777E18
              1DFF00EA30E90594BD9B218580AFD4FDD1940E8E63FE0F7545C07428095D849D
              8BCC853E012E1E2867826FE132E279A667A8E8A9E30C0A3A5C3C94B2773EA432
              F0A9FF82DEECFF0EE8BFC03C7015C28E4B1F51CC045719805B605D179C08BC2B
              FF3911D304ED7EA87F8247DC05DA14581543BE020DC66ED03CA08F9C354DA443
              9FDF62006434AB67CEC4F2205C864A778C2051E0BEAC83BB0669EF124863E134
              2C4B6CA518054E08961B21A9AFF5F9AFDF8084CFACE1A0E995892C3F7C095F08
              759FD5C198F709916B02AF4FABB63F10698C723E0DFDE21B50A1AF21BD7101B0
              C2E955F231313935894AA74D9020D8096E8DCFF3D4A0A211E0D3EF584E8FB0C6
              EF813ED4978A6FCC7FD7836390BC82C62A28F83131F7635289CB203077E4FBFD
              AC20A9706607F416624E9DDD6F7E95B2594E4869B02B9A0D44CC66BDBE743BD3
              57306A26C3A000D8EAD69B34049D19993B32E22172C3786FA741A30DAA3AD3E8
              803CF7B3383C1EBA9A136A9E3FCD6359BED5688BB97B111B086ED63F3FB06574
              E595839A87056010EFB03A07EE9D31E8FB314C6650FD6754BABED071E2EA5C6B
              B4A95D8A013099D527C529A6331B758AAE423D2233992BBC342F228E797E682E
              C81B0073E79E188835C215AA0B2E1DE3868F4F51ACAEAC724FC2B810689F6E04
              79CD65143C8B54CCDB02B1DF204F00EE43C599600CF82ED40126A8EE8F515090
              8C5BA13E11DAE2A64C8C5A5F93A6656264A798056555F2398CCB83A1702C020E
              D6D900C54681DB92DAE6898750C34C45F84A523E4836E6097096F3DFA05E7ABD
              DBE0D738B397141B0D26FAB43566CB54DF040D2E26002EA1B376E23CD81CCF1A
              59051AC4E7E2D140BC126093D3F700F65ED42BC88358EB64E8E510785C0906DF
              15C83509E6C218A7B29091E00236F8831CF30468854158D3C200349D6CFAC23C
              FD80E6A82A8F937B77392D4D3298BE73FBD1C5981B43EE27F85E8EEA6C809053
              D949D49BCE864C013ADF05EC140D1355C40640BDB7F25F7F109EA3CE2DB798F4
              05A263E071F6E464B54EF607151E8D719D302A87EF13E78F32CCDC3A335156F4
              071AAB8C698F2FCC8C687FFA3EDAF9E88A7A052997603A08AE36F31C41F748B8
              1BD73ACCF442EC0678625B9ABA5ABE930A75BB7BE5DA83CB28F064A0D94C855D
              7C46DDF90A8B799E00E5458360BAC0D5A6D7A1E8B69E8EF128A1EB8250F9507E
              F795DDBAB4CFD8D7A4D94C9F749397A1FD8FE32F22002AFCB8D79304A199529D
              E0A67E906081CC6EE86BC341113AFDD645888D17292A00E3B58EBE5A8C6607ED
              5E01C546C09158A14D954F97AB0E8099C447196C53C1ED5953DB95D9575500FC
              467887C5E4D22B73C6EF1DCD0ED556339E14CB852A02E034CD7D82BC23715AE9
              C159D70373A0CC8FA07373D1B275B6C9F33EED79C19CBFC765F2EA19295F7600
              3CC5D63F6F1E6950AAF11BCA3A54078B9E4332FDED6AF335DAD21F41CBD6D926
              8FBF455646F406F0C40322C1E071191775C1825905CA0E80F3F92C698BB4BDA6
              B8759CE7747468BA2DA6EC3CDDC59B3A4F0C54B01FFC598E98C01607650740AB
              4C5B240B17AF87A199529DE4DEEB309EBCF57BA3206B1FDAE3711A44CA832A02
              A0F52E5C3C8E61B91FDD91D229EE15F4B795759D3C65A63B06F571389595D853
              5500184FCFE318FD1B31EEA9BA23657B1D687EC873A3E9BE75BCEFFE745D69E5
              2A03E020DC8A740BCFCD72EF7A671AD6D789FEED0A6D31CBEA2BC7574F667BF2
              32561D00ED35A5EC7111CB4DC2FF618C1F5D48755047008A1CDD7C28F307D990
              76421B03E01E842B55D1FD87A770BD65D15FCA70D91E685B00FC65C9CD23DCEB
              2F655E1FD1DEB8A6360540E7679931CD86975F045B016D09803B6D599C9F38DD
              3F43E0B9D1E4BAB1B42D017822C283A6BE23C4AA15694B00CC76867AC6F348A1
              3295F3B72500953BA6AA0EBB0054E5E921FDB433004306D3C6EAB60420666EFF
              421B02D2960038AD0CF5A7698A5099CAF9DB1200B71CFB53D9A39CE52E9CA989
              513C8D686B4B007496A96C7FD16E79142E4BA3BB7090E6439B02A0373DDF69EE
              7ED0A12ECFA6DAE6415C795B816D0B40E254FFD086CE4E63ECD9D444672DB4AD
              01A8C5596574DA05A00CAF06E8EC0210E0AC3258BB0094E1D5009D010108D0DA
              B166F6401780CCAE2A87B10B40397ECDACB50B40665795C3D805A01CBF66D6DA
              0520B3ABCA61EC02508E5F336BED0290D955E530760128C7AF99B57601C8ECAA
              7218BB004CE0D7B29B7F010000FFFF3991F0B700000006494441540300112A81
              D0CF56E37C0000000049454E44AE426082}
          end>
      end
      item
        Name = 'wifi-disabled'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000B17494441547801EC9C65AC244510C7F7700F2EC19D0F4002C1DD0341
              835B8243700D2EC1024182BB1D410F0D7A109CE0042701825B702EB8CBFFB777
              F36E765ECF6C75CFCEF60ECC4BD5564F7755774FD5F4747575CF9BA0D5FC45D5
              406380A8EA6FB51A03340688AC81C8CD3723A03140640D446EBE19018D01226B
              2072F3CD08680C105903919BFF7F8E80C84A4F37DF1820AD8D08E9C60011949E
              6EB231405A1B11D28D0122283DDD646380B43622A407D900F34B1F3B0AAF10BE
              25FCC7133F11FFADC28385CB09071206C10013493328FA71D1B492DFD1F555C2
              9D850B097D6176096C2A3C43F8B4305DF777BA3E4938B3302A7433C012EADD14
              C25EC36EAAF02B214AF9431445AF2CDA2F98460D1D25FC42481FC0CB949E41D8
              57E8668017D59B9F84C70A7B017BAA126EF652D119858304BBAA335F0BE9DF2B
              A23C7C22D54291013E4F357DBCD21842A4145C2469DAFC4574906171758E870F
              63DCAFF464C24A0065B82AE6499D2553C0AB880E6D94C9375E0EB15107751D3A
              9433D88975D43D1E98BF453717F6145C0698582D5C28CC833B54C00429520A4E
              973413F0EFA2758011EAE4CD421E205EA14A960797017E35548B8B48471636F0
              16B1FCA5C24985270AEB043811DC3F6E6EA97E670D70A36ACBE6292B17DE54C9
              6861596092C7101824A98BF403BA3852B8A290729E422B2E26990384770AAB1A
              65B8B918E21CB5110459656FAD5A3E12FAC0BA62A613538B960194C42B295130
              69DEBFA7A8D2A784948B98E17571A2988D45D3C663FE395079EF097B05FBA922
              74B089A817640D80F0DCFAD94AE80BDF4B0065890C3430A19EAD1EF21AC5D8E8
              E0105D33E2444AC1ED92FE4D38A5D00434EE62BC49999451999266385C9C3F0B
              B931915A004FEE99EA29238E7EEFA1347922413089A47E145E22EC0A28398F89
              4E4C975758903FB9CA70D9B610AD23E0E1A0178C81D7137A0FBB4B101DB2EA56
              D20D34E42E69B50E52014FB34810308A3E08921C1CA12DD5150CB19368281077
              42974EF93C03BC2F6E86A54829603EE12958B4542DF18547AA0B186235D11040
              974EE7266B001661286C9E90560A645E53D943C2BAC363BA010C615E118B3F81
              399540B7138A0E41DA002CAA7C5DBDA18A0C8935C44307A615ED05ECA04A8E13
              1E2DC40DE4354144351B425171CF810518863837A0E63F2533F446480C40E759
              54A9CC0C849189199905C6318E113D4B5816AE56052F0B5945E3EF5FA9347B0A
              041131741A3F53192E72AF8DB3BFEAC510DF8AFA006F04F6405A18E01A49D279
              11331048C3DDBA58120C29DF91C30A151797F655453010974201DD22B5B3AA05
              5CE4B47188FF9BFD75C91701FB082C628B78B265EC818C4401D7674B0AAE59AC
              E02F13484BD8703959699E9664182906A4BEED8DFC456C53A9905791881988FF
              E3AF33520879E03E9B851D8CA394C7C3C083A5A40946610062391B1AD8F18951
              3E4A73B11FA6CC9070042390FD5B89978293251DAAC4B5248BCB8D31F655BA0C
              B077C0D3DDAD0E743E1A03C078B77E8899883801F70B9FD85998CAE489E229B8
              2D956749B27FCBCD2F69612EE021924BFBAC410AD80A8B9858E90B0F5C216341
              21FBD80410F358D0353A6FCF0109135143D7EA95E015EE57C267A19B89692EA1
              2FBC208127846581585648FBE9767135310481C074BE358D1CA321CB8F6ED075
              3B3F1901ED0BFDDC224C2613DEED3C4D04AF94ED0574DEB9F030D4C293C38D33
              B119D873593E5609FD7F49B40C2C2F61FA53B449251627301FD087E4B5CD5BA4
              E3ED903500B530996CA704DE8D8817CC246E0C5766F8AA8A36B0417E7E3B55EE
              87D7DA4AE5AA684BE3726388A5DB577E3FCC9DDB4864985E5C06105FCBC73382
              1FBC563F5F0AB1B8484F606FD5C27A23E46190E8103CA914FDE2288C92A5E039
              4973504CC40BD8EC1A26906780618C051949F8825153C0165CC4D3C3EA11B7D1
              56493E1707B10837E773D84A3828C66858C4C69ECF55D600EC86F92EC2F27B53
              5CC2C28985543157F752C2CD8951BB731773BCA1E2EB84C150C6000FAB55D610
              22DEC0CA9B5702E1041F6142093C79CBFA083978991419B91738CA7CB3B69500
              F395883F841A800657F76FAEC5063B8ADF659C2CF19039C6A57DC8336206454A
              C13E922EEB6DA98A1675F060706F5C9B31C400783934686E448C49CC8680982E
              3BE0535DD17136D1953403A3809B26CE631672301248A3FD471C65BE59E8C64B
              26C4003E27E3581913F3B19C16E018C9DA5EBD1FCB4CA49323EC63AFC27F0997
              D387F01A5A2DCE0B79C987188025F4068656088E111BC28D34B0B7591ED42F4F
              E30FA23EC0D21F4F89F7BA8F5C96975148FB215BA9EC495C9EADB0DB758801A8
              F31EFDAC277401AF05826204C75CE5963C36B2393E6EE14D78582BE091ED9564
              94A0F34A964357222638425CE709BD21D40034749F7EB246E0C9A14E82622A0E
              866524898B2BE20D7836DF784B0D17E08C0FA38128E9F0D2F13984E14F1D7FE9
              9742597E129DDC692330FC78723A39EC576C8912BF61043D2B31B6174582607A
              4951CF2AA265814D1B8E4EBAEAC1D884E15D65A6BCB206A0118CC00D7B4F4008
              0BD91D43596C8986B8A4AA221788E272CE3F97C158C0B6275161FA9988B096C1
              8D4DAE83682F0C40C3635A2D88171E236E6EA817FBC3AA2A17F8D28576D873C8
              6532141015465F448C0958266B1983683E0B15E697565382AB87424EA8A6FADC
              5AD97563F72D97C158C09E4912B2378AE4B3F5DB0044115FCDEF4EE525EC3F13
              86606D5279639606FA650056AB3CF544112DFDAA92877B66A324F7B860958D67
              EBA633D9BC5E5FB391C16AB56CBDC4F2896412F6E6E41E8B2EDCC4047D5D5F8E
              0B7246A96CBF4AC9576D00E235215B79DC14931EAF8C44C1492C9FCDA20FC5C0
              CA57640858FCB9624D430C8E04A7F418992181454775FE59551B007FDE12B648
              F79C5309281DB7CF37D64EB495F047BA3E4B9AD03AA7D52CBC3DE5A9DA007496
              B005C7304817219F0DA1788EFB15F1752B2300483DF77663CC94735E93D1C0EB
              2D5354DD653F0C40EF3986C1710CD2597C5E19288CCF8694EC19ACAF9A42267D
              8EE60FDB3C575D9540BF0C40E7398EC1B10CD2092EA004711F914AE06DD58A71
              A14A9A816335C4F65DE77ACC955818FB6900FAC393C5F10C7C7114F32E997D40
              4682EF5C44FF7004985772BB58B6A0DF06A0BF1CCF60539C743F91B908A53247
              F8B44B58DD777FC25C7F0C03983B6760E454B6EF6B022FC9F7A9E6F435137436
              FC6EE862314B1D0DB0AA6E0965802CBE784D9006AD311AD60BAC1B90517566C0
              B3229C6216E8C6583703F09DD9A305377583CAACF30AC6E3FE896E4ACC0CCC27
              180E07C22C94C74807F2CA062D1FC5B371DEAD5FF389819D39111310DDE46B4E
              13738A09CFEAAED47550B22E06E01F28F1EAB1DE240AF5D90DE3243713B4EF6A
              18CF8AD1C0AE99B56F1D7C7531008BB58E8E1B2ED80D33B075B060E890B8109E
              55D0FE465D0CD0CFF83DAF3A46836FA4941DBE6E1BF81DD6E6A22E06A0AFFD46
              F6B939EBE3D36EE259590EA2B5EB6D0CD05643EE0F677D187DACDC73991C051C
              6931CD27F53480E38E2BCCE2641F2B77CB978FE96EB0F79DBE76A6EB62002294
              CE1B28C8ECE57FC4A2198E3FCE46C280B8B606B656C757922681484C0B06B4CB
              822940AC50840F444688838D26112770B8CCBCB8ABCB08E01DCCA7A7CE3B7664
              B2F7808CA3A82759FC3370D05599D7E7B175310037CAC7D77CD14EBA08D75421
              7B0F229502A380D1C0A8481A5A2A4958699D0CC03D110BE2A63987CA751AF986
              8C32F677D3F955A799173825C77F68E74373AFF6EA6680E4E638878AB2D3C8FF
              684BCAFB4D3927BA4248A3753540C8BD0EA44C6380C866690CD01820B2062237
              EF310222F7F43FDA7C6380C8866D0CD01820B2062237DF8C80C600913510B9F9
              6604340688AC81C8CD3723A03140640D446EBE19015D0C5075F1BF000000FFFF
              C2FC820700000006494441540300634D9ED08EA258500000000049454E44AE42
              6082}
          end>
      end
      item
        Name = 'wifi-offline'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000009B9494441547801EC9C75CC2DC515C02F955453B754D226F5A6699BBA
              A692B6A9A64D5D092EC182FC01840081207F00C182BB3B81A0C1DD3D5802040D
              EEEEFC7E97B71FFBEE7765675666F77BFB72CE3BB3B37364CED9D99D3933F77B
              D3A0FF97D4037D0092BA7F30E803D00720B10712ABEF47401F80C41E48ACBE1F
              017D00127B20B1FA7E04F40148EC81C4EA97CC1190D8E979F57D00F2DE4850EE
              0390C0E979957D00F2DE4850EE0390C0E979957D00F2DE48506E7300BE8F3FD6
              058F06EF015F0DC4BB692FAF3294C565FBA00D01F8286ED9127C1CCC3BF922AE
              B701FF027E1C0C854FC020AF32949597ADAE2DB8AF6E483A4811808FD0DD7DC0
              CC21F751DE007C0FD814A86B4394A93BB3636FAE3F0C360A4D05E0BBF4EA06D0
              CEDE0F5D166C1B2C87410F80DA783DF43B60ED506700DE89F5678176E812E897
              C1AEC05730F45250DBCF84DA1748F5504700FE83991AFE34F467E022E82CF939
              96DB17FBF46FCA954295013800CB34F260E8428543E8987DDC1F5A0954118013
              B144A3FE0F5D5260693A6A9F4F8096823201D813CD1AF13B681DF002428F07D7
              02BF0A2E1588F2C8AB0C65C15E39FC1E89FA600F6814C404207BC7AF10A5713C
              D3AD54AF0DFAB1CB1CFD36AEFF04EE083A2B8104813CF22A4359995C75A8EBB6
              2069D31BAFC86D03F12F68108404E0BD487E11ACE21DFF32725CA1664EF91CD7
              DB83CF8275833AD4F55914A95F1FAC47599B20A5E050B8F5D1FBA08540E5451A
              1E44A3C7C0B780B1E013B232CC765A39DB516E0368D7B618A24DDAA68DD65115
              05CA7914CE03C199302B001F4082C6FC171A0B47C068C7D415FDAE444653A08D
              DAAACDDA1EABF77F30EABBF74327828A26DD74A9FEF0A49B05EA97A18D9DF827
              B4ABA0EDF6A1CCCAFD113AAF2F21F3615200EEA5A9C92A4830FC140E8DAE6CAE
              8CBCD4B01F06D8A7D885A5BE34A38B98C56134006FE5B6C3E663D050F81B0C1A
              792E74A1C23974CC3EFE1D5A08728DCCE8EA5B7D3C579D0FC037A88D992F3BA3
              D02873EF88A8157C9F7E0F0DBE5F57879A45DD08BA26E86BE227D02652CC47A1
              C73E3BCDA51804FAF8EB19471600E7F457659505E943B4D308E7D4142B833723
              C9EF8723C927268FBE4F2FE6BE338C9DA0EE236C0EDD0134C52D4F3EC59CF1FA
              4ADD8A365507C7859E3ED02EC41786AB69B93C38FC7D80391C57B55E17453F4E
              55E6CE3745F14BA00E93EE4BD9A7195209F84A5D1F49F9E0D8E7775157057C10
              21A18BB0BDE0D9CF11E0E2817221789E5646BCCCF40C110365EC4A41878B9B50
              F6C98734068EFAA7D0A6FED3A0EF00CBC0E130DB2F7D44B1101C6E004EA6E91F
              C159E053F9F6598D66DCF743FD0A6DC455A06D815F62C833A0C1580D5A06F491
              B3A65932F4F9C906C08666F5CC99581E873FA0D21D234814B82F6BE78E84DBA7
              04D25AD819CB325B29468113821F4DE1D4D7FA7CF80DC8DA99351C37BD3291E5
              872F6B1742DD67B533E67D42F8DAD0D6D1AAED17461A239FA36194FDAF54E86B
              C860B10058E1F42AFB98989C5A8A4AA74D90205889D61A5F66D420A215E0E8B7
              2FBB4458E3F7401FEA4BD9FFC17FC7807390BD82E62A28F83131F7635289CB20
              3077E4FB7DF720AEF0C6CE945C595E09AB474E6E82BAD96F3DC55A6055A41A88
              98CD7A7DE976A6AF60C4BC01E302E05DB7DEA421E8CCC8DC91110FE19BD4F654
              6E381A5D7C29338FAE263FC9FD6F813F04DDF077AA697DBE9D1D77B673056DAA
              0237EB6F8E1076D8389E490118D776529D1B1C3E19E3BE1F9378C6D53F41A543
              3473E06FB876349A06A718006F3475E8FB1DFA365599DCDF52BE032C035F80D9
              3E7F095A0ACA06C0DCB92706628D7085EA824BE7B8E1336F88C60A9EC2770AF7
              3E03AAD3F34A4F528E851B618C795BC0F63A9409C07988D80D8C011DAD034C50
              9D1F23A0229ECB90E329396D71FAC96530F86E372D13CC28436C007C6A7EAC80
              40DC9AF676D6570DC556C11A58A36DDA4831084C45F84A923F88312600CE72DE
              1DA46530F083AA71662F03591B6FAE8DDA1A93DDD5374106C704C025745125CE
              83CDF1F8412DCAD396762EC49C45B9BF5BD426A7EF45DB0EDBC504C083587F18
              724FFF6F636EBB120C7E2AE06B0B388B726D63EA60964D3A3FF8831C13000D31
              081E4AB23C8A2E864C5F98A71FBD177BED2BCF0E3A9776D6E5FB761CBA0EF175
              E71EC58762958DE13375E06BC96F9FB71DD9CE804CD19C4D85B6053B1FBE79A9
              08EB8AE249341C3D15E78AD4C5504CFA027173E002EB0CAE3227DB718FC6B80F
              E1BA835B63C1A7F5D7DCF1C8CB83D08CFF76CA7F06CB42366372647B82DA3485
              8777A39CAF31B123405ED154B60B1BCBE64A5C915A8E41173577C1A8D32E87FE
              02AC0A3E8DA0634165FBEB1857CF5CA687B201B0072E6C7CF262F3E84EFF748C
              43DAF48232EB449FE20B50A04E0F64514C07550440EB1F1D0C244168CE5C27C4
              6C6C07299AD2781DEE6983FB15149B87AA021062F9D7686CA7DD44A7D80A70BF
              C2B44AE3C6341D003389D734DECBD90A3D70159242F7011A87B3358DB4682A00
              7E23343826973E6272E5971E2DF7C055E5828B086C2200E6F49D9F17B1675A1B
              135E1E9C75CE6D36D3E9AE7373D1A9E9E76176E6E493EC5A81CB99703A2D3C1E
              0249037507C0746FC8B197BC179EE34267EB60D17348BEA79D739BCF77C14793
              2178E6FF164AFE2AD3D3162EDCE4119D268F3B38E50AFD57F02485BA03E03BBF
              48DA22EF0453DC3ACE733A3A3B7F2FA6EC34D96CA53237CB0928FC238A1C4FE5
              C5BA03A0C1A62D8AE452B22CA47BAFF2D5811E003310DAE3EABA0E1D41329B08
              8006994BF13886E551BC960A9D12938787350AB4278AB16AA6A602A0DD1EC718
              DD8831FD307752D8464B1A3619007DEB56A45B78A6797DEA634E1728A73558D6
              90A603A0BDA694DDE8B0BCC4638A0054E9F42F22CC1F6443BA095D0C80F37A57
              D5A2FB0FD7E17ACBA2BF94E1B23BD0B500F8CB1237822679D85FCADC39E9661B
              EBBB14009D5F64C6F4291CEDAA18521B38811887C10ABB120077DA8A383F7380
              7F86E09BD9459B6957021093C2360DD266DF0F6DEB4A00CC7C0E0D0EF8CFF348
              01CDD334ED4A00D278A701AD7D001A70F23415DD0CC0B41E3577CFE9B06B0FD1
              334C519ABB128098B97D9D79264FDFB920CC9CEE4E9C75D97561DA950038AD2C
              DCA9450D9DBA2E2A564E3C7D372A745CDD689B79D75D0980DB8FA3A9EC799DC9
              55B80BE7AB2157D5CE625702A0F74C65FB8B76CBD3D06387EEC24D6B53F69E7F
              146454867FEE60B46EE67597026067FCD89902F087775EE7D1B3A9DEF367ABF9
              FA3ACAFE51AAE37282FD31E1827E05E5FA3A2CFAD3539D9DC7D8B3A9438111FF
              79DA3AD3EFD19B08118352C7D3A314F64C8B7BA06BAFA0C5AD5F00577D001207
              B10F40770290D8D205AABE1F018903DB07A00F40620F2456DF8F803E00893D90
              587D3F02FA0024F64062F5FD08E80390D80389D5F723604600EABEFD1A000000
              FFFFEE5D5E3C000000064944415403001CD389D04FF0F9F60000000049454E44
              AE426082}
          end>
      end
      item
        Name = 'esphome'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000003E2494441547801EC9CBBAA1441108647453131F002A29106268A0F60
              A6B90606A6C63E80910F60E203F800E6269A6BA499899A9868A418882088A878
              F90BCEC0C2E9DB74574D75EFFE87AA9DA5BBBAAAE6FFB697D959CE1E9CF8E7AA
              0001B8CA3F4D044000CE0A3897E70E200067059CCB73071080B302CEE5B90308
              C05901E7F2BBB9039C45DF2C4F009B6A383CEF11C03FE810720C2FB227880EE5
              B98EF16EAC4700DD88B3462304B086CA891A049010678D29025843E5440D0248
              88B3C61401ACA172A2C65A002EA087AB858EB0A095AE9FE34E06B34CD3658CCF
              31A9E315C41D869B9A258063E8FC075CAEC5DFE1F8ACD01116B4D2F5739C0818
              4A741F83734CEAF80271BFE0D2FF1D1C4DCC0AC02574FB0D7E14BE67431F1EA2
              FBB77075B302F046BD53FF8417D1C25DB8AA590078ACDA615FC91E68B76301E0
              A676939DE53BA3D98F0580587FCF3131927F41BF2193ABA8D078D5D89A00AEA1
              C391FC25FA0DD991D060EDD89A006A7BDCEA7504E08C970008C05901E7F2DC01
              C60072E90920A790F13C01180B9C4B4F0039858CE76B00A4EEA1CB9C71CBABA5
              97DBD0A162F24958CE33E6A135D1B11A00A97BE832172D36D8C48148BFB9EF13
              22CBC2C33500C299385AA540AF00CEE26CE42D40D391B23FEB15407F4A197544
              0046C296A6AD0190BBA75F5ABBF73879FB0BF5F81A83290D305D6E350072F7F4
              CBAB5B45EAE48D5D05DD43FA9406982EB71A00E5D91999556034001F7146F2CA
              4C3942C6B1D1008CA36C61A70450289455180158295B9897000A85B20A23002B
              650BF31240A15056610460A56C61DED1009CC679BDCF38A6552C762B4225F99C
              4411C09CD2F47808D9CF651CD32A261FF65412A592D400905746CA53F5B6612E
              F61FF8B3268BCEB106C0A2020C4E2B4000697DCC6709C05CE274815E017C46DB
              E7951DE91699BCA72F5A5013DC2B803F38990FCA8E748BACDBAB20692CE58BCE
              72C0E01BE859EDFC7BDD0138C7DD300270E64C008D005A971340AB828DEB09A0
              51C0D6E504D0AA60E37A026814B0753901B42AD8B89E001A056C5DBE2600B9B7
              3292C77E61F753ABE89BEB2D00FCDD2CB085CF5F699E9305805B9A0D7696EB37
              FA915D8C838E5900905FCCFAAAD35E77598E6B776401407A3C8187D80F1E61AA
              D17C96CBF713DFB54B5B01903E4FE1416EDDFEC471647B84E6E5F6B37C3F81A7
              BA6609403A7D8A07F9E94A398152C792A095AE9FE3A4762891BC28E69892E3ED
              5012AD316B005A7D6E6D1E0270464B0004E0AC807379EE00027056C0B93C7700
              01EC5320766DBE2F303310BBDE8F7D3EC8A4B3995EB0036C1AD8F5AC04E0FC0A
              2000027056C0B93C770001382BE05C9E3B80009C15702ECF1D4000CE0A3897E7
              0EC800B09EFE0F0000FFFFC10158780000000649444154030066ED08D0471FD8
              9E0000000049454E44AE426082}
          end>
      end
      item
        Name = 'project'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000BF5494441547801EC9D05CC2C370EC7DF31333333A3EE743A3E1D33B3
              8E4F073A28A9A832B34A2A838A2AAA5C55E5AA6AAB32333333D3FFB7FBF9BD7D
              F3CD244E667666E9C9597B13C7C9D8DF4C1CC7B3EFE90B66FF3AD5C0CC009DAA
              7FC18299016606E858031D0F3FBB036606E858031D0F3FBB036606E858031D0F
              3FCE77C0B3A5BB9B556E55798ECA58C2B81AE02C69FB619557ABBC52E521958B
              54C60EC6CD00FB4AC34FAA7C44A508EF2956547E1FA1867131C07AD2198AFFB1
              F044C1A81BE06FD2368A5F5A782261540DF065691BC56F2D3CD1306A067887B4
              FD84CAD12A5301A36280174BDBF7AA5CA6F23495A981AE0DC0F85749DB77ABBC
              50C503F77998C68507057435D7E335F0E32A6F51F1C063627AB3CA8B542606BA
              30C08ED21E0BECE785BDF009313E4BE55A958982360DB0BC3487E2FF20EC851F
              889135E10CE18984360CF00B690EC5AF29EC857F8B11C51F283CD1304C03F0D8
              40F17BF635E8FA5C575C287E0BE1A9806118E075D2DC232AA7A978613731A2F8
              6585A70A9A34C073A5B9DB546E5061C1148A029E108AFF6D947342199A32C0F9
              D2CF832AAF50F1C0A56262EC2F0A4F35A0843A0A38589D79CEBF5FD803B78BE9
              792AEF56A19FD07443AE013691DA50E077843DC0E1C96BC46887272267800652
              0DF02F7542F1FF15F600BCDC1DAC0FB7783A4C1B8FD700DF946250E6E6C25EF8
              9A18917FA1705BB0B2061A95F27BCD250A2828C4F45E35121E3E4CD80B7F1423
              9ECD51C26DC32A1A7054CACE9A0B7FB44147A3CA002F53E70754F8EB459922A3
              B0A238E0DD4978068B3470AC48828E6F139E07650638555C77A8E0AD084581F0
              308A4F093544854E0AC3DC75A0E72B44B347125A04342CFAD6A73E2DC41D805F
              2F320AC4F1B9D55688724E2F038F71EE80D7175550660078EED2C7F355580350
              AEC828AC210E785D8B8F78A705BEA00B7D860A074F428B4395018CEB6211F0E0
              058974812D3E5F7271E731B5BDD06E9F314D73464E08F545B9A1766B3B4204CF
              79C2C4225D708CB8B8F5D8F58A6C145695B436CA461A6749953FAB78812701BA
              7239235E03D8E0848911BEA9554430BCDC457854DE385144642BCDCFD4289CBE
              DD23EC3D02DD5DBC5CEF4AC26E48358009FE9F0806231624320A7854444A6F12
              A737522AD64EE04C8DFAA8CA1B553C70B298D0C56F849321D70036D0F74430F8
              05C21E201EC459C1B91EE696790ED57838111F15F600770877CA673DCC553C75
              0D60723F2082BF72A29D22A3F0417170B1293B6C75190A6C2BA9CCE55BC21EB8
              5F4C2F552143830D96C87C68CA00CC801471A29DF8BADCC2D4C50ADE1517DF45
              0AE26A9A1C63FF45D803F0BE4B8CEC7BC86312591F9A3480CDE64611BC3CF149
              612F58126E1B9B391B2B65B1FCAA2E045D91B927B239406873D2169774BABEB2
              3EFC52D80BB870FCA5FDCEDBA194AFBCF2BBAA4676CADD86B1B886A1E5AA0ED3
              00BADE1EECA54F2E22E5AF7B17F541594D6CE63E3E27EB20612F587606EB83B7
              4F165F1B06B089AD250243B83628E2056C33C7B397EF298545927446EE446FBF
              7DC4C81C5BCBCE68D300BAB61EB8B6E83DCEFE070AB944249BB9970BC7C032AD
              AF16233118A1286024C6F95994B361865403FC54E3F368B85318B753281B2C48
              85A23C42180F37B76A33874F7EBD04E1A1E0A9888C428EC35026143D126E4637
              DEE3DA9E1C3AF688C8C7FBD48EF0BD8501FC60FE22793391BF1CEA720AB1A2B7
              AAE34B54F0AF85A250B6993B47BD707D71814546019799D008FCF48B76083090
              DBC47E8070336C96B0E05ABF6206200EC2814BD54E9737135122C13A06CF2DC4
              5CF8AB7DA7046068A128D8660EFE0F45B9FB0CF09224C0DDC4A153BF36EFD31C
              85AA2C6FD62FD6A03784C4870CC022C6EDFC829080B9B6AF0B73712987F6EA32
              0F2E570D73E2405F64A3400A0DB23966AD23D836701E579935E83A0D86272634
              1F98D0FCDA7ECD3542B4B30911E9024B5B2184EBEA50C1C4813E8FB6BF57B4A7
              5413424716B19E947E455E0E9AF8234BD9C06124C6AE4CAF47C1C5818ADFD984
              202445191B480893FDA1701DD8469D197B7DE154D8581DE84B085D6436F088E1
              5A3868F20A213586B1778D75F018C064E428637F7566F21F16AE03CBA8331784
              3C9141E09D0278970872C51B5954595C5964E3DC7D0E8CC4D83CA6FA3591CF14
              03982853C67E56D1C7C1CFB3D54A7A22BFED20321B78539E0B445E51089E106D
              BC55536C4BF96EFB08DC4AAF7E387664EC94B77F7A73F20ED0632E7CFC44DF19
              941FCE1019050274FCBA09298AD0D10E010662F6FC420AB228D065BF1F111031
              AF8905933D098E071ED93C86928A2B55473FF63422D3A18E016CB48F8940A128
              5764145E250EEE86B2BF6235B981831DF604146877C712C6935487CB88E72732
              0ABCD38C8BFE7671E2860BE541130660643633AF1561CA151905D605D68703A2
              9CC363E0CD1CE6E03DD5624D606DE031C5FEA8F6CC9A32804D84735F32A1BD1B
              23FAF1CC46091BF2A5A5B2BAC661CC5F0B7BE1736224DC519ADFA3B62C68DA00
              3689F344B03E7C5FD80B782D28E51FDE0E197C040219833C566F77F3E5794C79
              FBB8F98665009B0031780CF17FAB70E02DC58392BE21DC14D8AFAFEC9020D0ED
              CB27C89CC73A6C03D88004A83044CAA6E87075668123DE24320BF8F5159EDB6C
              26BD02927D79AFE032BEB60C60635B5800E55A5D08633422AE445E49180EF10E
              B6115D6591E40CD77B8DD9BEFCE0C0A9B47772837251628A3206FB1A4D0A8829
              D7EA42D8A297A477E37757F1D246F08BE4624F101139B57D7984A8E08AAF2D9C
              04290660B3C1B379338D4028970BE582F5351B3867200B1B791E21BC048EBFCE
              3B0C45FE5354415B30FC2B1E83467CF93961ECC2D9DB7094898E7E35571F451E
              0370D1F8F9C715A471A15C7099320AACC1AFBC87C0E188C90B32CF357E4A980B
              DD43989F4280E6BD067D8D02EB4A53BE3C4E066317DD6EF244A9E7CC2238A190
              01C8E16477CB6D8FFF5B25685019553C9E7AC6614CE479F8E121E5851F0381F6
              147C79EEDABABE3CC9C928985497D0B8A460B27EB1712BE50B1980BF7A9ED5A5
              1D4B2A510693AAFBAA12BF31C1FA80BC9261B2AA9AF2E539EFE51AFF93308B9F
              8B97133FA1F9103200DC1C24A08C946C01FB5D20363DC8C82D39F944C5B19AF2
              E5494246F1B8D3C531AABE63247417CC208F19C0845BBECC7256E1C06C7A9874
              F0354D871CCB27E297B61CEC3D96A67C799EED5C03670C3DC18E0F1E4F281E67
              25CAEE3580095A4704C2B713F642F0354DAF10F1FD4985B18BCE80AA174253BE
              3CE716783578370B8547088CC4FC787722C2BAA839D500D6F3AF22188C937F91
              51601C0E38781612C68D76083090EEC1428AFF6E6CD0D4E12A5B5D0EE65C815F
              63C7F9C0AFF7C860A1451704153DFC8BF1A098C52A12BF7C45FC0C4E3683C828
              A07C8C80C2EA8C8D2B492C1E791468EAA2130830F0933BE40B91621F605BD864
              074184D51756A6127594303816F93C9C22B1B919ACAFA249C622469372DE5A26
              8B7003A5ACCD5B77881879CE932F24320A3C9A7844357110D4E87F6345661BFE
              AE29377A2562B08C83940556DD1A01729850FCB713A4B12873DEC1632AA15B35
              6B5377C0E0089CABB27143B983F5219AC36C94E14B610F498AB7D9B903394C71
              EE3E076E288F5ACE39FA350D7D0EC30036B513453069942BD205F68246939B30
              1BF847223072CAC99BCB9797DC6C18A6016C52E693A35CAB8B61623C28CB1BDF
              09C92369005929693449BE7C68F0585B1B06B03990D2C71D41A0CAEA62980827
              2111027531DE623B4902644BB09B2FB6557DCFF2E5AB8479EADB3480CD87179A
              3104CAB5BA10663D21F4ED7D27814592E40072FF09EE85645B5B2D5FDE84E4E0
              2E0C60F3FC8C0853AEC82878DE4920F3D9C2DB51816268C497979C6CE8D2004C
              9ABDC09B4470C246D8566414382366D335F84E02479C3CE7F9799DA8003134EA
              CB4B5E36746D009BB81D21A25C1469F5216CEF24C09F9241D1B82F1F9A64AC6D
              540C60F3E4653CE68472ADAE293C345FBECE04B9D83AFD87D5F7480966A1FEA7
              705D18BA2F5F6782A36A00BBA6AD44608894CD93BAF4A0355FBE375AE6478201
              324768A6DB521283213C89BCADFBF29A5B368C8B01EC0209276088B28392CE7C
              799B5C0E1E3703D835F232068727F8F114E85A717913DC361E5703A027C20CC4
              E429D0D48D5D1967038C9DB2CB263C334099565AAC9B19A04565970D35334099
              565AAC9B19A04565970D35334099565AAC9B1920A2EC61373F050000FFFFF353
              000700000006494441540300070416DF264881990000000049454E44AE426082}
          end>
      end
      item
        Name = 'npp'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000005C6494441547801EC5D49C81C45181D7745C505455CC01D0551410411
              5CD18320E24D054170457139E85105C5050FA2B8E3020A7AD28B887851544802
              21392424210921C9252424218110B22F24EFFD9949A6BBBA6ABAAABBFAABEEFA
              7EBE3755F5D5FEDEF4FCDD353DD5278FF44F9401154094FED148055001841910
              EEBE8F47C003E06C3570A4845548DF0FF4CAFA24C00D6096A4FF8390710405BB
              11A97F0196B91E612FAC2F027C0F36F9AE4750CBD6A0D4B740F2D60701BE068B
              CF01BEF6022A7C01246DA90B7021D87B0908B55750F17C20594B5D80750EE696
              21EFCE319623B4D97A5B460AFED405B0BD7B9F0779B7020BC7B805E18B40955D
              60381372A42C004F37ABA83A08E70F40D9F84F9779653FD3F7F12545341580EF
              3A9EF6C5004F37AB38FBA4CA39F67D3A0ECBC17F70C41823DBE4D188E6C3AC89
              0007D0E53740D776A5A3C3AB1C79B1B2BE43C3FB81200B1580E49F16D463F34A
              4F389A78CC911733EB74344E4E10F8598800AFA20B29F2D1F59CED987B2DBE54
              F98A25E2A6C8094F7BBD7A0911E073AF1EE2143E0FCDF2F3771F428271FA9014
              35EF0BBF1001446758EAFC0CA40904FDB43605380914E4044CB7B9B52940F3D1
              64D8820A202C7A870208CF34D1EE55006161540015409801E1EEF50850018419
              10EE5E8F800C05E0BA4DCAE854123D023AA5DBEC4C053039E9D4A30244A67B56
              F32AC02C8622E7AB0091099ED5BC8400A97F67308BB356F325046875027D6F4C
              05105650055001841910EE5E8F0015409801E1EEF50850012230D0A326F50810
              164B05C8508094BF8CE1D83A95448F804EE9363B53014C4E3AF5A8009DD26D76
              A6021CE3643782A7002E9523A8652C4BBC8ED2878120CB5D80B7C11A493C07E1
              CF4088F19799A7A222DB5980D0CB2404E04053C1FB5E6CCD2E7CD7EC22C51212
              0214479079AA450132673270FA2A40357197C1FD06F03FC04D41D6225C0CFC02
              3C02B4662AC0092A5F439457C2C446C43F06EE056E06AE056E079E04FE005886
              5881F8A540B0A900A31137FE20999F05B07813EA6C020E015700DE96B300DC77
              8EC43FEBCD9A59E114B836004B012FCB55007EBCF8EC41579754EE614451795D
              50AB4E8E0270EB1AFE83AD45506021EE5B74499DBAB909F03748F1DDBC896742
              13A07A6DDB8C92E7024ECB4980B7C0C48380AF7133D8097CEBEE9C554142007E
              46C6826DBE1723E33D40C276B93A9510C0359E26795F392A6F75E435CAAA51F9
              6C94E1D66E084C1B9200B6CD92AC9337E988E6B16EED361401F8916663CF3A79
              5B8548FECA95D7A108C075FD2ADEB88C50E597F0BD59D5E95004F8A86A72F0FD
              0EA464DC8AB9301E0901627C1963FB4AF09AC26CE513EF9487202140790C39A5
              5F2E4F76C8025C5D9E6C0269836FC391C020DB1A027756B7B535595AA8134EB7
              51A7FCA4CC743D6B7CC802B816C3264B0B75C269F2EA949F9499AE678D0F5980
              5EEC27DA4F01ACEFA742C696422AD1C49005707D3BC52BE7BA9896AE6E1D969B
              AE678D0F598025D659279431640112A2F9F8507E3B1E1B47DA1480879D14C6D3
              3182BD8647D631D82BE1CB2DBC4A3DD0C1329CD1CA7246C811F04CB99104D2BC
              B7A76A187F5639857CBCA1CBE83A44801FD14AF033535037863DE468F44B475E
              97598F5675162200DB39132FBCF5024132769D65247CE48A25AB33F74FB69E42
              05607B7C700DBFEEB32D05B34C97703D4DEFEE2E0752D1D7D315BE39571301D8
              001F9EC6BBC062ACF1FBB679160764C17CF8FF0224CC352E9F479A4B8CBDD53E
              1F466BDB802E8D2BB27CC890B5CFA64780B5E14433787F107F90E733BCE96B1B
              9F7A8FA3F042C069B9094032F8833CDEFFCF782CDC81867F05665A8E029014DE
              CBFF01232D83470B4F4E16D56D375701C80FEF15E5D3EFF630D10278DB09F9F4
              3A3D678516FAEE6D13FC650B6F1DBC0833580F84D8BBA8C433B60F117A5BEE02
              4C08DB8E087F0746226F439C4B1BFCE911A286CD8387D73F93D36F63810DF9B5
              4D0530A9E2F7087C463017F8284819F7A00AAF7F5AB9005501C0A6A4A90092EC
              A36F150024B82C76DE51000000FFFFAD9CC91E00000006494441540300827468
              D0893DE6290000000049454E44AE426082}
          end>
      end
      item
        Name = 'console'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000003E6494441547801EC9C4B8AD5401486E363E0CCF74897A03BD0898EC4
              070A2AAE40DC858F5D880B101105411DA923DD812E4127BED09920DAFF1F0884
              74DD54554E724E87FE9B735249EA3CAAFEEFDE6E1A72EFDE463FA10A0840A8FC
              4D23000210AC40707BBD0304205881E0F67A070840B002C1EDF50E1080600582
              DBEFCE7740B0E8FDF602D05723E05C000244EFB71480BE1A01E70210207ABFA5
              00F4D50838AF05700B6BFC0BFF2F6F521A509B9BD0A6D86A00FC40D5C7F07D70
              595A016AF30453DFE045560A80050F1755541015388AC35778D64A005C431516
              C420AB50E01862AFC047AD04C0D3D10A9A1C53E0D9D824E74A00F0F71A638DBE
              2BD3F7E7765D0260538D3D9890374DA74133E5C702604A3FE50C1410808120DE
              9702E0ADF8A09F000C04F1BE14006FC507FD04602088F7A500782B3EE8270003
              41BC2F056061C573E50520A7D0C2F302B0B0C0B9F202905368E179015858E05C
              7901C829B4F0BC002C2C70AEBC00E4145A785E00161638575E00720A2D3CEF05
              E02DF6D13DC8F412E7A5B696BCD2FD6C8BF300F0065DCFC13BBB8893D7F09C4D
              CF6B1ACF7EB97D8CCE7B00389F58C185C4BDE1ADB5E40DD75D75ED01A06A41BB
              2DD803C0BB84A8A97BC3B0544CEA5E74DEB07FD5B50700FE2AE93F5DF7022BE4
              3D0CA3C69835E48D6E2237E901806BE023DBDD034C5779A3D0D79257B89DED61
              5E00B677D69D5601016865883B08409CF66D67016865883B08409CF66DE71901
              B4F574A85440002A059B3B5C00E656B4B29E00540A3677B800CCAD68653D01A8
              146CEE7001985BD1CA7A025029D8DCE10230B7A295F504A052B0B9C305C0A8A8
              355D00AC0A1AF305C028A035DD02A07BD04A63D37E7BD624162500FE4DAAAC24
              2AC01727C78D5E02E0C6C66C4DE414B89E0B2801F01C457EC265750A7C4738B5
              C3B0D94A0030FB080E2C884156A000BF638F5F59960D2D05C0422C7819277FE0
              B2B402D4E612A68EC38BAC06000BF2D1F20338E91EB22A1911BE6A2BD9631743
              6D5ED5ECB616404D6DC51628B04E00051B5B4B88000493F2007036788F96F667
              2CC925B91E00DE6321FC237507E35AEC3616CA357FC0B8A87900E836F01027DC
              14FD20CEEFC33FC3A38D6BB88745704D5C1BFD11AE5DCC13407F43BF71C14D9F
              C4C80D777E02D7FC5FE32E467E90E31346C6629864BF90F511CE5AACC9DAECD1
              F5E3C835F0C560E98316D32C0AC0A6D57EC104FFD77880911FE43885B1FFCAA4
              60357E08F9A7E1ACC59AACCD1EB8B5336CA701D819AA38AE42001CC54EB51280
              942A8EF704C051EC54AB0A00A974DDB32A200056058DF9026014D09A2E005605
              8DF9026014D09A2E0056058DF9026014D09A2E0056058DF9026014D09A2E0056
              058DF902901170E9E92D000000FFFF30B0559300000006494441540300FF8EDE
              C1701441A20000000049454E44AE426082}
          end>
      end>
    Left = 344
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
    Left = 32
    Top = 31
  end
  object ImageCollectionWhite: TImageCollection
    Images = <
      item
        Name = 'Run'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000004EC494441547801EC9BBF76D33014C61BBAC066B70B63B3319691AD1B
              B031C21314364636CA13C0061B23E5096063840D36C67464E869D2892E49F874
              4EEE419125C7892D5DE94A3DD6912DDBFAF3FDACEBAB1BF7D65EF96355A00060
              957F6FAF0028009815606EBECC8002805901E6E6CB0C28009815606E3EF80C98
              4EA7CB69C429348FE000420F709BF646A3D1F936D70F716D9E001CCA2D97CB17
              8E53DE8A0B004DDABAAE67DA6190DD02E0BFCCC1C5574D17004A0524D8FFE7C8
              826FD100C0F41F85482E85ABAAFAEC3AE7B33C1A003E0749755F5E5EDEA3FD58
              F2AC00ECEFEFBFB7090FF313DCFDA47E640500833E416A6C1CEE277522370034
              EEB51CEF1E160F4875221B00087FBC5603B62436F1555FB20180C19E213536D8
              7F16F7933A121000351957CEE57E920A590080F939A601C796670100A27F446A
              6C303F6CEE2775261700D619C0E97E6603603299DCA6C19A39A7FB497D113F03
              207294EE67360060665ED160F51CF69FD5FDA4BE889F01345033E7763FA93FA2
              015C5F5F3FA481C69A8B06309FCFDFD98487F961773FA95FA20140686BFC1FEF
              85603FBE93D0AE5C2C80D8DD4F02221600DCCFB7344823678D7E1A7D91FBFF01
              303356371366C95A6E0A13EA58EC0C7009188BFB49FD1309003FBE3FA1019A39
              22A33B7F9B3A9BCDBE9BF5F53D1609003FBEBBEC7F2FBD307B1EF4AAC072B348
              0018E711D2D0DB78E80A557DE200B4B99F6AC0BB24BCB8CFE1555DEC72EFA67B
              C4018050D61F5F3609D1761EA6E759DBF93EE7C40180FBF9B48F20E6BD78F1DE
              31CB863C160700336054D775E7EF4C01EC4F8BA067E3F1F8A6E57CEF53E2006C
              A3089EEE53D8F7BBB67B00E6A6AEEB37B6734396650D00227F7089797070E0D5
              F450BBD902500B3212C1CC178BC563B3CCD7719600207EDB42EDE2F0F0F0AB2F
              C1CD7AB303B05A27BC3485A063D87D2F0B2EAADFCCB3035055D55F5304EDF8BE
              B61F64372B00F07ABEB8548537F4034FFF2FD7795FE5D100805DDE2A4AB9AD20
              A8FF085ECF23D77D98198307DA5C6DE9E5D100D03BE5697FD2526F50BBAFF723
              0B00303DBFF541EBFB303DDE026D7A3BAEFD0101B89AE02D87E93981E9B17E1D
              A17A06D3E32DD0A6EADF94C4038000DF90AC1B664690D5AEB5F155A1680078FA
              A7AB71DA32EF81365BA36659700070F53A472AD5B56687BB1EE3E93EC5B51552
              6383490A12686B346C29080EC0D287C18BD46A1722B307DABA0C4C2400BC589D
              ABDD9081B62C01C0EE471368CB0E00C457363F9A405B760030E036AF2778A00D
              FDD9B8897907C0EB892ED0B6517D5C2002004CCF31BC1E96401B34ECB5890000
              057E22B936B6409BAB437A79F200F0F43BA39CDC81365D68D77ED200AEAEAED4
              4758CEEF40B11E600DB4B944D7CB93068027FC933E187D1F2F65F6409BDE1FD7
              7EB200607ADA5CCE28026D2ED1F5F2640160106AD1856C7D8337144DA06DBD67
              F6A39401584714EA8B366BE33B148A02105BA0AD0B0F4900827ED1D645DC2ED7
              8801801F6FA25E70B960A409A0399A28036DCD6E364B920780B500CB176D4D29
              772B491E0056BB2C5FB4ED2677F3AED4012469F7750CC90280E961FDA24D17B1
              CF7EB200607AA20FB4750193248054026D5201241368130720B5409B3800A905
              DA44014831D03630802ED579BB26C9405B173592F082520DB44901906CA04D04
              003CFDC1FF75B48B70435D9384091A6AB031D65300305329000A006605989B2F
              33A000605680B9F932033600F07DFA1F000000FFFF4EA60E4100000006494441
              540300B4A8FAD09B9965980000000049454E44AE426082}
          end>
      end
      item
        Name = 'Compile'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              380000076C494441547801EC5D3B6C1C4518BEB309C16061DF59918D91030E96
              90008150143A20020C4A04158F129148A92822A043400244A20B54140870910A
              2B543C8394F06840102123E820B1820505C27767631BC7808FEF8FF6CEB3B3F3
              DABB9D9D8DFD4733D999FF9FF91FDF3733BB77176D7A4AFC2728024C4050F84B
              25268009088C4060F7BC039880C0080476CF3B8009088C4060F7BC039880C008
              0476BF35774060D045F74C808846807630026AB5DAA97ABDDEAC17A0361A8D8F
              03607FC965100290F0A972B9FCE0A5080AF057B3D9DC87988290108400245C18
              F05BFC23A67DAD769ED72004E49960D17D8522E0AB02027326444C4108A8542A
              F722D9F7518B524E22A6FB43041384004A14093F865A5655D2ABAA6AAC4AA69A
              4B32D5D848F638E943D460048448B6883E9980C0ACE44840E04C0BEA9E09084C
              0C13C004044620B07BDE014C40600402BBE71DC004044620B07BDE014C406004
              02BBE71DE099009B7926C08690673D13E019609B7926C08690673D13E019609B
              7926C08690673D13E019609B7926C08690673D13E019609B7926C08690673D13
              E019609BF9CD49802DEB02E99980C06430014C401C81E5E5E5EBE292EC7A3E6D
              771A65A17640B3D9DCB6B6B6F67BA7C9D8E6916DF2611B97A7BE5004341A8D35
              43F24D834E5669C75A7CC876BCF70B4340BD5EFFD7946DA552718ED536D6E6CB
              1447D63AE7A4B2762CDAC3AAFC13FD5E5465595A5ABA5AA930082D737A239F06
              0BF9A8821380D57816E7F2902E5D9CDB136363637FEBF43A39CD2997CB133A3D
              F984EF6F75FABCE441090000EF22D1DDA8CA02901E191E1E3EA7543A08070707
              CF910DC3D03D88E11D83DEBB2A180148FC20B23B80AA2C58BDAF55ABD50F95CA
              1442B241B60C530E2296A70C7AAFAA0C09708F736161610F469B56DE69ACDEE7
              31269312D93A6D3036857B8276271AE675ADCA9D00805F5D5F5F379DBDBFE229
              E681AE33930C904D1C477392B8DD85EE2CC5D616E4D4C89580E9E9E95E803F6F
              C86D0D40DD60D077A5C271B41306B49F35283610912B26B93A9B9C9CB43DEB6F
              0740B182F3F9483735660C1D109CF00171BBE028FAAFDDC9A1911B010051BBF2
              284F9CD389CF01984347D551E83BAE910D98D8282A5F1BDA5209732E8A7D9FED
              5C084042BF21896DA8CAD2D3D333842795755189396FA04F376B5CBA2AF4A849
              B6DA46C817F96C0B928D2BE19F624E6A329678270089D06B094675710388BB06
              06066AA2BE56AB3D8CFE61D4ACCAE1C866DB1EF924DF6D41B2318AD8BF4C8AB3
              9578250009D0CABB5B17326E7A8700C477A21E40EDC40AFD409465D1269B645B
              B445BE29065126B5EF410EC72559A65D6F04CCCFCF3F81484DABF8C4D0D0D0DB
              18D32E7802B902405D680B326E906DF2219A8D623821CAA4F633B8313F2AC932
              EB7A2100E0DF8AEDFD9E21CA193C8D3C29EB91E83FB22CEBBECA4714CB8CCE17
              483B4939E9F4DDC8332700815E0BF07F3204D540C277CA7A6CF55559E6ABAFF2
              15C5D4D0F9A49C4044BFACEFB69F290108B08C40170C4135916845D66355FE0C
              99F1F91CFA2CCB7690403E6336A3D84C3FE6FC4539C62675D9C9940000197B94
              94634382097F00621A4969BF36966D64D89F20DFB23D558CE2185B8EE2589776
              02109749AA3178C25851C95B3204DED76AB7AE38AE0EA11DEC5D3DE43B8A01CD
              8DA28A75435B2AD97215C7DADA99108095741E4F1809805BCEA1DB353E3E1E3B
              E331E70E1C576FB5C684BA520C148BE89F62A5984599D886AE0F737E11659DB6
              BB2600AB815EF738AE0B00C7CB7E7CF49F15F5905D83BEF6A903BABCCB4C1453
              DB2FC50CD9FEB620D9B8093BE5A3A4389DA42B02B00A8E6235985EF7780CDF40
              7E228784C0976459E8BE2AA628F663BAD8882060F0824EEF22EF9800AC7C02FE
              88CE0982FB0C37B417653D02CEF5DB46D9BFA9AF8A8D72A05C0CF35EC57DE421
              83DEA8EA8800AC965D58F974F4E88C5FC0EA49048504FFC0848E7C625E1EA527
              8A31E62BCA45FB091DF7914F8189F6188E19933AA9C1989B9BEBC38AD0FE500E
              622E62D5DC28F9A1AF78BF806C076AD1CB0E90F0B91C24E544B9C9F2561F989C
              9F9D9DBDAAD577BDA626A0BFBFDFF8B8899B57220824F40A02A27785E2725994
              BD88F9653952556EE218E853FFF399540420A81F4587721B0124EC616BDE8771
              897B01649D977C66BE847CF7CAAE54398A6330E707B16F6B2700B34CB84DA7C7
              F6ACA2263EC623E033D8BECA17B45E06723A366329538EA8D59830DEB93DDE35
              F79C09C09DFE169D2904B41B40D775FACD26A75C29675D5E8B8B8B37EB74B2DC
              9980DEDE5EDDAF5A0710D0F7B2E1CDDE8F7256FEC332FCC873BD6BFECE04ACAE
              AE7EAD313A8573AF10FF1346DE71008F29D444595959F92621D4089C09181919
              59D6D860B184C0E8E8A8F149511CEE4C004DC2B9F7265DB9EA11488B512A0270
              EE3DAD77CD1A42202D46A908881CA49E43F3B64205F8A9B1493D015B8C7E56A4
              9F1E5FDF0AA0BAE488EF828ED3671AC2C665BC38263501ADC9030303CF9253AE
              9532B078AE854BDA6B0A02D29AE6F12E0830012E28791CC3047804D7C53413E0
              8292C7314C8047705D4C33012E28791CC3047804D7C53413E08292C7314C8047
              705D4C33012E28791CC30458C0F5ADFE1F0000FFFF8650D8A900000006494441
              5403001B1DEBEEDFBC6E8B0000000049454E44AE426082}
          end>
      end
      item
        Name = 'Upload'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000BC8494441547801EC9D7B6C1C471DC77D7E0527B1635F6C4CE2A4C84D
              5D94121E22413C0B05F128955A0888B6108104546D0A122A827F0AAA1AA48290
              40ED5F505A5409A4424B81425A6855A02AAD0802E42081426931504AB0696D9F
              CF8E719A387EF4F33BEFDA777B333BB3EF3BFBACF9DDECFC66E6F7FACECEECCD
              EEAD9B9B1A7F9946A00140A6E16F6A6A00D00020E30864ACBE71063400C83802
              19AB6F9C010D00328E40C6EA6BFA0C989E9E1E2C168BB7427F8796A15153BC68
              F300246D47A6A6A6BEC271B7A94F96F53505C0ECECEC5E02F62824015CE6EF5F
              04E773D0106495E893731A5E90CBE5BEC831E28A22EF6CA150B881724DA5CC01
              3871E2447BB1587CAC582C2E2F2C2C3C4974DE092591DA9B9B9B6F133D457471
              765C978492A0323303606262E24282303730307016A32F81524D9C1DDF76C078
              2055C51E65A90340E077E0F8626B6BEBD30461B3C79E2C8A97638F4C517FCE42
              79AA00E0E8BF09FC188EA6AA177D36E9D5D8B7CCC27F8F4DE3B8DAA412081C3B
              082D63F4CBA1A0E93867CA953D3D3DB99E9E9E0153E77C3E7F39ED6421FE00FD
              7E6F6AEFAD6711BF5A6C65C17EB3B72E8972E200E08C5CC9DC1FC0F8250277AD
              04D1A103DDDDDD3F0AD0BFD494BE47E9F72672012EB7B4B4744BA9C2F28305FB
              18B6FFD3B279E8668901C048DA840332EA076DAC23E80F13B01602D642FE1D9B
              3E41DA6CDFBEFD2664E75A5A5A7AB14DA6419BEEE78B0F4C4B7B6C1A87699308
              003333331760F4191B8308FC3D1218827E19C74B367DA2B4E9EAEA2A304D0DA0
              AF05397F817C1360FD8DB6899D09B103C088B984D37DC4D72B2A716CCC09FC47
              29A69E046CF4BF6674747413CA8B902A3D035817A92AE2E2C50A80B3703D6632
              6E7171712F8E191754939C38EAF7EDDB370F10796C7AA347DEF3F0CFF7F0622F
              C6060053CE7E59B80C1616702AD7DBDBFB94A15DEAD5D8F407B10DC57F848A1C
              BF8C3CF1140B004C3BDD4C29C3FED6367D17A77A0D6D32AFC6C63740F9B40C89
              05008CD5CDA154353531DF5E83539F686AFC55452032008CFEF92AA9650CBEF9
              BEBDBBBBFBAE32D6BA383C79F26407BECB6576247F2201C0BCFF0BB4B741BA74
              B0B3B3F3095D65BDF2D9CFBA70EBD6ADA7C57E4018973C2C8506809DCCF398F7
              2FD32966DA39CCB4F3335D7DBDF209F841CEEAA7CBECEF83F7F1B272A0C3D000
              10E0677D34FD9669E70E9FFABAAC22D0B761B86A5BE57BF043A5500060C8DD3E
              DA5E60E45FEC535FCF551FD4194F4C8675757EFC500020F010A44C043FB53D7E
              9C3E22A434240126BEF9EDE6EE1F1E1EF65B0F9516050680B95F6E1B2A85B105
              71B5B22201A613F89B117DB373CC61F2896FCC7B755AF6ECD9F38CAE4EC70F04
              008B6E3373BFCE8029761C7FA8531427DF09B804DF159B1A087C63966FF17F75
              157BF20162D4EAE1F9160301C065E7A33A692CBA3B747571F215C177C5A70602
              53D13E57A93727468F97F34CC781004098EEE6F99F38337CBF90D13772F209BE
              2B3B351050A8BB4914E84E9A3500EC747E01A5CAC488D8AFAC889169117C575B
              2A20E0F395AE426FCE59F0292F4F57B606809DCEAF6B84D8DE5DD27437B30304
              DF15960A0828535E90B00E58DFD1B3060065CA343F3FFF3A65454CCC10C17735
              270EC2DCDCDCDB5C659E5C1E0AF0B0D4452B00B8F4BC5EDDBDA9A9BFBFFF795D
              5D547E84E0BBAA130561D7AE5D05579137C7F64F7A79AAB215004C3F47549D59
              787FACE2C7C1C301D1597EA919566CA22060D44F2155FA868AE9E55901C09CF6
              526F4729F3A5C47AB191F6B61463F05D958981D0DEDEFE19578927EFF1949545
              2B00943D61F2C5EB1459AC2981E0BBF62502C2962D5BFEE72A08931B01989C9C
              4CEA69E52A7B6D828F3D2FA9EAE830FCEA9C268980E0C8AECAF0E78A2AA68761
              0480F9FF5D9E3EA522D392DF8E68A94D900F8C35CEF912E0A1A121799A5A295A
              EAA48DB2728D990408DF5F13BF76448C3EB256521F1901A0DB3BA0AA0430B13D
              D61D47F05D034B204C4E6ACF12A75DDC20FCC4915B917191F2DE0A86A2600400
              21DEE7654A624E9F3E6D7CFEA7D4D0F01167F05D556983C03ED8CF5DDD9EDCB8
              101B01F0085C2DEEDCB97372B510F22089E0BBA6A4090283F41C5B13A58780BD
              B96B8F2E0F0D804EA02D3FC9E0BB36A40982AB33689E090036C1976736258041
              1DF2B61719192DCC5E5394E5D401B00DBE3CB3A9B43804B39641481D00E2278F
              8593A9938CFC3883EF6A111044B65BD6E4BEB669FA4462A70E008BD44D58ACFC
              B58A042889E0A3AF9444B6E82815AA3F6E716CABAE4990933A00E28B38CA95C3
              D7E4D825098C04C82D27958B0ED1E5919F49F0C5864C0010C55C3BDFE8822001
              91C0083F0D125DA25374890D3220E4380BB201605665D8F4F474E4DF4D090850
              9B0444A523499EE814DDD08D51F57061D10DC96F8DABC824DB06805F6A847836
              E934AD0C6C46E082A14962D571E946CE873446EA1E5F596D6E04606969490980
              CD46D3AA96757E402C944F0A02CC5193EB460010F010A44ACA4D3A55C30DC053
              C6829B35B79B7C3702C04D97FF9A8434EAD511D8BC79B331764600D4A257B8B3
              B3B3AF5C39DAB89F535353919E04B7054039972D2C2CC47A53A61E61649EFFA6
              C66EDD937315CDAD006091F96C45AFB5C26BD70E37ECD1AB549EB7B4B47C5AC5
              F7F2AC00C8E7F3FFF17674CBEC34BEDE3DDE6839D3CF5B743E77757559DD2FB1
              02C051F23B27AFC85A5B5B8F5530365081DBB2CAA7C599961EB10D833500CCF7
              1F5609657A6A83E47D0BAAEA75CB1B1919D9A4F37BDBB66DC6A721DCC05803D0
              D7D7A77D08976D09E3EB245D85EB25EFEDED2DBD9044E1CF326780F5A3FAD600
              8822045F25B982B6B317E2F7FB294597FA65150A852EACDF0DA952A02D9A4000
              B071759F4AA3C30BFCFB28A75FDD65CCFDDA05969DD5DF04712810002298794F
              F72C648EA9E85BD2663D133E5E8B7FBA5F43BE9FBA402930005C926A830C38D7
              8F8F8F6F0D64411D35C6BF6648F703F465467FE087D5020320F16287547BFDDB
              D6D6A6BC7F20FDE2221C0DF50C4E54FD333333DAC595F531D4FD915000B04127
              DF09A6740E719A3EA7ABAB673EA35FB7EF7F9CF531D41A180A000922A370BBE4
              2AC2D07EAE8AD6DD3E113E1FE5EC7F8FD767F807BC3CDB7268001C05DA772750
              7F0810E4E5161CAE9FC4D9FF2BF679DEEA7AB4B8B8A8FBE1BADBC4378F0400C8
              CBCF738EFB68B881FD127985BC4F93FAAB629FE7183B03B20776375FC8E497F3
              A19D880480680584032C40E7E45845D4C93F5150BDE245D5BC6E78EC0C0CE3FB
              C7A21A1C1900318005A85D721F9277471B6F50FBF4AFAC5A47A5580090780042
              87E43E74116BC2120BB4092C1F11C95731658E62E744F29A5634C4060053CD19
              40307D09936FCB67B94CAD89FF5EB11282954F6EAFCA00918DB49D707AD30221
              3600305A5E4F390710C6776E7216C87FAF581C1B1BAB89F78832209E6451F54E
              91028276CF47FC8D836205400CE22C284222D7F44AC7E68E8E8E0946DA73596D
              5F10F87BD1CF7858D65D4ACA2EAFF60BA7F81B952450516554F5E72C907D1191
              ADFD297F59A77ED9BE2010FF8774EF5E286B1EED90A9A68F79FE297449E075DB
              EBE54ABAE51DA1E58C388F254871CAAB90C5659A4C319FAF60EA0B5BA87A5C02
              C3C87C98209D473996C41E4E1E79A5D1CE5433CE0079858D60DA3D820FCDBB77
              EF7EC1A67D983689022006E1C0AD0454AE904C5392342F1143F3529C7F56C080
              16E97F2F017C5FA9D2E2E3D4A95317D3FE76FA9DA3FF32DB0705E4D98CF655E9
              DCEBEE672ABD749591D041E20088DD838383670042DE3717E6EA47B680AF2280
              0F114CE3762F817F90ED8127687F182003BDBF4D6CA5DF57B135D7D9D919E98D
              B822CB865201C035841175A73847F9D750ADA5FBC5366CFC529A86A50A80EB18
              8EBE1BCA3142EF747959E56283D802E9B69A13352D0000F1DBC1DDB5EB705CFE
              C3914C3156FF7326262BCE11F82B44B7D81093CC50623205C0B5982DDEFB38F5
              3B2420B95CEE3094C40D9D22413F243AA07602FFA0AB3FCBBC2600280F0040DC
              01ED2048A5DB8E8021DBBE5FA68DDFB637D515E91F94EEA26F69AA736411F3FC
              0FE0D754AA3900BCD1010CD9F63D42100F40C627CE88B2FC27BD21DA5E43DF5A
              5CEC2B5CAC79002AAC5D878506001983DA00A00140C611C8587DE30C68009071
              043256DF38030C00245DFD22000000FFFFABF7822200000006494441540300CA
              DA5BFDB5CFDFD40000000049454E44AE426082}
          end>
      end
      item
        Name = 'ShowLogs'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000005C2494441547801EC9C5B8B144714C7677AF2B0E46577D6C99297CDFD
              0B8490484840481E12C805422E845C08819090C7E431110451DFF4511441C40B
              225E9E145114441444C54FE0831704D199EDDD6577655CD7F17F96E9B1B7BB6A
              AAAA676AAAAA3D52C7EA3EE75455CFFFD7D53D5DD36C54E17F4E1560004EE5AF
              5418000370AC80E3E179063000C70A381E9E67000370AC80E3E179063000C70A
              381EFEC59C018E454F0FCF00D26A38D83602303333F3631CC74F601DB658A4C1
              9356ABF58309476D00711CCF54ABD5C3E8BC06E32256A01645D191388E9BE270
              DEAB05A0DB613DDF9C3D1205D6CDCECE3E94C4D6B8950020FE3768B10EC6C540
              814EA7D380765FAB9A2801A083A3302E0514C025FBB8AA990E00BEE6AB5494C4
              310B5E92847A6E1D00BDE4F446BD5EAFD6D97A1AA4B531D92E0CC06410CE952B
              C000E4DA8C2432420023F93CC10DC2001C2363000CC0B1028E872FED0CC0C2E1
              5F78125D5D30C3B2C0DF8E75960E5F4A0010FF009E4277259F1A0F443B01635F
              B2EF535D3A00103B82F8BF0844FE4DE073EE2A1D009CE9F764AA22764C1673E5
              2F1580A5A5A5D770F6BFDA47CC6FFBC49C844A05A0DD6EDF52A98859B05F9533
              CA786900E0C6FB1384ABC254E55755C230E3AABE4A0300979E43AA0F9BC4016B
              77B2EDBA2E05005C56F69A0809587F9AE4DBCC2D050008F43B4C541E8B9CE403
              B4ED54BBB6E00140C89B3211979797E9B7ECBB92F8BF12FF48DD4103989F9F6F
              40ADB761A272636A6A6A616262E21D51907CB8176CA5DAA5454507C799B7BACE
              32A4FA4291E3585959B92F6B879F4BDFA318AEF78FF1742CCC43ECBF211D7F87
              C62A6285011419AC4F9B0D10E2529F782ED46AB53E8753F8C200845D73662F2E
              2EBE855C2F8B2F00489C8FE83F5D8BA2E8B42C17979D8DE9D8F4F4F423407990
              F6F9B2ED13800A66C1391D6190B7439687CBCDC7A2D8F8F8F89B22BF6B9F5700
              20C6A7309DF28F2809E23F9A9C9CBC2C8A61062CC17F07E655F10D4005DF4C4E
              F6530867FF0D591C375EFA5654A94812107F1DA1DB306F4A6100F830BD97928A
              6C4301A1903853BF404C587086BF8CC0BB3051B98AB674968B623D1F8EF50DD8
              40C72E6ADF1BC070A33000C37172E9F810AB5F1373013870960BD7EDE7E6E65A
              080B0BFA5B2F0C78EE7406A0ABCBF56E9DAD72EBF6CD66733D66C0583691F6F1
              8D6813D5219A5300386BDF9789865970301DABD56A57D2FBE96D7CC3D99CDE0F
              69DB2900120AD7ED6B540BECE7C4871BF3FFC976B6C6D37090979EE473380780
              87A60F9283C9D698057BC807485BA816D862A3D1B82AF007E3720EA0AB946C16
              FC0108E7BB39B96A6161E1959C3330871700702F90CE02E8F9094C542ED31283
              281092CF0B0024182E3346971240132E39505F21993700702FD0BE99E2EBA8F4
              A61C92F874AC430440DD0D66BAB300EB3DDB061BC99FD65E01D0990580247D82
              F64756FD23F10A001D362E2FD2072EC4E92746E11A12624116EF00E0F2F2A14C
              49CC10FA915D160ED2EF1D005211B3E00CD56983EF2C2E3FD2D74CD2B9216D7B
              0900B3807EEFBD9812F21A7C9FA5F64BB3E925005217DFF337C09275FB7E0F6A
              941EAC790B2058450D0F9C01180A36EC7406306C450DFB6300868265D307DD67
              00832A38607B0630A08083362F0C003F940CF3E5DCE0FB2A0A4207C0D3A29D73
              BB8AF2AD691D00DFB3908515F84ED55209004FA327D0490CE362A640ABAB5DDF
              564A00D41A1D4D62214CFA561AE5B0AD51A009CDFABEA79A646B01A0642C0537
              B022F91540B4699F4DA8401B1A7D09F1B5DFD6D00640C36145F224408C618064
              918CEBB57F39720C1A9D22AD74CD08806EA79CA7AF409800F43F9FF7990CC031
              2206C0001C2BE078F8DC0CE0359ED8EABA5496770E403681F7ED2AC000ECEAAB
              EC9D012825B29BC000ECEAABEC9D012825B29B9003C0EB3C75ABEB5B599C3900
              D984E7FBBC65430106604355833E19808158365219800D550DFA64000662D948
              6500365435E89301188865239501D850D5A04F066020968D5406604355833E19
              80422CDBE167000000FFFFE98694CF000000064944415403008C24300CF859F6
              090000000049454E44AE426082}
          end>
      end
      item
        Name = 'Clean'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              380000059A494441547801EC9DCD8EDC4410C7C720B8A1CCCC75F97803780584
              8410047244441CE0C69D44480894B011444811825700210447444008897740B0
              12574872F678F796281BE7DFBDEB8DC7AEAA76BBED748F5D91DBEEAFAAEAFEFD
              ED9AC96C26FBC442FF4425A00244C5BF58A8002A40640291C3EFDC13B0D96CF6
              518E50CA46317DFB91797A87DF1901F23CBF6380638757509E41691EA6EF8A99
              8372BB39986A3B79018E8E8EDE04D032CBB23D0F88CF1A1B8876DEC326CAD4A4
              0500C04F8E8F8F7FE94B06A2DD848F8FFBDA3F0EBB6405C01D7C01003F0F8500
              1FD78DAF503F63D9272B0036FC33CA50C790BE865A93F593A400B863FFB7AB63
              4E6559DE58AD56D9AA5670A77FC54CB7DDF0F99FAD985342254901C0E77914F2
              30D0D7EBF547CDC1E572791945DACF0B4D9B14DAD282A3ACAF288A2FB9C000FC
              243766FAF11494D21CBC205F37F3522AC90900381FA2B40EC0BD81F2A035D0E8
              389DF375A3DB363176D956123A252700F2FB53141FDCD9ADB443CD337D4853A4
              8818237DA33FDA919C00D148440AAC0244025F8555012A1291AE2A4024F05558
              15A02211E9AA0244025F857D8C025421F55A27A002D46944A8AB0011A0D743AA
              00751A11EA2A4004E8F5902A409D4684BA0A10017A3DA40A50A711A1AE024480
              5E0FA902D46944A8AB00234377B957015C84461E57014606EC72AF02B8088D3C
              AE028C0CD8E55E0570111A795C051819B0CBBD0AE02234F2B80A303260977B15
              C04568E471156064C02EF7D314C0B5EB84C65580C862040B707070F0745114BF
              6E369BE6F7767BB5391E1B4FFF43F911E2DEE4FE2537179BEA0F1220CFF39FF6
              F6F6EE62216F50CE27DE771E37DE3D30F821649FBD05C09D7127CBB2B743824F
              C1160C2E82C5ADBE7BE925009437AAFB7C71BAEFFA76C5EE3988F07D9FC57A0B
              807493A15CEC136CE236EF824BE6BB476F01A0F48FBE41E632FFF0F0D06406AF
              ED7A0B809C47E6FD55ED3BBB73A85394F104BC43F54B7DDE0248CE74CC9F800A
              E0CF6C508B010518745DB371A60244965A0550012213881C5E9F0015203281C8
              E1F50950012213881CDEEB09C0E7402F475E6FF2E17D19790980DD5F45210F04
              EEF513B05DB523219C74B28C4E86B7CFBE02E813B0CD6F4134BD18F90A40C4D3
              AE10029D0540AAF052366451BB6EEBC3AAB30080C2E5B64B73F8FC9FDA23985C
              42A10E8E556BAE8F00E413B05C2EBF69799D4987B077921585C54700CA7E819F
              9039FF2B49D270029D43ECBD9300424E3B9C00C7D02D900C04665BF13A09000B
              2EA75DC3D8DC0F8E01C76C8B575701C89C26E4C0AD20536E080C48664D165D05
              68DAD9F61039D03ADAE1532803A700422E2373DF0EB30C593AC942607716CB29
              006672B98CCB7D30691F799EFF8605559F17FDD99EE1D183A989F9E35870ECB0
              8393A38B00642E1372DF89E7DAB9288ADFF1A8BE5EEB7A0562FC516B7B5553F3
              27B020D9D537DB4580FAFCB33A80767EFF5F96E56B67868F2AAF3EAAFAD552F3
              E7C3A2B9535100DCA59C8264CE6B3A9F599B642230B47844013083CB615CCE83
              C96C0F8E09C7D0827209403E0142CEB34EE7781298900C2B462E01AA795BD790
              9CB7E568428DBE4C580184DC45E6BA09B10CD90AC94660C9FF3E61BCD3F88059
              0997EB98E9B3EA26D9082C7901F0485DA0D009B98E9A3EAB3E8E0D58BEC58160
              53100C8E515A079C757EFFDF329E7887C0E63EB77549807FB78D6C8BCC717644
              4F15811623A4208AA59D2F0940BD069CC30B4AF5794EE7AB8D449CFAF8323684
              2BDB65C6FA146B4C9C7AFA3A47B8A258DA69AC00F821F45F76869E8209ACD7EB
              BF3927AC00C6008FCE4BE6AAA53F01307C51B2160530CAE185E50BC9818E8904
              AE81E13FD20C51006388B7569FE2FA3E8A1E7E04DE431A173F0732EE9C029849
              70F42D8AF91AFE67A6AD452470D5B042F94E9C753AD84980D3B90B38DD47C9B4
              AC2406E4DF862B86CDAB97004D636D87135001C219067950011CF8C61E7E0800
              00FFFF8F9EF858000000064944415403001367F6EEBC02C7FE0000000049454E
              44AE426082}
          end>
      end
      item
        Name = 'none'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              380000052F494441547801EC9A4D6B134118C7933429822924A5170F4209D883
              2FF5D2BB0A0AEAC1AF510F2A5A04C55A41500B8A58EBC17E0AC18B3D2888F71E
              D48AA2D216048F4D52CCC5A6D9F89FC2CA4ED9EDECCCCECEEC6C9E32C366669E
              9799FF6F77D2DD6CA9407F5615200056E52F14080001B0AC80E5F474051000CB
              0A584E4F570001B0AC80E5F474051000CB0A584E3F98578065D183E90940500D
              0B9F098005D18329070640BFDF3FB8B9B939D36AB5BEA3F623EA8F76BB7D19B6
              C5A048697ECE3D8066B3B9C8C486B09D52A9F414624EA046952310FF256C3DE6
              03DFA528435DFDB90500F1E69988C562F1AAAA58F09D663100E4816A0C915FEE
              00E00C2E41B41D88775BB4F8B8E388398B9838F42B717DE2DAE50A40A7D399C4
              D9DAC3E28750B517C4DE0688933A03E70600C439DBED763FE9142722D6476C6F
              1722C6A4BB730100821CC7FEF0567AF58A0ED8DEDEB09C8AEE9C9BF30020FC10
              0459E55615A351AFD78BF5408DE1C299B09C2C37D7A9D03008406176315CB0F5
              746398A56282DCDB49033B0D005F88F72080B19B26E4DA5B4AD88A66F776CAB4
              9D068085DE47B55AB01525BA47701600CEBC2756950F24C756341F684A7D7416
              00CEBC9B522B4DD1185FC6CA377D4E02C0820FA4A8A752E8959515A5BB642701
              E0CB774649A5149D1A8DC60D95F04E02C0F6734565B169FAA8CEC9490010F210
              6AD6CA619509B90A4065AD99F421002963118527002285521E2700290B2C0A4F
              00440AA53CEE2400DC88FD4E591795F0BF549C9C0480852EA2262AB899E35E4D
              49140CCE9EE729CDC94900EBEBEBCFB0E64C95D1D1D10595093909606A6ACADA
              8F305122E34E98BD0C10351CD9EF2400B61A2CF8313B66A42AFF26200D60EFDE
              9962FBCC7EE2D66AB55BFB8DC718DBF07F1386ED06AA72419C3955676900AA89
              14FC5E897CF0DFD043914DD438446BF863C1CF7E5FDC23E690DB9F246B2211F0
              C57717367D54BE986B7998C3A324E9B27C0514B0BDBD162D0E5BD1B0C8266C1C
              B1FF6F3BC1CF61B6517DC8ADF4234C305EA60160A29750F72DF832DEA9542A2A
              AF0B8E43F8DD7B01241847952AE572F918727B524E21C659075068369B1F42E6
              CD7555ABD5CFD88B2F729D29367ABDDEB9919191AF3A524803C01716F74659DA
              6DECB1A7E22C1476CB803019C736890DCEFCA3636363EF92C408FA4A03083A67
              ED3320AC625F2E635E89B706C4E00AB69B1E620FE1CCFFC60D246CE40A00D382
              0985AB720857C31DD6D654AF43FC32626B079B3B00BEE0B81AE60182BDB6A87C
              970A88B32C06EA733FAEEE636E01F84241BC39D422CE60F62E117B75E4A73F16
              72FC82BE6B6B6B6BC3CC071013FD8F8F58C2927B00BE02D83EFE42D405D409D4
              A87F244E60EC85C9877D0303C00791B5A34600595B9A1BF32100963911000260
              5901CBE9A5AF00FF019603C73F98E369CBFA0AD34B031046CC8E411553790F08
              BB4F3CDBEDF6D2D6D6D679F465AAE419002734EE6AA73DCF5BE63A33D0181800
              19D03A740A04205416739D04C09CD6A199A401E05949D4731427FA435548D099
              D4551A40D284E4CF2B4000783D8CB7088071C9F9840480D7C3788B0018979C4F
              4800783D8CB7088071C9F9840480D7C3788B0018979C4F4800783D8CB7A401F8
              CFD7AD1E5BADDD67FC2D85A371850509A50108E2D1B0A40204405230DDE60440
              B7A292F10880A460BACD09806E4525E34903A01F64241516984B0310C4A36149
              050880A460BACD09806E4525E3110049C1749B4B00D09D9AE23105080053C162
              250016C567A9090053C162250016C567A9090053C162250016C567A9090053C1
              62250016C567A9090053C162250002F1D31EFE070000FFFF7193204800000006
              49444154030013DB1BEE9B964D2B0000000049454E44AE426082}
          end>
      end
      item
        Name = 'question'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000599494441547801EC9CCD8B1C451887777676C3880BBBF3A190BD88C8
              1E34D10541D093E4A082F88110576FDE0311143CF80F78F610C183272F1A4451
              3088AC608E7A12A2E4A4ACC95E0299999D2190CDC7CC4E9ECA6C879E9A9AEEDE
              4957557755857A77BADEAEEEB7EAF76C7577BD3DD9C585F0CFAA02018055F917
              16028000C0B20296C3871910005856C072F830030200CB0A580EAF750674BBDD
              F7F7F6F606D8C8131B743A9DADA330D50600C1BB954AE51B3A53C57C29D5C5C5
              C5F38CBD9D75C05A001C76A09EB513C6DBE90FD8ECF57AD7B384C91D00E2BF43
              E026E675198D462DB4782B4D84DC0110F03B2C1414E012FC3D1F894507009FAE
              F989E2320B96121BB05307004E3B5DEAF57AA5EEB04D8F389BC718806CDDF1AF
              55006099790010005856C072F830038A0E80C584328F63B9DFCE84373803CC69
              4612709567F0157311E78FE40400043F139FA9AC4049C5F46EC47DB4F9757777
              F791F9A5D27364A90190FA7D4F888CE05FA4C9439B575756566ED2FEEFB4B626
              F79716801092D4EFB77388759263473B3B3BB5398ECDFD90520240C02E4A9CC4
              E62E6B6B6BFBDC272A739F20A7034B0700F17F62ECB3DE35DC65DF47CBCBCB9B
              C3E1F045043E8B5DC3A72CDC28EE28771874960A40BFDF6FA08D32C78ED09B24
              FB8E619F73ADBFD46AB5FE6C341AE7B0E3F8C46FBAEA05C912F791D738A7B552
              2A00070707FFA9946AB7DB3584BEA4DA17F980F038DB97B189C27DE4970987E1
              4AA900A0CDA3D84441C0973636366E4F386754807042B14BCC0E85DB8CAB5400
              10F01837CF65A4B98889D25F5D5DFD436C64351E47CFCB6DB9AFACC93E53F552
              0110A220E00010A7B0CAFEFEFEBAF01DD1BE92DB57ABD567655F5EF5B4F3940E
              407C40EBEBEB37E3F52CDB40FB576EC7BD45CC2AD96DA45E6A00F32854ABD59E
              531C7745E133E2F20E00AA7E8C4D14EE2BCAA7AB89469A2A3E0278599396739D
              D62B00AC7CA7D601A8F60166AD780300F12FB05A7E5A527AC8D3D4D792CF68D5
              0B00BC0BF807F15F9795E5DA6FEDE927EA8BF30058640D583B4CAD8001F204FE
              512484AD4FA70120BE1058F555C9E7C91D5DB5257A3CAEB300B8E60FE2038DB6
              59749DE0BAFF5754B7FDE924805EAF77994BCCD46F3EBECD66B3A97A12B2C6C1
              3900E4F79F4168F9696781EBFD692E3B89296B1B149C0380D0BF2984BCC2134F
              EA77F515C76977B908E0B8ACDAF6F6F653B2AF2875E700A884DDDADA1AAAFC45
              F0F900A05304A167F5C10700BFCF1A7C11FC2E023885B071FB847A618B730058
              645D94ECFFC2AA4FC79C03C0984A550200CBB87204607924250DEF1C009270D7
              45163432DE057C5664364E0110A293076AC5052735F129FE1FE3BE226D3B0300
              91CF2508FB76C23EABBB9C01808A67B099A5DFEFBF3073A7C51D2E0150BE8089
              B41D0E87B7A2ED227D3A03806BFF8749C2F22EA050FF372CEAAB330010F84B06
              B5874D156EC4AF4C390BE2700680D09314448399F0E0668CF0220DFD242F6354
              2F69C421D6CD2900424D66C25940DCFFDB4408BFC476C80509615CB5871D9773
              33E06105317D7C00605A71295E00200962BA1A0098565C8A1700488298AE0600
              A61597E2190340B672E4B249BA66AEEA00709039BAFB0DC5D7E31347A903C0BB
              8911FDDA793A6DB8B90360E9FF0341954931FC3E95CEA1168963CE1D808846E0
              0689307D5F0914418A6D6D349878353AABBB5A00886024C25A6426DF0444A6BF
              64228E71C06E33E63710FFB1AC63D106407480CCE4CF80A8D1A1FBD9490F3EC5
              DF2DBA20C69ED5B402C8DA099FDB050096E90700018065052C870F33A0AC005C
              CEEB248D2D6F5E596640C8EDE4AD7AEC7C590084DC4E4CB0BC375301B0783ACC
              EDE41D3A9C4F28900A40340282EFB91D218316CB04404426A5E0636E470C5DAB
              6506207AE1616E672A872574C8D38E0420CFC0E15C63050280B10ED67E0600D6
              A41F070E00C63A58FB190058937E1C380018EB60ED67009022BDEEDDF7000000
              FFFFD007970E00000006494441540300CF0B32FDBA65A00F0000000049454E44
              AE426082}
          end>
      end
      item
        Name = 'serial'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000526494441547801EC9DBB6B145114C6B363CC4694EC23692D34AC560A
              A9043B1BC14221085629D2042176FA07F8E8ED8C421AAB54A2904E49632516C1
              C2520B9F4520FB0A0A260ABB7E0776611DE7CEDC7B67EE6B73640E3B73CF39F7
              DCFBFD6626939959134DF03FA70A3000A7F24F4C300006E05801C7E5F9086000
              8E15705C9E8F0006E05801C7E5833E02F6F6F656C91C6B98AB7CB0007676768E
              F77ABD35325ACFA582C3E4600194CBE59F43DD46D7876DA99F1E398304D0E974
              DEC5354C6A8BC7F8B81D1C00087D0D422EC0E2CBC2C0176FF77A3B2800FD7EFF
              08D4DC848996CD418CC8EF5D7B5000BADDEEEF2C056562B2FAB0E90F0640BBDD
              7E056164C61B0D6211EEFF223321E7B3C0B5FE8552A974597620144B39B2F12E
              E38200806BFDB7AA22E9E4A8D62822DE7B00389DFCD29D689E5CDD9AAA795E03
              C065E5539C4EA65527358CA75CEA63B8EDE3A7B700700E6F40B06558DE6579D0
              57DE7E8CE45B04A0367E9CC33FA86588A38BEC4B5C45CFE325005CCB37F5A623
              CE32D1A7B89ABCC74B00D56A75AE56AB956A02134D4F144FEDD4A728CF65BB97
              005C0A62BB3603B0AD78AC1E038809627B9301D8563C568F01C404B1BDC9006C
              2B1EABC7006282D8DE64008615CFEADE3800FC06BA8E1B62FD98BD6FB55A27B3
              0667CA8FBBA45763E3898F4FB85DF4988C0180F02B34493CA35D4918F4B9288A
              BEC2DF4DF01DAA26230020EC22845F9750B282BDF18744DCD886180100B55EC0
              A416DCB33F0160B7A582C730A8700038F5AC69E8F45023672C520A078053CFAA
              8E32C82B7C2C3AE3B09DE3CDA4777777CFDB9EBC0FF5BC0130353535E78320B6
              C7E00D00FC30FEEF855BDB62B8A86702C0779D89542A95B64E5EE8398503C003
              F08BAAA260EFFFA89A931A1F90B37000B3B3B3DF30FF4F30E9057BFF59E9E031
              0B2C1C00E98387E0A77159B94FEB12760A47405F226E2C438C0020A5EAF5FA31
              4048BB1DD1AA56AB4700EB33C51F563306800405849BF49964107E0E7B7E2FC9
              67BA6D7272F20D6A5C8A19361317D9B8C4E4AC46A300B28ABBF2CFCCCCB4B003
              BC1E35D1584663685D14A7DB7E2801E88A65228F01985055A14F06A020968950
              06604255853E1980825826420B04606278E3DF270370CC98013000C70A382E6F
              FC08C0ED8683A439763A1DE1CB4F9D0C5F527FD4969597E6A7FC04D3FE8A6C42
              5F894DC601E086DCE3C4CA01344651F4C4F4308D03C0FD9360DFF9C1738A3BC1
              03A009E03474833E03B3EB36C66BFC08A049E0BEFFB39020D05871E44ABFDD47
              73D4352B0068700401932A61FD012CF3FFFD418CD505A2D3C5C23D1A238DD556
              716B008613C204EFC2CA30E1F780B37CC3BEE29F5979697E883E0DFFFD789F59
              DB79FDD601E41DF0B8E53300C74419000370AC80E3F27C043000C70A382ECF47
              000370AC80E3F27C043000C70A382E1FDC1180872AFB1302D1D27C8214E7CDC1
              00D8DEDE3E0A81E935F6728A6A658AC143A060E615CC40E7E7E7A5EFA076BBDD
              3F2990BC720501A0DD6EDF52542DC291B0A898E3243C0800B857FF48439DE71A
              39D6538200A0A90A3DFCD14CB59736CE00ECA998A31203C8215E11A90CA00815
              73F4110A00E94BD0A116F8C1AD9C33CCB5F9190A00E52F72E397B1333685D4AD
              A50040B744FEBC5AAD46DF25DE52E8690B395F14E29D85060180D481A0F45794
              36683DCDB0E76F0C62D3C2BCF10503801483B04BCD66731A22BFA4ED51A336F2
              D5EBF5A5D176DFD783024062361A8D03887C0530FE79B18BDAC8473121597000
              42125766AC0C40462583310CC0A0B8325D330019950CC6300083E2CA74CD0064
              543218C30032C435EDFE0B0000FFFF5FF2D8020000000649444154030015DED9
              D0809B787B0000000049454E44AE426082}
          end>
      end
      item
        Name = 'wifi'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000BD0494441547801EC9C7B8C1D551DC77776EF76774B7BF7EE6E176A49
              23BA141037414984A2365A425014D3A43CBAA548DA5A5D0986060B89AD46880A
              F247D182A6626B69A558BA7DF84763456DB0B11A5E6964C514218A45EB7677F5
              765F2E60DDC7F8F94DEE2C77F7DEB9F79C79DE9121E7C79999F33BBFC7F77BE6
              CC9933775B5D95FC172902090191C25F559510901010310211BB4FEE80848088
              1188D87D72072404448C40C4EE933B20212062042276FFCEBC0322063DDF7D42
              403E1A111C270444007ABECB84807C3422384E088800F47C970901F96844705C
              B1040C0F0F2F1E1C1CDC801C1C1818E8A13635E51FE81F3C73E6CC06B11501B6
              4A2E2327A0BFBFFF3C007E00B0869129902727279F2583CDC872C3301650EB96
              F3E9B0BCBABA7AB3D8CAB7CDF1F0D0D0D0FDE21B9D484BE804F4F5F59D0B008F
              2116D8B366CDEA03E08DA09046C22A69D33437896F3B0EEA1DBDBDBDAD610560
              FB098500A6802B18712F93A4595757D78FF33548A595B5F5F5F5FF94189113C4
              FCA130020C8C0046D86C12398A984C01CF73FEBE3012F2C9C7A5C4FC82C48EFC
              9AD867FB64B7C08CEF04309FDF42D02623FE0DBC7D1CC995D8564B2517C989DC
              56FA9D856F0410E0E388C97CFE13BF83AC147BE4B64772447EEC574C9E096074
              1C262093803E8BBC53CA6D923377C4CFBC26EC9A0002D88E303D9A9FF21A8443
              FFFF72FD10B29EF9B8BDA9A9C968D290542AD52E7D11B121B638F4B770477C5A
              3080886D6E2D6B13C0EAC09AE371B80EF1ABBC86A1BB46474767E7815CC7F132
              E49196969613B46B95B973E79E90BE88D8105B1681E2034377217F457C2910F1
              7921026C3A740D2A1300CB8D4C37638C463FE6F809EC6C001C0B14EA0B912D0B
              172E7C4B37015D7DF121BE9036C4C8643282C1DD8038A16B6BA63E393D091163
              274F9ECCCC6C733A17E74E6D53D731FA04010E31DFA4A62EEA1FC872B4539246
              528CEAEFE89BF0BF077999C4F31044A4A839353AF122CF342A5725852D201BDC
              ADD2BB2401DC52CD58926056A9182BA60369FB2431A41AD05DCF95C56C07710D
              F0B649AC8890B1CF838F5B053B668DA652361C0960CAD9C42D75A654E7326DAB
              2589E6E6E61565F42AB6193256480E04E8FACD9D010894039BB051B41425801E
              BDD07F7FD11EE52F7E4C82467C5B2B977719AC06B9EC420CBCB87AB1142CB91B
              7AE85F50A61170FCF8F15A14E5656A7E8166990B38B95182448E95518D6D33B9
              FD062155E326D524F2F41608B68271DEB5B77F1D4DE307DADADADCAC97B74850
              994CE660BEE1208E653EE5B97425722B77E997908D1C7F8DD8EF44D68C8C8C2C
              6199795E10BEF36D92EB01C9996B8F205A453026D6CBEC4ED61D4062B2A67FD1
              BEA8521B86919520105953AB7451D261CEAC21C0D5C831C4DAB2B66BDA06782E
              3D87ECC6FFF7900738FE26861F461E9B989838363636D667EBDB3544F592E3B7
              FD2687DCD72332350DE05FA774F3A1E873D2A19A201F27B1ED72A22A24BE8251
              E0DBDE3931DC878C23B289374E1C3B9125882F8578E793E3576690B39D6F13E7
              F8E100125AF0A1F512C687A21F91EFAE6A027B522388B3389397172FCBB32A7C
              1A8CCA1F108035C2F17F2F52838459D6F16D623417C311626AF0E29C01D925D8
              60E32CA254F0D955CD32F1290E3EA3D063270EEA15F41C5598066E24E149EA49
              46CC171D15C36FB88698DE24369381718717F78211D3E2AE72360473C1DE7A06
              7020BB7ACB9C3A61F02A0CAF756A2F779DC43623F834F7A32B732655651606C6
              F7255644627515242F9C6BC0EC23253A2FCB61FEF62A08800FD1A96079C5AD55
              87C1E74A18736C22891D88BC496F7054AADC06B95BE599F48C9B10C1EC996C36
              5B3063B050B841B0B66D5A77807D42A7038C00FB61328122A786F6D294DBF90B
              39E05DDF35764C51D7DCB657492EE4B4553796458B1659CF4CFA591B7D8079F3
              BC79F37ECAF9549946805C65C477E17415E06B6FBCB12697BDA349FAFF506C05
              2813F8388DFD1749EA79EAD7390F742715FBB70B11E4A8FDB15EB0A4FF4AB02D
              98D60A0820992AE6A73D52EB08C1ED630A93BD235FE67802FE15B212809B49C0
              DEB6B6EB14319ECFF5CB496A31F57B38CFFF9660E9D196A2FFB5D8D11EBD4EB9
              93A37CAC7FD5A9DDE93AF1ED2DD6569480628A4ED74E9F3E3D1BF0659E2F787E
              38F571B83E0258D6E617801A04FC09642F200E3AE83B5FCEB5606F82FE47B073
              87D814810C790B7D39A7E2B6BA4872668EBFC4AD01BB9F270298173B1B1A1ADE
              B08DE9D680D15B5353B34480411A01CBD3FB858A7FC878095FEF47E0C7B8903E
              2F21AE0AB1FF8965ABF66C91EFCC35018C80DF02E0A3F9C6348EF70B0080B120
              9D4EFF4EA39FAFAA10FE1A715C86C8B4F9901BE3B0B8122CB26EFA4A1F5704E0
              F0DF74FE28A25508F6414916B959AB6308CAC474372244DCE6C25D0B98301E4D
              E9AFD55D9B001C4DE2610EA25C88EC97921C234E7E03AADC2F0A45E2DC8D18EC
              D5687F32654A166CB4C2D626003055B62DAC2018F16701BD86A9E693D68518FD
              AFB1B1D1FAD100219F44940AA4697FBAD52600300F43C2F50A117D1DF0EB2141
              7B5428D80E4D85BBE1BDE4706D3987E874409AF603599B0009444880EDEBE478
              A610C8784F4F8FFC0E47F6E96736BB3A67EF3CCD6A6315B217B17730AD9D54A6
              C4A99A29E02DCE0F22ABF938D3E2CA59914E0CA42310416A465F91E62A1A3AD0
              E92AD656EE9A2B02C4286CFF622609A669BE4220B5EDEDEDDADB1762D316DE36
              AF00C4A388052E7E8649F2096405E2B8878F7FD97B598E9D9DECB964EDFE10F3
              2C7235D73D15727B173EA66DDF138F6BF02518D70448E77C1208642B7786EB9F
              A033CA2F65745B7F8AC4DBA66C2FB8FA002E71CD14405B8C3C9D23043703AE3F
              F690E32DD8B7768EC9F926487135F2B161154F0488052181409A09C4D53E3AC0
              AF176018E527B0B3406C062C4DF8B13E77E2DBD534C97474887C6B91035E63F5
              4C8004402083555572A42E80BE1631017E8B7A2F7F35F12D1FF4E523CC57752D
              43A27C3AD5ED56A0EF0B0105564B5C00F40F22B277B4A3845AA84D80F92D8989
              674FE8CBE5500920C91740F6F74845169E3D4F11E3EB6106170A01A74E9D92EF
              0432EAB5F7D2C30423E7EBDD9060B28CBD28771E681538012C393AE6CC9923DF
              09BC269265AAD8C6BC2D6F9B17F0DCA9E56168EFFBD762FC026963B5B30DBD7F
              71EEA9B08C7D1522EEF36444A173A00430A75E0918D3D6CD0A31592AF4FB8F00
              6A834CDD0AE89DACBAF670FC37DAA71E82722CD7A48D6562277AE7726E91C3B4
              D201296F5A46F5FF772F24ACD6EFA6DE2350021A1B1BE5CF5355B62DA62206CC
              47053C406CA0BFF6ABFD94A1DC01DFB9BB20E51CB1C9A5EF22CA8558EEA1DF2E
              E50E2E14032540E221F9C3D4D68B0BB56321D98D246B00FCED8E4A1E1BB0FF65
              045746591FDC351B8945FEA9048F5E4B770F9C00714FD28798536F90E322225F
              A804F8078BB405720960ADBB0CE3479162E51B0C9C50E2098500C9507E8EC1D0
              9BF621667C7CFC12C8916FB4A212BAE0FBEADADADAF9F98E89513E1AC94F25F3
              2F07761C1A0192412693D9CF8355FEDADCFACD516B6BABF6AF0BC48E9FC20AAD
              1F22E44BD628D3CE6662D4FA68E435965009906079B0EE2561EDDF1C49DF2085
              98E632EDDC13A48F62B64327A058106EAF8D8C8C5CCC7B86FC41B65B1391F78B
              1D01007E1D6B73EB3B010FF65798B3FF689F53DF1939A29A01C48A0000EE06F0
              9F97C8F16174FE5EA2BDE29A624300C076839ECA8A6921BA7F41371625160464
              B359F9D2A602BE0D7ADBD0D0D0E5F64925D7B12020954AFDC10588B2F5EDA25B
              B85D624100EB73D9EDD442863E61FFCD99567CB6722C08B083FD7FAC13022266
              359E04440C9A9FEEE342809BB5FD9FFD042A285BB120A0BBBBBB4D170036D52E
              D6ED13857E2C0858BA74E9386FC0D3B6B24B81C50AE87AF4E54700A5D42AA22D
              160408528CE8FD807A8D1C97929A9A9A0FB3AB295FE14AA9554C5B6C0810C420
              E169B68D65EFBEE0475D8CFAADD2964EA7E55F5D17F55848AC08B01105E87588
              F5AB07BB66D4BBFA6DAA6D33AA3A9604440556107E1302824055C36642800658
              41A826040481AA864D0D0234AC26AACA0824042843158C62424030B82A5B4D08
              50862A18C58480607055B69A10A00C55308A0901C1E0AA6C35214019AA601413
              0282C155D96A42803254C128260494C135E8E6FF010000FFFFFCB7EABB000000
              0649444154030071783C0C4546A0AB0000000049454E44AE426082}
          end>
      end
      item
        Name = 'wifi-disabled'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000D65494441547801EC9C7B9056651DC7DFF7E55D96DD04965D5A6D36C2
              5AC1FE589CC129B1C8343287268B86CB9AC94C80A043195E6AD41069CA986D34
              26C5E8020A3696C94D4752A921099C5249A48B3B930CD59A08BBED2E7B815D96
              BD9E3EBFD73DCB7B3997E739E77DDFB3AF1EE6F971CE799EDFEDF97D9FE739E7
              B9BC1B8B84FF028D400840A0E18F4442004200028E40C0E6C31E100210700402
              361FF6801080802310B0F9B0078400041C8180CDBF377B40C0414F361F02901C
              8D00EE430002087AB2C91080E46804701F021040D0934D860024472380FB510B
              40474747757B7BFB12E851EE8F703534E96DF8779D3C79F25BD0E501C456C964
              E00018861127504BDADADA5EE43A1264F2FF450DB642CBB89FCE55375521303F
              168BFD087A395937F79D80FA83A6A6A64A78024D8E00E0E8CC13274E9466DB43
              5AE40A74B7400681E847FFD668347A05D77CA509807A4F7171F1FFC48761DA7C
              EAD4A98A7C3960DA710400A6C3252525DD38B8967BDF8956BE125D062D7213CA
              2643A3292D1F1C1C6C15FFA0BF373737CFCC8773B600D0329B921CF81EC1EB4E
              7AF6745B5E5EFEB3B2B2B218ADAFC79382FC095D525454741820A487FE1E7FC7
              E5CAB42500047F2546CF4F36CA10512A0E415F4ACE57BF7F87133D064094A2FF
              CE777246F7FFF8790DF1E8A1DE435C1766DBDB0C000CC328827EEA60E8199C91
              17A4038B7B11203C406F88C3D90715428A12971DD4DD60349021342B3E670000
              CA671534CB27A2C14BEB62055E5B167AC3E0A449938A61B80F2A9884DFF21121
              5F6CBBFC3A9D0200C17F128529793CDB265E5A6F20B3C79641B10010D6D21B04
              884153844A0E427B6975AB878686661F3F7EBC18BEA82A2137035DB741BBA15C
              F5B2F9D223A087B0E129A5049B207C052D6F41CA898ACEC501A3A5A565BCB290
              0523C1EE23B8712811647C8943D73054D5555454BC545353A31544E4EAD1F510
              340F1A01AFABAB4B3EAB6FC785FF40D94AAB2406D0977515A60020C2383B9560
              5C27F73A148FC74FD11BEA746482E09D32654A0F757C10AA86A2802C31F83675
              1EE97D3EFC7A1A107A6994EF53D521C63378716A3B14C3A9DE8C42870C0CDF8D
              0367B8461DD8465511753400623DF54DF43E9E6FC64103F29AC6D210BBA05FA8
              28B004400471C4983871E224B9D7A4128CCB27DB224DB951C10E109B00240649
              23DAE1D5291AE14D34468359FF04271DB600207807813CE324EC548603DB71E0
              4D279ED15E0608B59000B1D4ABAFCCFA3B89C31D76F2960020D080E07A3B218D
              FCA9E892EFE61A0D9951C70A088F4102C4551E9D5BCFDCC1F2E32605005A6D91
              040C231742594B0C67AFA3F785AC290C4811201C80A84E5479466CBA8AD01462
              40888D31669E5C4700904915438ED6A79E28D0A039C30E9469C8D8B2A2EB6BD0
              773B3B3BD77095CFC0A5D4E10A3E335396506C15F828E03DB14B8040C506482B
              11E3017AC3C8889000800A2C95499596A648A41F38576ACA44700073ED3FD695
              4BE72700BF24EF6F4CD264162D13A12DD4E1C5FEFEFE260CC82C7584A8702354
              976D70F0E1564886A6367C514EF40619119688400CC71EE7660BA49C08FC9D18
              1ECB64E7E7B406E952BA3DE73682D48B9E440350369CC6880FCF40B246E3B852
              4B852F80EE4E0367331B32CADFEB69A6531EF1A102FD32894DC97779D84A0C1E
              93003CE1C2985C3C48C0E304FE013313C3433850CCF57E334FF12ADFCB830C21
              8B15F96DD9F0E73CC05C63CB605DB09C0D992E82203D45963C4AACD9D47289CB
              36E220BD4179EE84CFDB6238BF879B2F2A98D981813881B69C31E2C05DB430ED
              E5088690C709C2DB0AF61D59A8C73A7CF01AC4AB191ACFE0874183F8A6A32197
              4262247B075B5DD82212737CDE233D20C2CDB308CC83ECD25528AEB52B34F32B
              2B2BBBE09356F09499A778AD92CA7777775FAAC86FC946E3382BF6A9DC764B06
              854C1AC406F105F23C09C38765E899ED606EDE70CCCFFD460CA1DD0865CC5E79
              71955276C041594611FC0BD0F5A18C02978CBEBEBED7A8F89F5CD85C8BA9DC75
              5EECA7295E882F063DE3A5B47CA54759406C6D6D95DE90CEBF80F8C80A6D223F
              D1031277FC87D04E5A91F93291B13D2A8B571469259C5EC844CE72E2A1A068B6
              549C4F4A5F1BE4D4E5181595DEF857059BB62CF4A64F883FD4C96993CA527EDA
              B469BDC33E24866D622B33EB94D1210500D1C238BA0DA33720285F3792A54CA7
              4F9F7E3FCE0E21EFB9FB9AC6F8A4940DF29F98CF5EAFD4E352FCF9945779530E
              1D890305BC233E6EE6A95EF1218EFCF5C436232E19008852BAB0CE9791884408
              FCAF0606069A799056C7252BE91BE895F986766348B64E7DFE4C106880D196E4
              7C2FF70C6D7FC1A723BAB2F8209B5D196296006470396480ACB97C7183039B9F
              A238DD7F80C5C1E5CA4A6C18698195A020CBCD361CCAD9D301C1608CFFA8B284
              0DA32F00E88E73098EEE24CCC615E76CDE299BB1957C54C659C0A61410364172
              1860C08645397BCC9831FFC4A75F2B0B58307A068016B08FEEE8753F788B0C09
              F823CB095CD412BDED7CECCAB7FA2C35096B2E7A811C0628A27423E42BE1D357
              F1A9D5AB124F000C1BFC8CAE512ABE5A020FDD28B25C97F0B2FDA0DCEB10C0BF
              42CB7B4547C68A17FBB7D0B37C7D6D0DEBAD2026606168BFFFB401C0D01046B5
              9CC6B3C49A0D5DBF0ED9943479F2E4E30442D673EA530A5C1ED0390B5F8CE6E6
              E60B5C581D8BD9F56B13FB30FD11F2956814121B2D1DDA0050719D93715D6565
              65B268E77A5A80AF8419F486CF69790F7351515123403CCAADAF040873A89B1C
              65F1AC879EB94257581B0002F52C8E5EEB66089E35546A3CC38E9C7E76634F94
              D31BFE808CF486D3890CF5FF9601C2C0A14387645C57974AE3A46E7294458611
              2F5BA9AB98FC3D92A6D2F5511B00D188A3CF31767E5EEE2DC8A0D597C0B3CEA2
              4C290BD90900778F12F339A631D5D5D57D7C997DFD5C96B73B1AC187919C0F29
              251ADB7790795889398DC91300A283B1F3771620BC89233182A772BC51D45812
              41BC8C4ACDB52C74C96418D8486F38E9C2E65A4C3D9E86A4373A1E4CC0CFFB69
              303F745568C3E01900D19706C223382C2D478AB489B59F8B09DC31C820880751
              E0E7071BE5A207FA347A7C25822B9B366B6D946CA4FC2E9B32A56C5F00880501
              81165F4EF0B55F40224F906477CCE005FC06CFDA9FA4C838A503E83FECC4A052
              46DDEE63582D8577E4C0167596B9CC2DE4F94ABE0110EB38D71E89C89D3A1198
              7B21A990EFFD6117AB33C54E6B6BABFC66CC85D5BE9880F70084C46B27C3CE36
              EA9C98CBD84BA895884235CE2C71B1073D430282BAEF43794B2C1BC8AF2665FF
              DB974D4058C4B0632ED9FBD225C2790580C01FA125FD430C07448BF161B0BEBE
              7E6C40F633CCE6050099AD5271196EBCFCDC34C3699F19B1AAAAAA5EFCB13D2E
              E853BF9678CE0160C85929B3552DAF2C98E9392D8CBD9BF8F49565EF0B19838B
              180E12BF25902BE5BA9FBEEB01A1DDC2545EB3720A002FBE5904467B2B6F3802
              3D047CB1045788805732F6DECC57D7133CFF17BD03C37C890BE525E465AC3525
              0AEDFF2B030403D25E58B457A957925300585A3848105D972DD25CDE4080A350
              2901D75A6B0784D55E8EC6607F1F20BCCE35EF29A700486D08E2735C9D8EBC50
              1C8930F9BA9DA04BE06F4D6478FCCF3C1A436F785E53450D20188D8D8D593D98
              ECE643CE01100708EC6E265A0BE43E9D08D4AB944759C87A30BDCCCF33BDE10B
              B1584CFBA53F6EDCB80680C8D83CF7E38B936C5E001007188E9E22D82987BB78
              BE88405D26E5B920DE1747055C741F8574929C0992D31D56E77A74F4B8F2E60D
              00F18460EFA0555ECFBD6C094679FE37F7394F8030DDC3BB28DAD1D1D1C357DC
              6A2707FD96E51500719656F92401914D7179CC1BC9BB08BBB2BAD9A563945EBA
              0E1074F727944DE41D0065CF141869D5C50D0D0D5AC304408C27A85AAD1AFEF3
              782FC84FADECF64014BCB56629380008C495907CBB1B0C116719C67ACC675AAA
              D21A0D327550092191D93917B50410CF634BFB509693F682028080CBEFCCF6DB
              558800FD860029BD57E09593D452FF9D76FA6CF21387B2585EB9C8A65C2B5B1C
              D012088A99C0EE370C638E82FD8FC0ABBCA7CB7B61117AA72AE84D616179E528
              767E9B92E9E1A120006068B984BA5D09A9A6A9044779378CF7C25B00212F68DD
              D9F0B5D831FCFCD4A9200060B8785535F2497C5ABF6910398010A0B5D785867F
              EAE4697FA320002038795BBFA727EC87E4688AEE4AE9BDF454C70D7CEA91910A
              05800CC7739D0108E5D8580529277A6A890C4990EB41345369088019098B2B20
              3CCCE7AAF4BEC42F5C2C58ECB2E4CFD628BD4F0A1300BB6AE7209F56DD0F1032
              7377FDE563B27964948E39160A000DC99553BCCFE65FC48A10D065EC357C40C5
              36A065FCD8D14EAE2000D8BB77EF34BB0AD8E523A3BD146DA7CBCC67AFA10920
              886F540E8E99D92957E614C718B69427770501406D6DADFC013FE53FA3267B0F
              229312992C3E10E0CB59D5B5FC83E07CCA6AFD3CB7200090D851E9ED34BDABE5
              DE89E0F9ACEC3D38F164A38C55DD83C3BD61E46753D8FE98AEEE8201402A0608
              2F48A5B9CF38064EE5374B193CFB28CF5BC29EBC176E64E87999FBD7740D1714
              0066E508F40A48F68F4788CADF6496E7FB8A2F5B187A3EE9C56E4102E0A5A2A3
              55260420606442004200028E40C0E6357A40C09EBE4BCD8700040C6C08400840
              C01108D87CD8034200028E40C0E6C31E100210700402361FF6801080802310B0
              F9B007B80090EBE2FF030000FFFF48D006EB00000006494441540300E980AA0C
              A17E66140000000049454E44AE426082}
          end>
      end
      item
        Name = 'wifi-offline'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000BC5494441547801EC9C7B8C1D551DC7F7EEDE761F6EF7D92D4DA59164
              AD1642D48856A936B00D12104C09D4965A34148B852890BAFE611B234603F68F
              420049C596960A58FAA01A1B5B68B02255016BD555538B095AB1B6BBD57DDC2D
              5BB5EEE3F2F94EEE5CEEDDFB9A3377E6CEBDED34E7B767E63C7E8FEFF7CC9933
              67E6B6BA2AFC172802210181C25F5515121012103002019B0FAF809080801108
              D87C78058404048C40C0E6C32B202420600402367F7E5E0101839E6A3E242015
              8D008E430202003DD56448402A1A011C870404007AAAC99080543402382E5B02
              8687873F3A3434D48DEC1E1C1C3C411E37947FD27EF7C0C040B7740580AD2393
              811370EAD4A90B00F87EC01A4692204F4C4CBC4204EB911B2391C82C72D3F44E
              3ADC585D5DBD5EBA5275733C1C8BC5EE936DDA049A4A4E405F5FDF0C00D88258
              604F9D3AB50F80D780421352AAD4148FC7D7CAB6ED07F9E6DEDEDE8E523960DB
              2909014C01F318717F26C8786D6DED298CAF40CA2DDD565757F72FF9881CC1E7
              0F97C241DF0860843510C88B489C29E0D79C5F5C8A803CB271093E1F92EFC8CF
              F0BDC123BD196A3C2780F9FC33381D67C49FC1DA954822556CD6A5581413B12D
              F33A0ACF08C0C1279138F3F90FBC76B25CF411DB36C5887CDF2B9F8A2680D1B1
              1787E238F459E47C499F53CC5C113F293660D704E0C02684E931FEC9629DC8D1
              FFFF94EF41EE613EBEB4B5B535D26A20D168F452F545A443BA38F43671455C27
              0C2062A35BCDC604B03AB0E6780CAE44BC4A7F45D1EA9191918614906B395E84
              3CD2DEDE7E847AA3346DDAB423EA8B4887745904CA068A56237F433C491071BB
              88009B9B4D153A2600969B996E46198D5ECCF1E3E8E9061C0B14F277230FCD9E
              3DFBBFA60198B6970DD9423A91484B4B8B30F80A208E9BEA9ADC9E989E8188D1
              63C78EB54CAECB752EE3B9EA92E5287D1A0763CC37D164A1F98196A3AB143412
              65543F68AEC2FB1EC415C79F0720224ACE69641556744F237395A2E802B2A1A7
              9CF4CE4B0097541B9AE4CC7227CAB2B581B49D0A0CA90674D7736536DD7E9401
              DE46F98A888C9D45D8B845D8316BB4E6D3919300A69CB55C5203F93A17A8BB55
              41B4B5B52D2DD0AE6CAB2163A962C041D74FEE0C40A01C5C8B8EAC292B01F4E8
              85FEFBB2F6285C78859C463C5B2B1736E96F0B62D98A44B0E2EAC1525872359C
              A07F464A23E0F0E1C35368A887A999192D0B146064B19C440E16685AB1D5C4F6
              1242A8914F3B0D22A5DD2C612B8C53CADEFE3A9ACA0F747676BA592F3F24A75A
              5A5A76A72AF6E358F329F7A58F20B770957E0959C3F1D7F0FD6E64C5E9D3A717
              B0CCBCC00FDBA93A89F559C54CD923885112C6F8FA7EBB9375051098D6F4BFB7
              0B9DE49148A45F4E205A533BE9E2A80D73660D0EDE8A1C44AC2D6B3BA76E90FB
              D2ABC853D8FF0E723FC7DF42F1C3C896F1F1F183A3A3A37D767B3B87A85E62FC
              B6D7E410FB3D88A6A641EC9BA41E5E147D5E1DAA71F24902DBA413A742E04B19
              059EED9DE3C3379031449B7863F8F104B200F124E1EF4C62FCEA247236F16EE2
              1D5E188084766C183D84F1A2E871E2DD5A8D63CF18387116637A782966795685
              CD08A3F2BB38608D70ECDF8BD420A54C2B79373192F0E1057CAA2FC638037287
              B041C759C451C2E68E6A9689CF71F029073D9EC0409D8376399B300D2C26E009
              F20946CC1D391B96BEE22A7CFA0FBEC519185F2CC6BC30625ADC5A48873017F6
              D63D8003EDEA2DCAD5098597A3F8B65CF585CA096C3D82CDF82EDA6ACE242BCF
              C4C07854BE22F2D595933C70AE00B38FE5E9BC2881F9DBAB2000DE43A78CE515
              97562D0A5FCDA32C6715416C46F424DD9DB351F956E86AD53DE965372E82D9CB
              FDFDFD1933060B859B84B5ADD3BA02EC133A3DCB08B06F26E334E43462BC34E5
              72FE420278D7578DED53D03997EDE58A85983698FA3267CE1CEB9E493F6BA30F
              30974C9F3EFD879C27531A012A65C4EFC0E872C037DE78634DAEBDA309FA7F4F
              BAFC1202D14AE904F9EF905790D710BDEC57B92F6689E94E11418CC62FEB8525
              FD97816DC6B4964180BC677EDAA6DC44706E275398F68E3C99E371783FA0EA6A
              C4FF567BDBDACA09644A6B6BEB85E49721F3918B919994A9DC6AC37184B2283A
              F48CF35B9358F2B52546BDACFF4BBE36D9EAC0747BB6F2AC04646B98ABECE4C9
              930D80AF793EE3FE91AB4FB672003F0D584B049C0487AF01402DED62D9DAE72D
              4B54A26F1C1D9BD1F721C4220600AFA5FA0DA498F41EC5CC1C3FB71825EA5B14
              01CC8BABEAEBEBCF48911B01F45E6481C001F066C0CAB844DDE8CDD787FBDCF3
              D8BB0889F030348FB66F22AE524D4DCD5196ADC6B345AA31D7040C0D0DFD02F0
              1E4B556670BC4B0000FA2CE49706FD3C6DDADCDCFC1BFC6842346D3EEA463957
              D932B0E877D3577D5C1180418D9A8F4B8189E0EC3A058B2C31E9578AB6F87417
              828B91752EECB58309E3312E228DBA1B1380A1092C34228E139EED57704C31FA
              06D471BF201ACA47F90A13C6BBBBB1584CD818B96D4C00603AD9B6B09C2088B3
              0454C334738D5550417FF07B31A2A5F89053B7B9A718BFBA35260030F742C2F5
              0E9CFA3A01D44182F1A870A0BB244DF05D0FA36D18CBB94D439D95043EF714E3
              1BB23101B29620E13A1D4F169C1E03787D87A37DFAC9D5AECE21BC91D5C67264
              3B53E019C4DA45CD920F300DEC67AF7D352F67A6BB3296A51353D21E44F3BBEE
              7D6A7196388F22DAA2F939FE2D7703BE14B922401D21611FACA77D158723AF01
              FE141C33DEBE904E5B00F132C03D80584073FE263A9F46F4823FDF97CA6DF870
              357E3DC89ECBBFEDFEE47F476EB0F5BBCD21C15A3191D711E725883629BBC0C2
              78E45725FEB92640FD61FD3982D5834D15E06CC011D79FA03362E702D271040C
              E387D1BF10F12ABD0B453F926E64185BF3392F8B5414018A00129E07FC364683
              AB7D7400B90B8933628FA2EF42C4EFD484AD5FC926F280DFC60AE92F9A001900
              FCA1AA2A1D3917825F81680BC3F8C5B6732B055B7E593E20FA2D5AC1C67E34F0
              840013C7B891BE8F8005FC16937E3EB7EDC62F7D92E8B3994CF5252500E00F31
              5DFD21D38DC04BAEE4FEE5780B9D38ACC5C1E4DC4D142521E0F8F1E37A4FA051
              6FBC97EE2628933E0C88DB59D5BC64D2C7CBB6BE13C0A57D736363A3DE1314EB
              773F606D64D5A5A7CD8BB8EF24F7FE4746461A464747E76060214B288D64473B
              B4E8FB297A1EA75F60C95702787B348F204D3E7B490241BFFF096C46A7B58F4F
              DE0158AB58756DE3F80DEA936FBFF4CDFF8C19335EA7FC45A6923BC81B11AB5F
              62FF3FDB875313E8FB44D2604007BE1200588718914EB62D92E103EC63020F70
              EAE9EFFA01C75698D8FF6F974ECABE8958696C6CCCF18F28AC0E3EFDF19500F9
              CC88DC4B5E702F05A2D6082480BF93F6BE24F4DF8B684B6151474787BDADE08B
              2DA74A7D27408E10F41E1E7E6ED27116F923F511885A97A5CE9722ECE9877BBE
              E836555A1202E4943EC7607A497B11C334301730925F0AABDDF926252340C032
              BDECE2C6AA5F9B6B9B37C23460FC7581F4949314EB4B490990B3DC58B733EAF5
              A243A7E7BD949C002F116757F3BD3C67E807D95EAA2DA9AE8A2300C0AFB5B700
              B8B1EB8BB83FD9E7E47797143D0F8C55140100DCC38D7C5F9EB81FA6CD3FF2D4
              975D55C51000B03DA0E764C5349BB6AFD3D6B7C43DCC7ACA9E9CBB31581104F4
              F7F7EB4D9B13F06D0C3A63B1D807ED9372CE2B82806834EA660BFB5039036FFB
              561104B04D31C576D8694E9F52FFE6CCA96B69ED2A8280348FCFB19390808009
              AD4C0202064DE6791ED9C76ACB7E357940656EA45208305EDBF3BCE0DB3E132B
              2CFD7AC7FA1E2A01FA4295258E8DB28A20A0A7A7A7D3282A1AB3E7A4A52B47DE
              276EF0574FD69AAD6C729B6CE71541405757D718233A6D2B3B5B307619605C4F
              7B7D046017956D5E1104083D6D6503EA553ACE27353535F379B9A3B770F99A15
              5B97EDBFE479C18DD28A2140C141C2013DFE73BC19494B8CFA0DAA6B6A6AD2FF
              BA9E56E7F50976AE40E78F112B3130F463C28C69C9AA2CF0A7A208B063018095
              48DA7E0CA3DED5B7A9B64ED31CFB3720960F0C0CFD9CD65485D5BE2209B03C3F
              47FE8404044C6448404840C008046CDEE00A08D8D373D47C4840C0C486048404
              048C40C0E6C32B202420600402361F5E012101012310B0F9F00A080908188180
              CD8757400102FCAE7E0B0000FFFF1E008ED200000006494441540300BD08560C
              B23E1A680000000049454E44AE426082}
          end>
      end
      item
        Name = 'esphome'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000450494441547801EC9C3F6F133118C69BD0A02EA849888460A2030BA8
              1FA01BEC3030B032F30198F8002C7C003E003B0BDD61828D055858E804A2559A
              2A124280C2F15C45DBBBD6679FF3DAF7FAAE4F65AB77B6DF3F7E7EE7E4CE69D3
              5FE18FAA0204A02AFFCA0A011080B202CAE1B90208405901E5F05C0104A0AC80
              7278AE000250564039FCF95C01CAA217C31340510D85E3E400CC66B36C66A8BE
              DAECEFEFBF32F941FB5D5F5F31C7270720E66453F44D00CA540880009415500E
              CF154000CA0A28876F6405ECEEEEDEC02DE1ED3AB54A8F3AB6C531F07319D554
              368BE3AA8EE7F3F9569665039383906DD100ECEDED5D3A3838F889096683C1E0
              33927E5DB36298B1D4B53F1CD7EBF5B64C5ED0FE14ED87636CBF178BC55BE4FF
              3BCF1FCF0E8F30364A8902603A9DDE5A5D5D9D6759B67692757B8F00ED39407C
              8A31832800FAFDFEC718C92AFBBC8915F138740EC101E04A79193AC954FC6145
              3F0B9D4B700048F03E6A670BDEDBAE869C5C0C0055F9BD41479BEA14F99E2978
              79DD3CD32868680CC06834BA336A51C5CBCD3B93AE7843BE686A5FB6AD3100CB
              26D8753B0250264C0004A0AC807278AE80C8005CEE09C0A550E47E02882CB0CB
              3D01B8148ADCEF0D007B3DD67DFDC8F936E61E0F5C594530EBE709153695CDDE
              00E0C9B5978E21ED2F7812EE99660130AECF134C66956DCB00A874C60E7F0592
              04801DC76B78A933FE85DCB2EDFED2346391248066A69E46140250E6B00C00D7
              9EBEF294C284C79B6DD55DD00744B06980EEFAC51B806B4FBF7EE8882303B8AE
              BA0B42FB139B06BEA1BD01F806E078BB026D03F015575FCF56EDD34DAFB76D00
              D253509811010805949A13805441A13D010805949A13805441A13D010805949A
              13805441A17DDB005CC16EE8175B15EA716C6ED98A381E13E220208010E9387D
              5CC088EB8E8A6E79C19683F10319B9E7B2076F00B8FAACFBF465F7DD3BC3CA30
              FE07FE912EBE33F606E01B80E3ED0A10805D9FE8BD04105D627B8024014C2693
              EF487B237085BBFA05AFF5551FC8D477526364920030F905B69C7742D61A5A94
              86247B1704513AB51F5F52BDC609C0DCB36950C3456948922BA09461C74F0840
              193001080148CD0940AAA0D09E0084024ACD0940AAA0D09E0084024ACD0940AA
              A0D09E0084024ACD1B0370B45FDE96DFD80E317EC36EBFDFFF2615BD681F03C0
              DF6280AE1DAFAFAFBF0F39A718001E844C30315F7FB03282EE920607808DAAFC
              1BB366890917249DE170380AE2A8E0243880DC37208C71A518BFF028EF17571D
              071B98D38FD0A1A300C8931C0E87937CEB1649FFCACF5B5C5FE082CAB7E07762
              CC211A803CD9F178BC0D106BFF27904FC259733B53F5F1918F05FC6D931FB45B
              F7F373DB53F5A1C94FA8B6A8004225D9653F04A04C970008405901E5F05C0104
              A0AC807278AE0002282B70EA1EFCF8B9A13CCA7D866710E3FD3EDA8DCF076E8F
              714678AC8038099C77AF04A07C05100001282BA01C9E2B80009415500ECF1540
              00CA0A2887E70A2000650594C373053800C4EEFE070000FFFF1236D864000000
              064944415403004BCB12EE58CB725F0000000049454E44AE426082}
          end>
      end
      item
        Name = 'project'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000ED8494441547801EC9C09901C5519C7776637BB2C7B249BDD6C2E1313
              E48C0967A0A42C220A41103082075184221E584A8A201E850A8562C45B932268
              290AC69280F1C022C85116A0C1A20C15109220811842CC26D924BB9BEC91CDDE
              E3EFEBCCDBB3BBDFD73D3D333BD9D9EA6F5FCF7BDF7BDFF7FEFFD7DD5FBF7EDD
              F182FC5F5611C8139055F80B0AF204E409C8320259369F3F02F2046419812C9B
              CF1F017902B28C4096CDE7EC11B065CB96E283070FEE430E6CDBB6AD24CB3886
              369F930400FACBD3A74FEFA4D7B5480D7F1D870E1DDACA7ECE6D394500C0FF09
              4980F219C8902D91489C3224C3EFC7282ACB09029A9A9A7E9004FEEA51845D24
              AE8C6A0238ADDC28C0C762B1AF44D2DB51D8C8A82400D0DF8B705649FC621462
              16A94BA38A0046FC3B00BE8F1E3E838C896D5410D0D8D85809F0AD0CF9FF827A
              0C19335B560900F038C0BF158FC79B41BC1CB16ED469B32AE59042D60800F8F5
              9C727AC1EAED8875E342DCD3D7D73773E2C4891556E51C52C8380100FF0022B1
              FC055A9C00FF9C0913268CABAEAEDEA5AD932B7A19238058FEEB49E06F0800CE
              A2AAAAAA18E0BF14A04E4EA9A69D002EB0D708F08CE2EF6891E13CBFB40AE091
              47B57572552F6D04707E3F4780E702FBF05170ECFF21E9FB801EE33C7FAF5DFB
              D8D0889C80C3870F4F05FC2E46F1C600103D28C073AAB92D409D634235320276
              ECD8711CC037747575ED01FC714A74D60BF0C82795FAC79C5A240470817D95D1
              7B04E0AB95086D433F0EF0EF51EA1FB36A291100F08FC9799E73F71C25428D00
              5F0AF027C76231094595D58E5DB5500400FA0A240188976BA041AFB3A8A86832
              C0D7B0DFA1A93356740211D0DCDC7C93000F38CB10CD9600F8398CFAE32A2A2A
              F66B2A8C351D1501007FA900CF54C02A2D408CF48B19F171807F4D5B27553D7C
              BC7314C9F59AFEF812D0D0D0702A1D02F7BE27348D25759600BCDCBD3E9DFC9D
              C9E49B181B2DB21AEC12886FA0E14A00E1641517D8F6C2C24219BDAAE96146FC
              ED023CF21B40C86F0308FC1D127AEBEBEB670F640DEC8D2000E51708279B00B4
              7440CD7B0FDD36408F719E574F3578B776EC95247B142F292979136CF7247FF7
              27230800CCF328AD02D823A4D60DA2CA6938C111F30DABF2D85590A77CB3C176
              DA70084610200A281E623EE6784E41A7F25B15AF43C4722102515D7C68774C6C
              0CE405E05988BCE5D66157028C626565E5EB54643E2D7EA9C953A4CEC5E7C081
              03172A74C3AA64FA42FBEB108E3AC10803F939BFBABE04988AE3C78F7F0A2262
              30B1D4E4D952E2FF67391AFA20E2649B6ED0727CF95626A4A7A7E7278CE02FE1
              DFA711EDB61CDF62882A185111602C43C4BD342C51D14A9367496310F13A44B4
              D7D5D569E7892C4DA6BF18D08BF07917BEB7706A553D02456F8D6083DC11C4C3
              4004988631720B22443C66F22C696959595903E16D3D9DD3CE945A9A4C4F31C0
              FF1B3FBB69FD6D887503F87F09164481D75A955D14421160DAC1F095480C50FF
              63F2FC52F426D3B92E3AB9D94F2F1B6544718FE397041C672AEDEF02F422E47C
              A5BEAB5A4A049816B9D0BC13604B190D8D26CF92CE95CED2E9272C7A692FC68F
              FB109958BC4C69EC30036902036F26FD95551DCA6AEE6A9110204DCF9E3DBB83
              D150535C5C3C0DC7E410966C5F41CF996382BC8C2F4104F4BB1019F19FF17572
              A03041107212C09733E0641DD340490A7B9111607CE05CBF17228A0177BEC9B3
              A58C2867112E4744DA6FE620DBB1854FEA8B257DB908E0E30421B2728FAAD16D
              9113605C838417713AC64CDE6293674BE9A8B999BBCEA6EB5BEE5208B957C888
              876CF5D1863F374A1FE84BDAD6AAA68D0083417575F5EFA513743CC8E8FEAD80
              C53D44CA37738CF8B3A52DC05C677CB2A5E83AAB3300FE3E9B6EAAE56927C038
              C879F36E2182DFAA1B14F40A88C39D9BB9E6E6E693E4771061C4CF04F81E887F
              3140BD3F8A8F009FB1D5191923C08040079D5B747EFBDEA2536E36398DBD0198
              ED1031D1647AA58DC995D68CE29DE814229ACD395DE2DB4735CA51EA042280C3
              F92300210F190EEEDAB5AB341547E8EC02469A002440699A2AE57AD2887DD79B
              39467A11A37E37918A4428E59A06A9B377FBF6EDC5F8A20E18DCDAA59D38D8C8
              74B360B3CC4DC72B4F45406B6BEB69741C3B893F241B9A505E5EDE8ED1AD64CA
              1D71323B58C228EDA3F3B300763CED1C56D69E8CDD213773F8B689BC6EDA1B31
              DDEBD626B63A20AA9AD3E2B4F9F3E7AB4266B776240FDBCE2A6FDA340F5C9C05
              0BE4ABAE5FBE047011ACA0A13626A55CEF74317A0A1DEF63E43D25CE84152ED4
              2D80510E8027D286C4E624D6CDB999C33FD19F67D53EAA90E8EDED9D83AD5242
              CAA6A359E1FED3672750A0B6D72A6FB97EF5B4B7B74F47C773F324000333B908
              CAE15CE6593B590070970810C8AA6456A88453D2768E8838ED5D1CAA019F4A0C
              96CBA5ED9A9A1A79CCEAA3E95F441F9D1B387CD484CA859D9D9D750CD2B3BD5A
              F5248051F23F71184317795576C97796AD702194295C97625D16443C8D6D4CC7
              3EA7ABE1AD05F0CE4A6BFAF3B8B796BD04E0AF47E46853DFC0719ABB4EFA417F
              3C97D77B12605CA2F233D20868A8C1C0F08FC4D98686860F9976C2A4D8FEA5D8
              06C41F86A8FF53A90BF029ADB4E64C7081F405FBAB11ED76A7D8E634F73B5B05
              2B01A6813060F048F311719E4E9C6EDA099302E257A543D47D04B16D8F8A2E72
              AB4DD1AF9CD3C66C7CEF65E0ADF7D31B56B61ABB31E4AE61F99E3FD504981606
              81F167937734F5FE4F275EA1339DF5F5F5F26D076F454B091DBB1A91A8EB1517
              D54D52862C7229536771FA346F6CBE49252D3ECF6157800FF2F60FCD1714680D
              38CA83FF61F0C3488CBC9711CD565C5252225F37D92F5F3AD154F0D2C1EE99BB
              77EF2E81D8FD22B24FDE88EF4778D577CB5FBB766D2147EA4E4E9F1278A8EE23
              B0BD8333833C705FE0D6A6262F3401A6713A7E164EC8ECE73E93674927C9974E
              3822DC46B1A5EA40F1DCB973BBB03B5944F6074A82EF01FCF30B172EEC01D099
              CADAADDDDDDD15D83E813AB2E444596DA45ACA04489338D18D335338E74FE2B7
              7C4686C4BA9D0E0972E7F817AB669A1400FE41F101FFCFD79840AFB7A3A343D6
              F754D6D6D646F2BE72240418E72B2B2B1B38228E236AD1DE1849D5450202F263
              F99109C1D6B711790AF609AD3D06D7BB19644553A74E755DDFA36D67B85EA404
              98C6B9506F81087956FC4193A7486F1550883E3EAFD00DA542FB4B1089E56FD7
              36C035C189E5195CCF6BEB04D14B0B01C60188582744F0FB8B886AE3E8F99980
              4434F27E55058512532ACED75750BD1FD16EEA585EDBA09B5E5A093006216105
              224784FAA68891F72444F4B5B4B484FE121647937C7DA5972995204FB402C7F2
              A69F61D28C10601CE38870A60518E54F9A3C4B1A63F26C2B174B9979ADB2E8F6
              17A33F1EF2DAB023CF70B57D0C1DCBF71B0EB1A375AEBF693AB79491A506A3BF
              E2A01D88B82C7944A83EB447F4510A98986E925760E519C2A0D60676D19158BE
              0EFD43E45A2711D1294037E5585EDA917B1B70F9AEEC071135018CA80588440E
              F7D0D126F6EB483DC1D0380111A7B5B5B51D8FAE6A6A18B0E425F01E6CBF409D
              211B791B00406279DFE9DF41952289E5A53D6C6F927B1BF0B88D7D59AAFF71C9
              D78895002E60D2697968F18F610D4E970E63700418C3F47C7FCE9831E3084743
              35CF1C04B81E5FE581C273B19BC0FE43C8C3B24FD1798866EB8B2A96C7EE3A44
              A2AA21613703658DE473C8CEB539E449C0C68D1BC7D1C83E2E607B60B6C8A7A1
              7E307C74AC4593264DDA0311E370FE5CAB725201BF1623D7247F5A1389E5B151
              986A2C0F2E2B1101FE0A3FA3F4653324B413D1557AE97912208FEA8A8B8BB5CB
              F50A0062B138C5884CE955256E763602923C8857AF27F2EA9CC927A28A2496A7
              7FCB1001FE66D3B622FD983CF1F3D2F324402A949595BD2460C0A47AB5004438
              DF05C2D125D24658C1E930EB89869B8B249667145F497F04F815C30DF8FCBE59
              B0E33AE7BB82DC9700D338A3D2592F03B85F33798AF47E711AF17D4DD3D60E1D
              B85B3A82DE0388768B249607F879F89F600006F96ED14AF117B947E3AC8A00D3
              10607C8F86650AFA57264F91FABEA6A9A8EFA860F75388D81E1E0C38E5C97F91
              C4F2ADADADB500DF09F09B92ED6A12F320E8168DB2D1094480A904109F45048C
              674D9E258DF32C40D6CDB41055A9DE38F16A0FBB1772444AF8BBC3E8005424B1
              3C477809C01F202293A9F562D3BE25DD8C4FF23026D483A05004188730FC3E84
              FEC7B69B3C4B5A4154D5422777D0D9D0B63128EB894E903979110849795E9ED3
              CDAB0410F221911A4B1F4CF17EEC96D0FF941EB78606C17821298E9CD8D9D929
              4F915AE5B74266D1D95E8808F2BC7544B3B5CCC98B8C280890811F7FC50F39CF
              AB3EB903F9F2E5975A809FCC7E570053AEAA9110202D4F9932E5304E49BC3B0B
              C7B46F8E382B0E0020C80556CCA52C8CF855D8E5404C7C40DB18CAF3186CF2E5
              9703DA3A36BDC80830862061274E16E1ACD78A31A33A38BD41C06034EA96B00F
              AE19709F9B22E7B90383E4266D55FAE2BC0B4710B2455B47AB173901C630CEFE
              1332E442AD5E2940479D1734189D8B4D3B51A5107C1522AF190579F2A68AE553
              F1316D0418A720C189C9F9BD1C516D8CCE8704AC868606EDFC8E67BBB4731622
              3751EA653434162896473FF49676028C6710710702B6B13526CF963277B301F0
              BA214226EA6CEA43CA99659D425DB9487A2E0B1C52E1E88F50B1FCD1AAE1FE67
              8C00E31ED7876B85084E371B4C9E252D82883AC03C481DEB3B09E6F39984A77B
              69771CA2D9528AE53506BC74324E8071846BC4BB20436659EB4C9E259DC0455A
              9E8C79BE93C0B5E335DA3C0251DACF22EC4F2EEA4A2996B7F8ED5B9C3502C42B
              CE47BD1C0D33D897276CEDA4D60D7047BC9300F0F2FC586279F9BC8EB50DECF6
              C7F2A92EEAB21AB328649500E31B241C42CA38D5C80378B9609A22CF1410CD3B
              0902BC7A050504461ECB7B3AA928181504183F2B2B2BDF80087941E312931755
              0AF0698BE553F1715411603AC279FC6F1021CB58BE60F25248D31ECBA7E05BF8
              D5D1A918D5D6E542FD732102FD20374FA83B5BC66279C75AC87F018E80901622
              A806095F46E4AE5AB39037E3B17C2A5DCC09024C0721E12A4488707B5092B558
              DEF81726CD29024C0721E10C89DFF92DDFA3CE7A2C8F1FA1B79C24407A2BF13B
              44C817D927CBBEE4E5A2E42C01B908B69BCF7902DC50C9605E9E800C82ED662A
              4F801B2A19CCCB139041B0DD4CE509704325837979022C60A7BBF8FF000000FF
              FF623D8741000000064944415403001CE3F41BFDBC00E50000000049454E44AE
              426082}
          end>
      end
      item
        Name = 'npp'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              38000006F3494441547801EC9D5F681C451CC773976BAA34C95D128B68031AAB
              54102D882001FF157D10447C8B8220F82712B1FA601FDB82E21F7C2816FF130D
              28E893BE48115F0CB6A042D0874A152DA27D09166392CB5D62624D7277FDCC25
              976EF666F776F77667F66EA7CC2F33F39BDFCC6FE6FBBD99D99DEBEDA63BCC3F
              AD081802B4C2DFD161083004684640B3FB969B01737373F7E6F3F9B30B0B0B95
              058BA0FB8DFC01CD78FA76DF3204CCCECEEE03E04A6767E7642A95DA671F29BA
              1BD17D236C8AC5E20DA45B22B4040180FA61269339EB15D172B9FC7BA15018F7
              6AAFD32EF604B0B4BC07404F21BE42A552791AE2DEF655498371AC09989E9EEE
              676979A6095C0E4244AE89FA91578D3501DDDDDD7FBA207086A566389D4E0F63
              F333220D2C45E7A4053151C69A0030927E7A9915A37D7D7DFB070606A6B2D9EC
              14E95BD08D612F0B7D75CA1829624B80B8DC94E104D06BB95C6EC25E864E6CBA
              6B76BDC8B317DC23E2384A5304B0418E31B86DD7E361E5C5E5A60C30969D3764
              7AA163BD3F2E62899C0CAB5FF67658E24625FE3CAB0213404756F934BEEFD953
              7886D7B83475AD4B59244590FE0124FC1FB4F1400408F071B803511E20FD1127
              A7948D389545A98784AE4D4C7CBBF14D008E9EC38B16F0F15B0DF4A1504D58FE
              C874966215C91D2CC907FD3AF24D000EDE4274872C805798FA178488341DCA22
              5A0333D0F78D5F1002B40ED2EA9CA9BF538855D76AE9D008E05A3C9524098BE8
              D00808AB43496BC710A099718504681E694CDD1B02341363083004684640B37B
              33030C019A11D0ECDECC80A41120CE6DE22CAAF930334035E2367F86001B20AA
              B3868088116FD4BC21A0114211971B022206B851F3CA0988FB77068D000BBB5C
              3901610FA0D5DB33046866D0106008D08C8066F7660618023423A0D9BD990186
              80081068A126CD0CD04C9621206904C4F9CB18D137D57C9819A01A719B3F4380
              0D10D55943806AC46DFE0C011B802C133D268ECA893D05612B04E31790121228
              249A80743A7D54808874239F0441907AC7910C92A2FEF788AFA09C00D1D1B848
              369B7DC5175A0D8C19D71D0D4CEA8A951350D783842B422420E148061CBE2140
              02DCECECECD5DC941D424E2167903F0A85C28FC49FE6F3F907255502AB0C019B
              D001EEF348F5B10B994CE62FD4C790BB919B91BD954AE536E24753A9D4899A1D
              F12F907515FAC021F10400E2045201C13711BFE126C83A4FFDF5F9F9F941BF95
              857D6209585C5CAC3E830E109E449A0D9D5CD24E43C44F7E1B4A24010075AC54
              2A797E069D0F50F7D336AB5525E3B54EE20800A093807308892CB061AFCDCCCC
              5CE9C541A20800FCAF01C5EFC39B4E51A72624BD85AEAEAEBF990A3D8DAC1343
              00E01F018CFB105F81BBDB0335F155116366C222916B504E0040542FF5A2889D
              46BAB4B4B49BB29711E58171FEEBE65439016E9D69B2EC5DA7FAEBEBEBFF3895
              35ABF7507F1733C1E98182EDF3F4749609E9C392DC06EF01BC504CD80B1C1FED
              D62E3340DC4849C1721BBCB442444A3E08D293D7B62000908FCA70E3DC461C23
              C88A94EBE8E36199D3B620607272F275D9E038B7F942A6D7A52B168BFD76DFCA
              0960AD0EFDC95A2323234E5F095E671FB0CE7CB95C7ED1EE5F3901F60E242CFF
              AC7DBC6D4B40A15018B20F3606F93ABCEB1431E864285D60FD174F55776AAB76
              B4E025B6B6E1C5BE6663ADE7986E5B02586F1D0FC3D887B68E171AA5ADC835B2
              B5965BEBB9A5DB960066C04EB781C7A5AC3509F0801ED7DD331ECCB49BB42D01
              20EBF8ED1407649E0F0469672B04ADB7D58024D1B604B01E9F968C3776AAB625
              2076486F74E8F38DE8D2DFD008F0333DC3B6BD349CED29F681FFB66BF4E63299
              4C7BDE09AFACACEC9141CB80B5BCD041D617A1EBE9E9F955C4560932039EB036
              1087F4EAEA6ADD4B7D44BF7A7B7BBF14714CE484AC1FBE096073FB886BECC0EF
              4C9175A2591D4BCDFD2E6DBCE352A6AC08DC1E9239F34D80682497CB5D462C7D
              65147A2D81A3DEEB658E19B878E58AAC48A5EE6327678108108D31B02E3E79E2
              BB4EA7A36061A64C4AA592E3DBF4E8E79DCA3A227104568F4BD45555600244ED
              FEFEFE711AAFFE3A8438F4737E3F6DD297CB459F6442D97790F095AC2C6A1DA7
              B28EFD12BE7D1020CC5B5720E101F6AE399523E04070786868E8829BCFC41020
              4060EFDACD4C103FC813594F62BD67F15461D308F01F1E181898DACC3A468922
              40A0C04CE82616FFFF9F289A904EA76F07FCCFBCB49E38020428EC2D832C47AF
              8A74C85261967565B3D91FBCB69B48020438007504116F045C11F96605420F43
              6C9AD8D7E5796209108003D63AA0ED5A5E5EBE82FC3924487889365290F95A90
              CA8926A006D8E0E0E03C20EE45C48FAD6F85980936EBF3B5725BFC2DE563005E
              BBFCAE3B60B3D9BB660D01367820E134E08EB259EF212DBBB7B98BF2714808E5
              06D41060234075D610A01A719B3F43800D107B36EAFC45000000FFFF0FA0C8B7
              0000000649444154030014CF140CD4F2E1A50000000049454E44AE426082}
          end>
      end
      item
        Name = 'console'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D4948445200000060000000600806000000E29877
              3800000402494441547801EC9C4F6ED34014C6ED9445778D93660547801BC006
              56088A8A04152740DCA27F6E81380042154891022B6005378023C0862613BAAB
              14C57C23C591D38C9967BBE357B75F354F99CCBC7FF3FD3A492A45ED44FC5155
              800054E58F22022000650594CBF3061080B202CAE5790308405901E5F2BC0104
              A0AC8072F9EB79039445CF972780BC1A0A730250103D5F9200F26A28CC094041
              F47C4902C8ABA1302F05603299BC30C6CC6029CDB834988DC7E3BD321CC5008C
              3193388EDF22F9068CC3ADC046A7D379678C39716FAFAF8A002C1226EBE15C29
              50A03F9D4EFF14ECAD2C7B0140FCA788E8C3384A2890A6E936B47BE20BF10240
              826318470505F092FDDE1726017041AFF9BE56AEDE3E6EC10DDFA924009C3992
              248913DA5203A74882C5CA0004B9E92250800004228574218090EA0A72138040
              A4902E0410525D416E02108814D2850042AA2BC84D00029142BA10404875A328
              F2A527009F4281F70920B0C0BEF404E05328F03E010416D8979E007C0A05DE27
              80C002FBD213804FA1C0FB041058605F7A02F0291478BF1100C6982FB0EC8B4C
              23E99910D38A38E9795C7EC10140C4CF287C1F968D47D3E9F453F6A4E8B1565C
              143556AFA87FE97A700068E4016C65A469FA7065C1FDA42D71EEEE85AB4D0010
              B6723DDD9A00F0D521AD6BEDBC9BCBC7B5A61D77BE7EA9E7C1012449625F4A8E
              735D0D176BB9A5F5E9C2E7D2C7AD775E6E253800DB0EC4DC83655F62DAB56B12
              434C2BE2246729F26904405171AEF3DFD5A8FF0EF0062823200002505640B9FC
              05DE00E593B4B43C012883230002505640B93C6F0001282BA05C9E3780009415
              502ECF1B4000CA0A2897E70DA809A06E3801D455B0663C01D414B06E786500C6
              98EC8B567C841655414800CCAB26675C94FA34900078EE4BC2FD42059E15EE2C
              36BC009224F9005F03E328A7C078A1DD7FA3BC006C3412F5E2381EDB394DA4C0
              0934DB96788A00D844DD6E773B4DD31D8038B3CF694E05CEA0D163883F70EE3A
              16C5006C6CAFD71B01C4260A645FB2F23EDAB8365B99B3C277131A7D2C73DE52
              00CA24A6AF4C817602909DAD155E04A08C293800BC29DD533E63E5F2E8FD6EE5
              60616070007853FA8637277C788A5F097B527743B32F6DCFE8FD7BE8668203C8
              0E804F4FAFEDA1ACCDE7F32DAC1FC27EC1B487EDE1C0F6647BB3865EDF34D554
              6300F207EAF7FBA738E801EC166CF95176369BDDC4B5DF81EF3E6C88F94FD829
              E655C75F04FE800D61FBC8B5636BE46B626E7B38B43DC1A7F1A102A0E89483C1
              E0770F7F6B409423D82EE6B7615B982F21959C77E17F07B60B3B42AE91AD5154
              5F63FD5201D01040BB26012813200002505640B97C891BA0DCE9152D4F00CA60
              0980009415502ECF1B4000CA0A2897E70D2000650594CBF3061080B202CAE579
              033C00426FFF030000FFFF5A992CC0000000064944415403002D1D18EE356D7B
              880000000049454E44AE426082}
          end>
      end>
    Left = 344
    Top = 88
  end
  object VirtualImageListWhite: TVirtualImageList
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'Run'
        Name = 'Run'
      end
      item
        CollectionIndex = 1
        CollectionName = 'Compile'
        Name = 'Compile2'
      end
      item
        CollectionIndex = 2
        CollectionName = 'Upload'
        Name = 'Upload2'
      end
      item
        CollectionIndex = 3
        CollectionName = 'ShowLogs'
        Name = 'ShowLogs2'
      end
      item
        CollectionIndex = 4
        CollectionName = 'Clean'
        Name = 'Clean2'
      end
      item
        CollectionIndex = 5
        CollectionName = 'none'
        Name = 'none'
      end
      item
        CollectionIndex = 6
        CollectionName = 'question'
        Name = 'question'
      end
      item
        CollectionIndex = 7
        CollectionName = 'serial'
        Name = 'serial'
      end
      item
        CollectionIndex = 8
        CollectionName = 'wifi'
        Name = 'wifi'
      end
      item
        CollectionIndex = 9
        CollectionName = 'wifi-disabled'
        Name = 'wifi-disabled'
      end
      item
        CollectionIndex = 10
        CollectionName = 'wifi-offline'
        Name = 'wifi-offline'
      end
      item
        CollectionIndex = 11
        CollectionName = 'esphome'
        Name = 'esphome'
      end
      item
        CollectionIndex = 12
        CollectionName = 'project'
        Name = 'project'
      end
      item
        CollectionIndex = 13
        CollectionName = 'npp'
        Name = 'npp'
      end
      item
        CollectionIndex = 14
        CollectionName = 'console'
        Name = 'console'
      end>
    ImageCollection = ImageCollectionWhite
    Left = 200
    Top = 88
  end
end
