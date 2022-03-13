object FMDW11PRMS: TFMDW11PRMS
  Left = 0
  Top = 0
  Caption = 'Param'#232'tres de l'#39'application'
  ClientHeight = 178
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 15
  object PnFen: TPanel
    Left = 0
    Top = 0
    Width = 441
    Height = 178
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Label2: TLabel
      Left = 8
      Top = 10
      Width = 151
      Height = 15
      Caption = 'Nombre d'#39'icones par ligne :'
    end
    object Label1: TLabel
      Left = 8
      Top = 40
      Width = 387
      Height = 15
      Caption = 
        'Marge entre icones (pixels) : - horizontale :                   ' +
        '              - verticale :'
    end
    object EdNbIco: TEdit
      Left = 168
      Top = 6
      Width = 31
      Height = 23
      TabOrder = 0
    end
    object BtCoulFond: TButton
      Left = 8
      Top = 70
      Width = 200
      Height = 25
      Caption = 'Couleur du fond'
      TabOrder = 1
      OnClick = BtCoulFondClick
    end
    object BtPolice: TButton
      Left = 8
      Top = 100
      Width = 200
      Height = 25
      Caption = 'Police'
      TabOrder = 2
      OnClick = BtPoliceClick
    end
    object PnBtns: TPanel
      Left = 0
      Top = 153
      Width = 441
      Height = 25
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 3
      object BbAnn: TBitBtn
        Left = 366
        Top = 0
        Width = 75
        Height = 25
        Align = alRight
        Kind = bkCancel
        NumGlyphs = 2
        TabOrder = 0
      end
      object BbOK: TBitBtn
        Left = 291
        Top = 0
        Width = 75
        Height = 25
        Align = alRight
        Kind = bkOK
        NumGlyphs = 2
        TabOrder = 1
      end
      object BtDesinstaller: TButton
        Left = 0
        Top = 0
        Width = 87
        Height = 25
        Align = alLeft
        Caption = 'D'#233'sinstaller'
        TabOrder = 2
        OnClick = BtDesinstallerClick
      end
    end
    object EdMrgVert: TEdit
      Left = 398
      Top = 36
      Width = 31
      Height = 23
      TabOrder = 4
    end
    object EdMrgHoriz: TEdit
      Left = 246
      Top = 36
      Width = 31
      Height = 23
      TabOrder = 5
    end
  end
  object CD: TColorDialog
    Options = [cdFullOpen, cdSolidColor, cdAnyColor]
    Left = 336
    Top = 48
  end
  object FD: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [fdEffects, fdWysiwyg]
    Left = 266
    Top = 92
  end
end
