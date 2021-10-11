unit NewImage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls;

type
  TMouseEnterEvent = procedure (Sender: TObject) of object;
  TMouseLeaveEvent = procedure (Sender: TObject) of object;

  TNewImage = class(TImage)
  private
    FOnMouseEnter: TMouseEnterEvent;
    FOnMouseLeave: TMouseLeaveEvent;
    procedure CMMouseEnter (var message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave (var message: TMessage); message CM_MOUSELEAVE;
  protected
  public
  published
    property OnMouseEnter: TMouseEnterEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TMouseLeaveEvent read FOnMouseLeave write FOnMouseLeave;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TNewImage]);
end;

{ TNewImage }

procedure TNewImage.CMMouseEnter(var message: TMessage);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TNewImage.CMMouseLeave(var message: TMessage);
begin
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

end.
