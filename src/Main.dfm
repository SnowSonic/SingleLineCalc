object fmMain: TfmMain
  Left = 0
  Top = 0
  Margins.Left = 2
  Margins.Top = 2
  Margins.Right = 2
  Margins.Bottom = 2
  BorderIcons = []
  BorderStyle = bsNone
  Caption = #1050#1072#1083#1100#1082#1091#1083#1103#1090#1086#1088
  ClientHeight = 26
  ClientWidth = 390
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poDesigned
  ScreenSnap = True
  SnapBuffer = 3
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object Splitter: TSplitter
    Left = 285
    Top = 0
    Width = 5
    Height = 26
    Align = alRight
    Color = clRed
    ParentColor = False
  end
  object Image: TImage
    Left = 0
    Top = 0
    Width = 25
    Height = 26
    Hint = #1047#1072#1082#1088#1099#1090#1100' '#1082#1072#1083#1100#1082#1091#1083#1103#1090#1086#1088' (Alt+F4)'
    Align = alLeft
    Center = True
    ParentShowHint = False
    Picture.Data = {
      0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000
      001008060000001FF3FF61000000604944415478DA636480823FD7FBFE339000
      58348B18413423399A910D612457330C601800321597A1D8E4500460FEC2E62D
      5C728CC428C4673056E7226B4006D8D4E2F52F21CDB43380222F501488548B46
      B213123980F2CC842F84096906D1002FAF789133E69E790000000049454E44AE
      426082}
    ShowHint = True
    Transparent = True
    OnClick = ImageClick
  end
  object edEQ: TEdit
    Left = 25
    Top = 0
    Width = 260
    Height = 26
    Align = alClient
    AutoSize = False
    BorderStyle = bsNone
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = edEQChange
    OnKeyDown = edEQKeyDown
  end
  object stResult: TStaticText
    Left = 290
    Top = 0
    Width = 100
    Height = 26
    Hint = #1057#1080#1085#1077#1077' '#1087#1086#1083#1077' - '#1088#1077#1079#1091#1083#1100#1090#1072#1090'.'#13#1047#1072' '#1085#1077#1075#1086' '#1084#1086#1078#1085#1086' '#1087#1077#1088#1077#1084#1077#1097#1072#1090#1100
    Align = alRight
    Alignment = taCenter
    AutoSize = False
    Color = clBlue
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    Transparent = False
    OnMouseDown = stResultMouseDown
  end
end
