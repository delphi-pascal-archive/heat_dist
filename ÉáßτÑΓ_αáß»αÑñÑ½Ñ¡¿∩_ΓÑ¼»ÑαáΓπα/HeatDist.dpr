program HeatDist;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uAbout in 'uAbout.pas' {fmAbout};

{$R *.RES}

begin
  Application.Title:='������ ������������� ����������';
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
