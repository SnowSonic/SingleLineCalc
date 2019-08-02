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
    EPIndex: Integer;
    LastResult: Int64;
    CalcDigits: Integer;
    CalcDozens: Int64;
    // Расчет с указанием, записывать ли расчет в историю
    function CalcThis(aStore: boolean = True): boolean;
    // Отформатировать результат в формат текущего округления
    function GetResultStr(aValue: real): string;
    // Обработчик колеса мышки
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  StrUtils, Math;

// По умолчанию укругление до 2-х знаков после запятой
const
  ciCalcDigits = 2;


{$R *.dfm}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  // Если есть параметр запуска, то надеюсь что это задано сколько символов после запятой
  if ParamCount > 0 then
    CalcDigits := StrToIntDef(ParamStr(1), ciCalcDigits)
  else
    CalcDigits := ciCalcDigits;
  // Сразу расчет сколько десятков для округления и деления
  CalcDozens := Round(Power(10, CalcDigits));
  // Создание расчетчика
  EP := TExpressionParser.Create;
  EPIndex := - 1;
  // пришиваем обработчик колеса мыши
  OnMouseWheel := FormMouseWheel;

  { TODO : Чтение последнего расположения и размеров }
  {
  Прочитать данные о последнем положении и размере из реестра.
  Если прочитались, то применить к форме.
  Если впервые запускается, то сделать ширину окна Width * 15 и расположить по центру
  }
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  // Освобождаем ресурсы
  EP.Free;
  { TODO : Сохранение размеров и положения }
end;

procedure TfmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
begin
  // Размер калькулятора минимум 15 высот и максимум ширина экрана
  if WheelDelta < 0 then
    Width := Max(Width - Height, Height * 15)
  else
    Width := Min(Width + Height, Screen.Width);
end;

function TfmMain.CalcThis(aStore: boolean): boolean;
begin
  try
    // Что бы не считать
    EP.ClearExpressions;
    if (FormatSettings.DecimalSeparator = ',') then
      EP.AddExpression(ReplaceStr(edEQ.Text, '.', ','))
    else
      EP.AddExpression(ReplaceStr(edEQ.Text, ',', '.'));
    LastResult := Round(EP.AsFloat[0] * CalcDozens);
    Result := True;
  except
    Result := False;
  end;
end;

function TfmMain.GetResultStr(aValue: real): string;
var
  i: Integer;

begin
  Result := Format('%0.'+CalcDigits.toString+'f', [aValue]);
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
  if CalcThis(False) then
    stResult.Caption := GetResultStr(LastResult / CalcDozens);
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
        EPIndex := Exp.Count - 1;
      end;
      if (ssShift in Shift) then
      begin
        PDV := Round(LastResult / 6);
        SUM := LastResult - PDV;
        edEQ.Text := GetResultStr(SUM / CalcDozens) + '+' + GetResultStr(PDV / CalcDozens);
      end
      else
        edEQ.Text := GetResultStr(LastResult / CalcDozens);
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
    { TODO : Прокрутить список последних выражений на шаг назад }
  end
  else if (Key = VK_DOWN) then
  begin
    Key := 0;
    { TODO : Прокрутить список последних выражений на шаг вперед }
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
