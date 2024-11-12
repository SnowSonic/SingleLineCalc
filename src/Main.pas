﻿unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  ParseExpr;

type
  TfmMain = class(TForm)
    edEQ: TEdit;
    stResult: TStaticText;
    Splitter: TSplitter;
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edEQChange(Sender: TObject);
    procedure edEQKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ImageClick(Sender: TObject);
    procedure stResultMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    EP: TExpressionParser;
    CalcDigits: Integer;
    CalcDozens: Int64;
    EPLast: Integer; // Кол-во выражений
    EPIndex: Integer; // Текущее выражение
    Selected: boolean;
    LastResult: Int64;
    // Расчет с указанием, записывать ли расчет в историю
    function CalcThis(aStore: boolean = True): boolean;
    // Отформатировать результат в формат текущего округления
    function FormatResult(aValue: real; withZero: boolean = False): string;
    // Обработчик колеса мышки
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  public
  end;

var
  fmMain: TfmMain;

implementation

uses
  System.StrUtils, System.Math, pm.VCLUtils;

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
  // Последний в списке
  EPLast := - 1;
  // Индекс для переключения в списке по стрелкам
  EPIndex := - 1;
  // пришиваем обработчик колеса мыши
  OnMouseWheel := FormMouseWheel;
  // Загрузить иконку приложения в картинку
  Image.Width := Image.Height;
  //
  Selected := False;
end;

procedure TfmMain.FormShow(Sender: TObject);
begin
  LoadStateRegistry('SimpleCalc');
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  SaveStateRegistry('SimpleCalc');
  // Освобождаем ресурсы
  EP.Free;
end;

procedure TfmMain.edEQChange(Sender: TObject);
begin
  Selected := False;
  if CalcThis(False) then
    stResult.Caption := FormatResult(LastResult / CalcDozens);
end;

procedure TfmMain.edEQKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ADD, VK_SUBTRACT, VK_MULTIPLY, VK_DIVIDE:
      if Selected then
      begin
        edEQ.SetFocus;
        edEQ.SelStart := 999999;
      end;
    VK_RETURN:
      begin
        Key := 0;
        if CalcThis then
        begin
          if (ssShift in Shift) then
          begin
            var PDV: Int64 := Round(LastResult / 6);
            var SUM: Int64 := LastResult - PDV;
            edEQ.Text := FormatResult(SUM / CalcDozens, True) + '+' + FormatResult(PDV / CalcDozens, True);
          end
          else
            edEQ.Text := FormatResult(LastResult / CalcDozens);
          edEQ.SelectAll;
          Selected := True;
        end;
      end;
    VK_ESCAPE:
      begin
        Key := 0;
        edEQ.Text := '';
        stResult.Caption := '';
      end;
  end;
end;

procedure TfmMain.ImageClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.stResultMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(fmMain.Handle, WM_SYSCOMMAND, 61458, 0);
end;

function TfmMain.CalcThis(aStore: boolean): boolean;
var
  Exp: string;
begin
  try
    { DONE : Сделать обработку aStore. Сохранять или нет расчет в списке. }
    // Заменить запятые на точки или на оборот, если другой разделитель десятичных и посчитать выражение
    if (FormatSettings.DecimalSeparator = ',') then
      Exp := ReplaceStr(edEQ.Text, '.', ',')
    else
      Exp := ReplaceStr(edEQ.Text, ',', '.');
    // Сделать расчет
    if aStore then
    begin
      // Если с сохранением, до добавляем
      EPLast := EP.AddExpression(Exp);
      LastResult := Round(EP.AsFloat[EPLast] * CalcDozens);
    end
    else
      // Если без сохранения, то просто расчет
      LastResult := Round(EP.Evaluate(Exp) * CalcDozens);
    // Последний результат окрулить до указанных знаков после запятой
    Result := True;
  except
    Result := False;
  end;
end;

function TfmMain.FormatResult(aValue: real; withZero: boolean = False): string;
var
  i: Integer;
begin
  Result := Format('%0.' + CalcDigits.toString + 'f', [aValue]);
  if not withZero then
  begin
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
end;

procedure TfmMain.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
begin
  // Размер калькулятора минимум 15 высот и максимум ширина экрана
  if WheelDelta < 0 then
    Width := Max(Width - Height, Height * 15)
  else
    Width := Min(Width + Height, Screen.Width);
end;

end.
