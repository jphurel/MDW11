object FEdRacc: TFEdRacc
  Left = 0
  Top = 0
  Caption = 'Editer un raccourci'
  ClientHeight = 156
  ClientWidth = 524
  Color = clBtnFace
  Constraints.MinHeight = 195
  Constraints.MinWidth = 450
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
    Width = 524
    Height = 156
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 549
    ExplicitHeight = 102
    DesignSize = (
      524
      156)
    object Label1: TLabel
      Left = 12
      Top = 14
      Width = 135
      Height = 15
      Caption = 'Chemin de l'#39'application :'
    end
    object Label3: TLabel
      Left = 12
      Top = 74
      Width = 116
      Height = 15
      Caption = 'R'#233'pertoire de travail :'
    end
    object Label2: TLabel
      Left = 12
      Top = 104
      Width = 72
      Height = 15
      Caption = 'Nom affich'#233' :'
    end
    object Label4: TLabel
      Left = 12
      Top = 44
      Width = 71
      Height = 15
      Caption = 'Param'#232'tres :'
    end
    object PnBtns: TPanel
      Left = 0
      Top = 131
      Width = 524
      Height = 25
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitTop = 77
      ExplicitWidth = 549
      object BbAnn: TBitBtn
        Left = 449
        Top = 0
        Width = 75
        Height = 25
        Align = alRight
        Kind = bkCancel
        NumGlyphs = 2
        TabOrder = 0
        ExplicitLeft = 474
      end
      object BbOK: TBitBtn
        Left = 374
        Top = 0
        Width = 75
        Height = 25
        Align = alRight
        Kind = bkOK
        NumGlyphs = 2
        TabOrder = 1
        ExplicitLeft = 399
      end
    end
    object EdPath: TEdit
      Left = 150
      Top = 10
      Width = 287
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
      ExplicitWidth = 309
    end
    object EdNom: TEdit
      Left = 150
      Top = 100
      Width = 362
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      ExplicitWidth = 384
    end
    object BtRechercher: TButton
      Left = 443
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Rechercher'
      TabOrder = 3
      OnClick = BtRechercherClick
      ExplicitLeft = 468
    end
    object EdDir: TEdit
      Left = 150
      Top = 70
      Width = 362
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      ExplicitWidth = 384
    end
    object EdParams: TEdit
      Left = 150
      Top = 39
      Width = 362
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 5
      ExplicitWidth = 384
    end
  end
  object OD: TFileOpenDialog
    DefaultFolder = 'C:\Program Files'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'raccourcis'
        FileMask = '*.lnk'
      end
      item
        DisplayName = 'tous les fichiers'
        FileMask = '*.*'
      end>
    Options = [fdoPathMustExist, fdoFileMustExist, fdoDontAddToRecent]
    Left = 450
    Top = 50
  end
end
