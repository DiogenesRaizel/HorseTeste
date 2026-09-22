unit uDM;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  ZConnection,
  ZDataset;

type

  { TDM }

  TDM = class(TDataModule)
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    ZTransaction1: TZTransaction;
  end;

var
  DM: TDM;

implementation

{$R *.lfm}

end.
