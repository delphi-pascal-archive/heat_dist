unit uAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ShellAPI;

type
  TfmAbout = class(TForm)
    imgMain: TImage;
    laProgramName: TLabel;
    laCopyright: TLabel;
    btOk: TButton;
    laWebSiteAddress: TLabel;
    procedure laWebSiteAddressClick(Sender: TObject);
  private
  public
  end;

var
  fmAbout: TfmAbout;

implementation

{$R *.dfm}

procedure TfmAbout.laWebSiteAddressClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, PChar('open'), PChar('http://www.loonies.narod.ru'), nil, nil, SW_NORMAL);
end;

end.
