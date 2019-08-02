unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ParseExpr, Vcl.Buttons, Vcl.ExtCtrls;

type
  TfmMain = class(TForm)
    edEQ: TEdit;
    stResult: TStaticText;
    Splitter: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edEQChange(Sender: TObject);
    procedure edEQKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure stResultMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    EP: TExpressionParser;
    ExpIndex: Integer;
    Exp: TStrings;
    LastResult: Int64;
    function CalcThis: boolean;
    function GetResultStr(aValue: real): string;
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  StrUtils;

{$R *.dfm}

function TfmMain.CalcThis: boolean;
begin
  try
    EP.ClearExpressions;
    if (FormatSettings.DecimalSeparator = ',') then
      EP.AddExpression(ReplaceStr(edEQ.Text, '.', ','))
    else
      EP.AddExpression(ReplaceStr(edEQ.Text, ',', '.'));
    LastResult := Round(EP.AsFloat[0] * 100);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  EP := TExpressionParser.Create;
  Exp := TStringList.Create;
  ExpIndex := - 1;
  OnMouseWheel := FormMouseWheel;
  { TODO : „тение полседнего расположени€ и размеров }
  {
  ѕрочитать данные о последнем положении и размере из реестра.
  ≈сли прочитались, то применить к форме.
  ≈сли впервые запускаетс€, то сделать ширину окна Width * 15 и расположить по центру
 }
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  EP.Free;
  Exp.Free;
  { TODO : —охранение размеров и положени€ }
end;

procedure TfmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  function Min(Val1, Val2: Integer): Integer;
  begin
    if Val1 < Val2 then
      Result := Val1
    else
      Result := Val2
  end;
  function Max(Val1, Val2: Integer): Integer;
  begin
    if Val1 > Val2 then
      Result := Val1
    else
      Result := Val2
  end;

begin
  if WheelDelta > 0 then
    Width := Min(Width + Height, Screen.Width)
  else
    Width := Max(Width - Height, Height * 15);
end;

function TfmMain.GetResultStr(aValue: real): string;
var
  i: Integer;

begin
  Result := Format('%0.2f', [aValue]);
  i := Length(Result);
  while i > 0 do
  begin
    if Result[i] <> '0' then
      Break;
    Dec(i);
  end;
  Result := Copy(Result, 1, i);
  i := Length(Result);
  if (i > 0) and (CharInSet(Result[i], [',', '.'])) then
    Result := Copy(Result, 1, i - 1);
end;

procedure TfmMain.edEQChange(Sender: TObject);
begin
  if CalcThis then
  begin
    stResult.Font.Color := clYellow;
    stResult.Caption := GetResultStr(LastResult / 100);
  end
  else
  begin
    if Length(Trim(edEQ.Text)) > 0 then
    begin
      stResult.Font.Color := clRed;
      stResult.Caption := 'ERROR';
    end
    else
      stResult.Caption := '';
  end;
end;

procedure TfmMain.edEQKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  SUM, PDV: Int64;
begin
  if (Key = VK_RETURN) then
  begin
    if CalcThis then
    begin
      if (Exp.IndexOf(edEQ.Text) < 0) then
      begin
        Exp.Add(edEQ.Text);
        ExpIndex := Exp.Count - 1;
      end;
      if (ssShift in Shift) then
      begin
        PDV := Round(LastResult / 6);
        SUM := LastResult - PDV;
        edEQ.Text := GetResultStr(SUM / 100) + '+' + GetResultStr(PDV / 100);
      end
      else
        edEQ.Text := GetResultStr(LastResult / 100);
      edEQ.SelectAll;
    end;
  end
  else if (Key = VK_ESCAPE) then
  begin
    Key := 0;
    edEQ.Text := '';
    stResult.Caption := '';
  end
  else if (Key = VK_UP) then
  begin
    Key := 0;
    { TODO : ѕрокрутить список последних выражений на шаг назад }
  end
  else if (Key = VK_DOWN) then
  begin
    Key := 0;
    { TODO : ѕрокрутить список последних выражений на шаг вперед }
  end;
end;

procedure TfmMain.stResultMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not (ssCtrl in Shift) then
  begin
    ReleaseCapture;
    SendMessage(fmMain.Handle, WM_SYSCOMMAND, 61458, 0);
  end
  else
    Close;
end;

end.
