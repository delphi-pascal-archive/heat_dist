object fmAbout: TfmAbout
  Left = 207
  Top = 202
  BorderStyle = bsDialog
  Caption = 'О программе Расчет распределения температур'
  ClientHeight = 98
  ClientWidth = 334
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object imgMain: TImage
    Left = 10
    Top = 8
    Width = 32
    Height = 32
  end
  object laProgramName: TLabel
    Left = 54
    Top = 8
    Width = 83
    Height = 13
    Caption = 'HeatDist v1.0.0.0'
  end
  object laCopyright: TLabel
    Left = 54
    Top = 24
    Width = 270
    Height = 13
    Caption = 'Copyright © 2006 Loonies Software. All Rights Reserved.'
  end
  object laWebSiteAddress: TLabel
    Left = 54
    Top = 40
    Width = 133
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://www.loonies.narod.ru'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = laWebSiteAddressClick
  end
  object btOk: TButton
    Left = 130
    Top = 66
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
end
