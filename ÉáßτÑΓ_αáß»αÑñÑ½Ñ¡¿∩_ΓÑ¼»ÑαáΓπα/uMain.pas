unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ImgList, ActnList, ToolWin, ComCtrls, ExtCtrls, StdCtrls, Mask, Math,
  NewImage;

type
  TCellType = (ctMedium, ctLaggingNormalLeft, ctLaggingNormalUp, ctLaggingNormalRight, ctLaggingNormalDown, ctHeatSource1, ctHeatSource2, ctNotUsed);
  TValuesArr = array [0..31, 0..31] of Single;

  TfmMain = class(TForm)
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    ilMain: TImageList;
    alMain: TActionList;
    cbrMain: TCoolBar;
    tbMain: TToolBar;
    tbtStart: TToolButton;
    tbtPause: TToolButton;
    tbtStop: TToolButton;
    pnMain: TPanel;
    laSpeed: TLabel;
    trbSpeed: TTrackBar;
    stbMain: TStatusBar;
    actStart: TAction;
    actPause: TAction;
    actStop: TAction;
    miRun: TMenuItem;
    miStart: TMenuItem;
    miPause: TMenuItem;
    miStop: TMenuItem;
    pnParameters: TPanel;
    pnParametersHeader: TPanel;
    Splitter1: TSplitter;
    scbMain: TScrollBox;
    imgMain: TNewImage;
    pcMain: TPageControl;
    tsTab1: TTabSheet;
    tsTab2: TTabSheet;
    laMediumT: TLabel;
    meMediumT: TMaskEdit;
    laHeatSource1T: TLabel;
    meHeatSource1T: TMaskEdit;
    laHeatSource2T: TLabel;
    meHeatSource2T: TMaskEdit;
    laMuParam: TLabel;
    meMuParam: TMaskEdit;
    laAParam: TLabel;
    meAParam: TMaskEdit;
    laXCoord: TLabel;
    meXCoord: TMaskEdit;
    meYCoord: TMaskEdit;
    laYCoord: TLabel;
    laChainsCount: TLabel;
    meChainsCount: TMaskEdit;
    imgLegend: TImage;
    laMinT: TLabel;
    laMaxT: TLabel;
    procedure miExitClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure stbMainResize(Sender: TObject);
    procedure Delay;
    procedure SetStatusOnStop;
    procedure SimulationLoop;
    procedure actStartExecute(Sender: TObject);
    procedure actPauseExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
    procedure ChangeParam(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SetControlsEnabled(bEnabled: boolean);
    procedure imgMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgMainMouseLeave(Sender: TObject);
  private
  public
  end;

var
  fmMain: TfmMain;

  Tags: array [0..31, 0..31] of TCellType;

  A, B: TValuesArr;

  MediumT, HeatSource1T, HeatSource2T: Single;
  MinT, MaxT, DeltaT: Single;

  MuParam, AParam: Single;

  CurTime: DWORD;

  bRunning: boolean = false;
  bStopped: boolean = true;

  MMKRes: Single;
  bMMKInMedium: boolean;
  XCoord, YCoord: Integer;

implementation

{$R *.DFM}

uses
  uAbout;

const
  sCurTimeName='Âðåìÿ: %d';
  sCellTName='T(%d,%d): %.2f';
  sMMKStr='(%d,%d) ÌÌÊ: %.2f ÊÐÓ: %.2f';

function ProcessMaskEditString(const sIn: String): String;
var
  i: Integer;
begin
  Result:='0';
  for i:=1 to Length(sIn) do
    if sIn[i] <> ' ' then
      Result:=Result + sIn[i];

  i:=1;
  while (i <= Length(Result) - 1) and (Result[i]='0') do
    Inc(i);
  Delete(Result, 1, i - 1);
end;

function GetColorByTValue(T: Single): TColor;
var
  it: Integer;
begin
  it:=Round((T - MinT) / DeltaT);
  if it < 0 then
    it:=0
  else
    if it > 255 then
      it:=255;
  Result:=RGB(it, 0, 255-it);
end;

procedure FillMediumCells;
var
  i, j: Integer;
begin
  for i:=0 to 31 do
    for j:=0 to 31 do
      if Tags[i, j] = ctMedium then
        A[i, j]:=MediumT;
end;

procedure FillHeatSource1Cells;
var
  i, j: Integer;
begin
  for i:=0 to 31 do
    for j:=0 to 31 do
      if Tags[i, j] = ctHeatSource1 then
        A[i, j]:=HeatSource1T;
end;

procedure FillHeatSource2Cells;
var
  i, j: Integer;
begin
  for i:=0 to 31 do
    for j:=0 to 31 do
      if Tags[i, j] = ctHeatSource2 then
        A[i, j]:=HeatSource2T;
end;

procedure RefreshLagging;
var
  i, j: Integer;
begin
  for i:=0 to 31 do
    for j:=0 to 31 do
      case Tags[i, j] of
        ctLaggingNormalLeft:
          A[i, j]:=A[i, j-1];
        ctLaggingNormalUp:
          A[i, j]:=A[i-1, j];
        ctLaggingNormalRight:
          A[i, j]:=A[i, j+1];
        ctLaggingNormalDown:
          A[i, j]:=A[i+1, j];
      end;
end;

procedure DrawField(Image: TImage);
var
  Bitmap: TBitmap;
  R: TRect;
  i, j: Integer;

  procedure DrawSolidCell(Color: TColor);
  begin
    Bitmap.Canvas.Brush.Color:=Color;
    R.TopLeft.x:=2*j;
    R.TopLeft.y:=2*i;
    R.BottomRight.x:=R.TopLeft.x+2;
    R.BottomRight.y:=R.TopLeft.y+2;
    Bitmap.Canvas.FillRect(R);
  end;

begin
  Bitmap:=TBitmap.Create;
  try
    Bitmap.Width:=64;
    Bitmap.Height:=64;

    for i:=0 to 31 do
      for j:=0 to 31 do
        case Tags[i, j] of
          ctMedium:
            DrawSolidCell(GetColorByTValue(A[i, j]));
          ctLaggingNormalLeft:
            begin
              Bitmap.Canvas.Brush.Color:=clBlack;
              R.TopLeft.x:=2*j+1;
              R.TopLeft.y:=2*i;
              R.BottomRight.x:=R.TopLeft.x+1;
              R.BottomRight.y:=R.TopLeft.y+2;
              Bitmap.Canvas.FillRect(R);

              Bitmap.Canvas.Brush.Color:=GetColorByTValue(A[i, j]);
              R.TopLeft.x:=2*j;
              R.TopLeft.y:=2*i;
              R.BottomRight.x:=R.TopLeft.x+1;
              R.BottomRight.y:=R.TopLeft.y+2;
              Bitmap.Canvas.FillRect(R);
            end;
          ctLaggingNormalUp:
            begin
              Bitmap.Canvas.Brush.Color:=clBlack;
              R.TopLeft.x:=2*j;
              R.TopLeft.y:=2*i+1;
              R.BottomRight.x:=R.TopLeft.x+2;
              R.BottomRight.y:=R.TopLeft.y+1;
              Bitmap.Canvas.FillRect(R);

              Bitmap.Canvas.Brush.Color:=GetColorByTValue(A[i, j]);
              R.TopLeft.x:=2*j;
              R.TopLeft.y:=2*i;
              R.BottomRight.x:=R.TopLeft.x+2;
              R.BottomRight.y:=R.TopLeft.y+1;
              Bitmap.Canvas.FillRect(R);
            end;
          ctLaggingNormalRight:
            begin
              Bitmap.Canvas.Brush.Color:=clBlack;
              R.TopLeft.x:=2*j;
              R.TopLeft.y:=2*i;
              R.BottomRight.x:=R.TopLeft.x+1;
              R.BottomRight.y:=R.TopLeft.y+2;
              Bitmap.Canvas.FillRect(R);

              Bitmap.Canvas.Brush.Color:=GetColorByTValue(A[i, j]);
              R.TopLeft.x:=2*j+1;
              R.TopLeft.y:=2*i;
              R.BottomRight.x:=R.TopLeft.x+1;
              R.BottomRight.y:=R.TopLeft.y+2;
              Bitmap.Canvas.FillRect(R);
            end;
          ctLaggingNormalDown:
            begin
              Bitmap.Canvas.Brush.Color:=clBlack;
              R.TopLeft.x:=2*j;
              R.TopLeft.y:=2*i;
              R.BottomRight.x:=R.TopLeft.x+2;
              R.BottomRight.y:=R.TopLeft.y+1;
              Bitmap.Canvas.FillRect(R);

              Bitmap.Canvas.Brush.Color:=GetColorByTValue(A[i, j]);
              R.TopLeft.x:=2*j;
              R.TopLeft.y:=2*i+1;
              R.BottomRight.x:=R.TopLeft.x+2;
              R.BottomRight.y:=R.TopLeft.y+1;
              Bitmap.Canvas.FillRect(R);
            end;
          ctHeatSource1:
            DrawSolidCell(GetColorByTValue(HeatSource1T));
          ctHeatSource2:
            DrawSolidCell(GetColorByTValue(HeatSource2T));
          ctNotUsed:
            DrawSolidCell(clBtnFace);
        end;

    R.Left:=0;
    R.Top:=0;
    R.Right:=256;
    R.Bottom:=256;
    Image.Canvas.StretchDraw(R, Bitmap);
//    Image.Picture.Assign(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.miAboutClick(Sender: TObject);
begin
  fmAbout:=TfmAbout.Create(Self);
  try
    fmAbout.imgMain.Picture.Icon:=Application.Icon;
    fmAbout.ShowModal;
  finally
    fmAbout.Free;
  end;

end;

procedure TfmMain.stbMainResize(Sender: TObject);
begin
  stbMain.Panels[0].Width:=stbMain.ClientWidth-420;
end;

procedure TfmMain.Delay;
var
  StartTime: DWORD;
begin
  StartTime:=GetTickCount;
  while (GetTickCount - StartTime < 1000 div (trbSpeed.Position + 1)) and (bRunning) do
    Application.ProcessMessages;
end;

procedure TfmMain.SetStatusOnStop;
begin
  SetControlsEnabled(true);
  actStart.Enabled:=true;
  actPause.Enabled:=false;
  actStop.Enabled:=false;

  CurTime:=0;

  stbMain.Panels[3].Text:=Format(sCurTimeName, [0]);

  ChangeParam(Self);

  stbMain.Panels[2].Text:=Format(sMMKStr, [YCoord, XCoord, MMKRes, A[YCoord, XCoord]]);
end;
 
procedure TfmMain.SimulationLoop;
var
  i, j: Integer;
  Temp: Single;

  procedure MakeTimeStep;
  begin
    Inc(CurTime);
    stbMain.Panels[3].Text:=Format(sCurTimeName, [CurTime]);

    stbMain.Panels[2].Text:=Format(sMMKStr, [YCoord, XCoord, MMKRes, A[YCoord, XCoord]]);
  end;

begin
  while bRunning do
    begin
      for i:=0 to 31 do
        for j:=0 to 31 do
          if Tags[i, j] = ctMedium then
            begin
              Temp:=A[i, j];

              B[i, j]:=Temp+MuParam/AParam*(A[i, j-1]+A[i, j+1]+A[i-1, j]+A[i+1, j]-4*Temp);
            end;

      Move(B, A, SizeOf(B));
      RefreshLagging;
      DrawField(imgMain);

      Delay;

      if bRunning then
        MakeTimeStep
      else
        if bStopped then
          SetStatusOnStop
        else
          begin
            actPause.Enabled:=false;
            actStart.Enabled:=true;

            MakeTimeStep;
          end;
    end;
end;

function CalcMMK(i, j, n: Integer): Single;
var
  k: Integer;
  i2, j2: Integer;
  Tag: TCellType;
begin
  Randomize;
  Result:=0;

  for k:=1 to n do
    begin
      i2:=i;
      j2:=j;

      repeat
        Tag:=Tags[i2, j2];
        case Tag of
          ctLaggingNormalLeft:
            Dec(j2);
          ctLaggingNormalUp:
            Dec(i2);
          ctLaggingNormalRight:
            Inc(j2);
          ctLaggingNormalDown:
            Inc(i2);
          ctMedium:
            case Random(4) of
              0:
                Inc(j2);
              1:
                Dec(j2);
              2:
                Inc(i2);
              3:
                Dec(i2);
            end;
        end;
      until
        (Tag = ctHeatSource1) or (Tag = ctHeatSource2);

      if Tag = ctHeatSource1 then
        Result:=Result+HeatSource1T
      else
        Result:=Result+HeatSource2T;
    end;

  Result:=Result/n;
end;

procedure TfmMain.actStartExecute(Sender: TObject);
begin
  if CurTime = 0 then
    begin
      SetControlsEnabled(false);

      MuParam:=StrToFloat(ProcessMaskEditString(meMuParam.Text));
      AParam:=StrToFloat(ProcessMaskEditString(meAParam.Text));

      actStop.Enabled:=true;
      bStopped:=false;

      YCoord:=StrToInt(ProcessMaskEditString(meYCoord.Text));
      XCoord:=StrToInt(ProcessMaskEditString(meXCoord.Text));
      MMKRes:=CalcMMK(YCoord, XCoord, StrToInt(ProcessMaskEditString(meChainsCount.Text)));
    end;

  actStart.Enabled:=false;
  actPause.Enabled:=true;

  bRunning:=true;

  SimulationLoop;
end;

procedure TfmMain.actPauseExecute(Sender: TObject);
begin
  bRunning:=false;
end;

procedure TfmMain.actStopExecute(Sender: TObject);
begin
  if bRunning then
    begin
      bRunning:=false;
      bStopped:=true;
    end
  else
    begin
      bStopped:=true;
      SetStatusOnStop;
    end;
end;

procedure SetTemperatures(MediumTemp, HeatSource1Temp, HeatSource2Temp: Single);
begin
  MediumT:=MediumTemp;
  HeatSource1T:=HeatSource1Temp;
  HeatSource2T:=HeatSource2Temp;

  MinT:=Min(Min(MediumT, HeatSource1T), HeatSource2T);
  MaxT:=Max(Max(MediumT, HeatSource1T), HeatSource2T);
  DeltaT:=(MaxT - MinT) / 256;

  fmMain.laMinT.Caption:=FloatToStrF(MinT, ffFixed, 7, 2);
  fmMain.laMaxT.Caption:=FloatToStrF(MaxT, ffFixed, 7, 2);
end;

procedure RefreshCells;
begin
  FillMediumCells;
  FillHeatSource1Cells;
  FillHeatSource2Cells;
  RefreshLagging;
  Move(A, B, SizeOf(A));
end;

procedure TfmMain.ChangeParam(Sender: TObject);
begin
  SetTemperatures(StrToFloat(ProcessMaskEditString(meMediumT.Text)), StrToFloat(ProcessMaskEditString(meHeatSource1T.Text)), StrToFloat(ProcessMaskEditString(meHeatSource2T.Text)));
  RefreshCells;
  DrawField(imgMain);
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  Res: Integer;
  i, j: Integer;
  it: Integer;

  procedure DrawLegend;
  var
    i, j: Integer;
    Bitmap: TBitmap;
  begin
    Bitmap:=TBitmap.Create;
    try
      Bitmap.Width:=32;
      Bitmap.Height:=256;

      for i:=0 to 255 do
        for j:=0 to 31 do
          Bitmap.Canvas.Pixels[j, i]:=RGB(255-i, 0, i);

      imgLegend.Picture.Assign(Bitmap);
    finally
      Bitmap.Free;
    end;
  end;

begin
  DecimalSeparator:='.';

  AssignFile(Input, 'tags.txt');
  {$I-}
  Reset(Input);
  Res:=IOREsult;
  {$I+}

  if Res <> 0 then
    begin
      for i:=0 to 31 do
        for j:=0 to 31 do
          Tags[i, j]:=ctMedium;
    end
  else
    begin
      for i:=0 to 31 do
        for j:=0 to 31 do
          begin
            Read(it);
            Tags[i, j]:=TCellType(it);
          end;

      CloseFile(Input);
    end;

  stbMain.Panels[3].Text:=Format(sCurTimeName, [0]);

  DrawLegend;

  SetTemperatures(10, 300, 100);
  RefreshCells;
  DrawField(imgMain);
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if bRunning then
    actStop.Execute;
end;

procedure TfmMain.SetControlsEnabled(bEnabled: boolean);
begin
  laMediumT.Enabled:=bEnabled;
  meMediumT.Enabled:=bEnabled;
  laHeatSource1T.Enabled:=bEnabled;
  meHeatSource1T.Enabled:=bEnabled;
  laHeatSource2T.Enabled:=bEnabled;
  meHeatSource2T.Enabled:=bEnabled;
  laMuParam.Enabled:=bEnabled;
  meMuParam.Enabled:=bEnabled;
  laAParam.Enabled:=bEnabled;
  meAParam.Enabled:=bEnabled;
  laXCoord.Enabled:=bEnabled;
  meXCoord.Enabled:=bEnabled;
  laYCoord.Enabled:=bEnabled;
  meYCoord.Enabled:=bEnabled;
  laChainsCount.Enabled:=bEnabled;
  meChainsCount.Enabled:=bEnabled;
end;

procedure TfmMain.imgMainMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  i, j: Integer;
begin
  i:=Y div 8;
  j:=X div 8;
  if Tags[i, j] = ctNotUsed then
    stbMain.Panels[1].Text:=''
  else
    stbMain.Panels[1].Text:=Format(sCellTName, [i, j, A[i, j]]);
end;

procedure TfmMain.imgMainMouseLeave(Sender: TObject);
begin
  stbMain.Panels[1].Text:='';
end;

end.
