unit uDM;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  SyncObjs,
  ZConnection,
  ZDataset;

type

  TDM = class(TDataModule)
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    ZTransaction1: TZTransaction;
  private
    FLock: TCriticalSection;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Enter;
    procedure Leave;
  end;

implementation

{$R *.lfm}

constructor TDM.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FLock := TCriticalSection.Create;
end;

destructor TDM.Destroy;
begin
  FLock.Free;

  inherited Destroy;
end;

procedure TDM.Enter;
begin
  FLock.Acquire;
end;

procedure TDM.Leave;
begin
  FLock.Release;
end;

end.


