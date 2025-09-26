object FormTemplates: TFormTemplates
  Left = 0
  Top = 0
  Caption = 'FormTemplates'
  ClientHeight = 529
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    329
    529)
  TextHeight = 15
  object ListBox1: TListBox
    Left = 8
    Top = 96
    Width = 313
    Height = 425
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clAntiquewhite
    ItemHeight = 15
    TabOrder = 0
    ExplicitWidth = 309
    ExplicitHeight = 416
  end
  object Button1: TButton
    Left = 112
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
end
