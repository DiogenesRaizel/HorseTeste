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
  private
    procedure ConfigurarConexao;
  public
    constructor Create(AOwner: TComponent); override;
  end;


implementation

{$R *.lfm}

constructor TDM.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ConfigurarConexao;

  ZConnection1.Connected := True;
end;

procedure TDM.ConfigurarConexao;
begin
  ZConnection1.Database :=
    ExpandFileName(
      IncludeTrailingPathDelimiter(
        ExtractFileDir(ParamStr(0))
      ) +
      '../data/HorseTeste.db'
    );
end;

end.

