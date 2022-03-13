object FMDW11: TFMDW11
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  ClientHeight = 338
  ClientWidth = 445
  Color = clBlack
  CustomTitleBar.ShowCaption = False
  CustomTitleBar.ShowIcon = False
  CustomTitleBar.SystemButtons = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Calibri'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Scaled = False
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object PBx: TPaintBox
    Left = 0
    Top = 0
    Width = 445
    Height = 338
    Align = alClient
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -13
    Font.Name = 'Calibri'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    OnDragDrop = PBxDragDrop
    OnDragOver = PBxDragOver
    OnMouseDown = PBxMouseDown
    OnMouseEnter = PBxMouseEnter
    OnMouseLeave = PBxMouseLeave
    OnMouseMove = PBxMouseMove
    OnMouseUp = PBxMouseUp
    OnPaint = PBxPaint
    OnStartDrag = PBxStartDrag
    ExplicitLeft = 316
    ExplicitTop = 76
    ExplicitWidth = 105
    ExplicitHeight = 105
  end
  object PPm: TPopupMenu
    AutoHotkeys = maManual
    AutoLineReduction = maManual
    AutoPopup = False
    OnPopup = PPmPopup
    Left = 236
    Top = 42
    object MiAjouterungroupe: TMenuItem
      Caption = 'Ajouter un groupe'
      OnClick = MiAjouterungroupeClick
    end
    object MiAjouterunraccourci: TMenuItem
      Caption = 'Ajouter un raccourci'
      OnClick = MiAjouterunraccourciClick
    end
    object MiAjouterunutilitaireWindows: TMenuItem
      Caption = 'Ajouter un utilitaire Windows'
      object MiEditeurduregistre: TMenuItem
        Tag = 1
        Caption = #233'diteur du registre'
        OnClick = MiUtilitaireWindowsClick
      end
      object MiInviteDeCommande: TMenuItem
        Tag = 2
        Caption = 'invite de commande'
        OnClick = MiUtilitaireWindowsClick
      end
      object MiBlocnote: TMenuItem
        Tag = 3
        Caption = 'bloc-note'
        OnClick = MiUtilitaireWindowsClick
      end
      object MiCalculette: TMenuItem
        Tag = 4
        Caption = 'calculette'
        OnClick = MiUtilitaireWindowsClick
      end
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object MiColler: TMenuItem
      Caption = 'Coller'
      OnClick = MiCollerClick
    end
    object MiEditer: TMenuItem
      Caption = 'Editer'
      OnClick = MiEditerClick
    end
    object MiRetirer: TMenuItem
      Caption = 'Retirer'
      OnClick = MiRetirerClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MiParametres: TMenuItem
      Caption = 'Param'#232'tres'
      OnClick = MiParametresClick
    end
    object importexport: TMenuItem
      Caption = 'import/export'
      object MiExporterVersLePressePapier: TMenuItem
        Caption = 'exporter vers le presse-papier'
        OnClick = MiExporterVersLePressePapierClick
      end
      object MiImporterDepuisLePressePapier: TMenuItem
        Caption = 'importer depuis le presse-papier'
        OnClick = MiImporterDepuisLePressePapierClick
      end
    end
    object MiAide: TMenuItem
      Caption = 'Aide'
      OnClick = MiAideClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MiQuitter: TMenuItem
      Caption = 'Quitter'
      OnClick = MiQuitterClick
    end
  end
  object TimDrag: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimDragTimer
    Left = 358
    Top = 66
  end
end
